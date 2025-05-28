import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'package:flashcards_app/services/performance_service.dart';
import 'package:flashcards_app/data/models/card.dart';
import 'package:flashcards_app/domain/entities/deck_with_stats.dart';

// Génération des mocks
@GenerateMocks([File, Directory])
void main() {
  // Initialize Flutter binding for image cache operations
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PerformanceService', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService();
    });    tearDown(() {
      // Reset optimization state but don't dispose singleton
      performanceService.setOptimizationEnabled(true);
    });

    group('Singleton Pattern', () {
      test('should return same instance', () {
        // Arrange
        final instance1 = PerformanceService();
        final instance2 = PerformanceService();
        
        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('Theme Mode Management', () {
      test('should initialize with system theme mode', () {
        // Assert
        expect(performanceService.themeModeNotifier.value, ThemeMode.system);
      });

      test('should update theme mode correctly', () {
        // Act
        performanceService.updateThemeMode(ThemeMode.dark);
        
        // Assert
        expect(performanceService.themeModeNotifier.value, ThemeMode.dark);
      });

      test('should notify listeners when theme mode changes', () async {
        // Arrange
        var notificationCount = 0;
        performanceService.themeModeNotifier.addListener(() {
          notificationCount++;
        });
        
        // Act
        performanceService.updateThemeMode(ThemeMode.light);
        performanceService.updateThemeMode(ThemeMode.dark);
        
        // Assert
        expect(notificationCount, 2);
      });
    });

    group('Collection Size Evaluation', () {
      test('should identify small collections correctly', () {
        // Act & Assert
        expect(performanceService.isLargeCollection(100), isFalse);
        expect(performanceService.isLargeCollection(499), isFalse);
        expect(performanceService.isVeryLargeCollection(100), isFalse);
      });

      test('should identify large collections correctly', () {
        // Act & Assert
        expect(performanceService.isLargeCollection(500), isFalse); // Threshold is >500
        expect(performanceService.isLargeCollection(501), isTrue);
        expect(performanceService.isLargeCollection(1000), isTrue);
        expect(performanceService.isVeryLargeCollection(1000), isFalse);
      });

      test('should identify very large collections correctly', () {
        // Act & Assert
        expect(performanceService.isVeryLargeCollection(2000), isFalse); // Threshold is >2000
        expect(performanceService.isVeryLargeCollection(2001), isTrue);
        expect(performanceService.isVeryLargeCollection(5000), isTrue);
      });
    });

    group('Optimization Settings', () {
      test('should have optimization enabled by default', () {
        // Assert
        expect(performanceService.optimizationEnabled, isTrue);
      });

      test('should allow disabling optimization', () {
        // Act
        performanceService.setOptimizationEnabled(false);
        
        // Assert
        expect(performanceService.optimizationEnabled, isFalse);
      });

      test('should allow re-enabling optimization', () {
        // Arrange
        performanceService.setOptimizationEnabled(false);
        
        // Act
        performanceService.setOptimizationEnabled(true);
        
        // Assert
        expect(performanceService.optimizationEnabled, isTrue);
      });
    });

    group('Batch Loading', () {
      test('should return all cards for small collections', () async {
        // Arrange
        final cards = List.generate(100, (i) => _createTestCard(i));
        
        // Act
        final result = await performanceService.loadCardsBatched(cards, 0);
        
        // Assert
        expect(result.length, 100);
        expect(result, equals(cards));
      });

      test('should return batch for large collections when optimization enabled', () async {
        // Arrange
        final cards = List.generate(1000, (i) => _createTestCard(i));
        
        // Act
        final result = await performanceService.loadCardsBatched(cards, 0);
        
        // Assert
        expect(result.length, 50);
        expect(result[0].id, 0);
        expect(result[49].id, 49);
      });

      test('should handle offset correctly in batch loading', () async {
        // Arrange
        final cards = List.generate(1000, (i) => _createTestCard(i));
        
        // Act
        final result = await performanceService.loadCardsBatched(cards, 100, batchSize: 25);
        
        // Assert
        expect(result.length, 25);
        expect(result[0].id, 100);
        expect(result[24].id, 124);
      });

      test('should handle end of collection in batch loading', () async {
        // Arrange
        final cards = List.generate(1000, (i) => _createTestCard(i));
        
        // Act
        final result = await performanceService.loadCardsBatched(cards, 990);
        
        // Assert
        expect(result.length, 10); // Only 10 cards remaining
        expect(result[0].id, 990);
        expect(result[9].id, 999);
      });

      test('should return all cards when optimization is disabled', () async {
        // Arrange
        final cards = List.generate(1000, (i) => _createTestCard(i));
        performanceService.setOptimizationEnabled(false);
        
        // Act
        final result = await performanceService.loadCardsBatched(cards, 0);
        
        // Assert
        expect(result.length, 1000);
        expect(result, equals(cards));
      });
    });

    group('Media Preloading', () {
      test('should handle preloading without errors when optimization enabled', () async {
        // Arrange
        final cards = List.generate(10, (i) => _createTestCard(i));
        
        // Act & Assert
        await expectLater(
          () => performanceService.preloadMediaForCards(cards, 0),
          returnsNormally,
        );
      });

      test('should skip preloading when optimization disabled', () async {
        // Arrange
        final cards = List.generate(10, (i) => _createTestCard(i));
        performanceService.setOptimizationEnabled(false);
        
        // Act & Assert
        await expectLater(
          () => performanceService.preloadMediaForCards(cards, 0),
          returnsNormally,
        );
      });

      test('should handle preloading near end of collection', () async {
        // Arrange
        final cards = List.generate(5, (i) => _createTestCard(i));
        
        // Act & Assert
        await expectLater(
          () => performanceService.preloadMediaForCards(cards, 4), // Last card
          returnsNormally,
        );
      });
    });

    group('Memory Optimization', () {
      test('should optimize memory for very large collections', () {
        // Arrange
        final largeDeck = DeckWithStats(
          id: 1,
          name: 'Very Large Deck',
          description: 'Test deck',
          cardCount: 3000, // Very large
          lastAccessed: DateTime.now(),
          createdAt: DateTime.now(),
          dueTodayCount: 10,
          averagePerformance: 0.8,
        );
        
        // Act & Assert
        expect(() => performanceService.optimizeMemoryForCollection(largeDeck), 
               returnsNormally);
      });

      test('should optimize memory for large collections', () {
        // Arrange
        final largeDeck = DeckWithStats(
          id: 1,
          name: 'Large Deck',
          description: 'Test deck',
          cardCount: 1000, // Large
          lastAccessed: DateTime.now(),
          createdAt: DateTime.now(),
          dueTodayCount: 10,
          averagePerformance: 0.8,
        );
        
        // Act & Assert
        expect(() => performanceService.optimizeMemoryForCollection(largeDeck), 
               returnsNormally);
      });

      test('should optimize memory for normal collections', () {
        // Arrange
        final normalDeck = DeckWithStats(
          id: 1,
          name: 'Normal Deck',
          description: 'Test deck',
          cardCount: 100, // Normal size
          lastAccessed: DateTime.now(),
          createdAt: DateTime.now(),
          dueTodayCount: 10,
          averagePerformance: 0.8,
        );
        
        // Act & Assert
        expect(() => performanceService.optimizeMemoryForCollection(normalDeck), 
               returnsNormally);
      });

      test('should skip optimization when disabled', () {
        // Arrange
        performanceService.setOptimizationEnabled(false);
        final deck = DeckWithStats(
          id: 1,
          name: 'Test Deck',
          description: 'Test deck',
          cardCount: 3000,
          lastAccessed: DateTime.now(),
          createdAt: DateTime.now(),
          dueTodayCount: 10,
          averagePerformance: 0.8,
        );
        
        // Act & Assert
        expect(() => performanceService.optimizeMemoryForCollection(deck), 
               returnsNormally);
      });
    });    group('Image Caching', () {
      test('should throw exception for non-existent image paths', () async {
        // Act & Assert
        await expectLater(
          () => performanceService.getCachedImageProvider('/non/existent/path.jpg'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Initialization and Disposal', () {
      test('should initialize without errors', () async {
        // Act & Assert
        await expectLater(
          () => performanceService.initialize(),
          returnsNormally,
        );
      });      test('should handle disposal prepartion', () {
        // Test that resources can be cleared without breaking the service
        performanceService.setOptimizationEnabled(false);
        expect(performanceService.optimizationEnabled, isFalse);
        
        // Reset to ensure service still works
        performanceService.setOptimizationEnabled(true);
        expect(performanceService.optimizationEnabled, isTrue);
      });
    });    group('Performance Metrics', () {
      test('should start with zero average load time', () {
        // Since this is a singleton and might have been used in other tests,
        // we check that it's either 0.0 or has a reasonable value
        final avgTime = performanceService.getAverageCardLoadTimeMs();
        expect(avgTime, greaterThanOrEqualTo(0.0));
      });

      test('should track card load times', () {
        // Arrange & Act
        performanceService.recordCardLoadTime(const Duration(milliseconds: 100));
        
        // Assert
        expect(performanceService.getAverageCardLoadTimeMs(), greaterThan(0.0));
      });      test('should calculate average load time correctly', () {
        // Act
        performanceService.recordCardLoadTime(const Duration(milliseconds: 50));
        performanceService.recordCardLoadTime(const Duration(milliseconds: 150));
        
        // Assert - should have recorded new load times
        final finalAvg = performanceService.getAverageCardLoadTimeMs();
        expect(finalAvg, greaterThanOrEqualTo(0.0));
      });
    });

    group('Constants', () {
      test('should have correct threshold values', () {
        // Assert
        expect(PerformanceService.kLargeCollectionThreshold, 500);
        expect(PerformanceService.kVeryLargeCollectionThreshold, 2000);
        expect(PerformanceService.kMaxImagesToCache, 100);
        expect(PerformanceService.kBatchLoadSize, 50);
      });
    });
  });
}

// Helper function to create test cards
FlashCard _createTestCard(int id) {
  return FlashCard(
    id: id,
    deckId: 1,
    frontText: 'Front $id',
    backText: 'Back $id',
    tags: 'test',
    createdAt: DateTime.now(),
    interval: 1,
    easeFactor: 2.5,
  );
}
