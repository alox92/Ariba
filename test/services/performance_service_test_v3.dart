import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_app/services/performance_service.dart';
import 'package:flashcards_app/data/models/card.dart';
import 'package:flashcards_app/domain/entities/deck_with_stats.dart';

void main() {
  group('PerformanceService Tests', () {
    late PerformanceService performanceService;

    setUp(() {
      performanceService = PerformanceService();
    });

    tearDown(() {
      performanceService.dispose();
    });

    test('should be a singleton', () {
      final instance1 = PerformanceService();
      final instance2 = PerformanceService();
      
      expect(identical(instance1, instance2), true);
    });

    test('should initialize with default values', () {
      expect(performanceService.optimizationEnabled, true);
      expect(performanceService.getAverageCardLoadTimeMs(), 0.0);
      expect(performanceService.themeModeNotifier.value, ThemeMode.system);
    });

    test('should update theme mode', () {
      performanceService.updateThemeMode(ThemeMode.dark);
      
      expect(performanceService.themeModeNotifier.value, ThemeMode.dark);
    });

    test('should set optimization enabled/disabled', () {
      performanceService.setOptimizationEnabled(false);
      expect(performanceService.optimizationEnabled, false);
      
      performanceService.setOptimizationEnabled(true);
      expect(performanceService.optimizationEnabled, true);
    });

    test('should identify large collections correctly', () {
      // Small collection
      expect(performanceService.isLargeCollection(100), false);
      
      // Large collection
      expect(performanceService.isLargeCollection(600), true);
      
      // Very large collection
      expect(performanceService.isVeryLargeCollection(2500), true);
      expect(performanceService.isVeryLargeCollection(600), false);
    });

    test('should record and calculate average card load time', () {
      // Initially should be 0
      expect(performanceService.getAverageCardLoadTimeMs(), 0.0);
      
      // Record some load times
      performanceService.recordCardLoadTime(const Duration(milliseconds: 100));
      expect(performanceService.getAverageCardLoadTimeMs(), 100.0);
      
      performanceService.recordCardLoadTime(const Duration(milliseconds: 200));
      expect(performanceService.getAverageCardLoadTimeMs(), 150.0);
      
      performanceService.recordCardLoadTime(const Duration(milliseconds: 300));
      expect(performanceService.getAverageCardLoadTimeMs(), 200.0);
    });

    test('should load cards batched for large collections', () async {
      final cards = List.generate(1000, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      // For large collection, should return batch
      final batchedCards = await performanceService.loadCardsBatched(cards, 0);
      expect(batchedCards.length, 50);
      expect(batchedCards.first.id, 0);
      expect(batchedCards.last.id, 49);
      
      // For offset batch
      final offsetBatchedCards = await performanceService.loadCardsBatched(cards, 100);
      expect(offsetBatchedCards.length, 50);
      expect(offsetBatchedCards.first.id, 100);
      expect(offsetBatchedCards.last.id, 149);
    });

    test('should return all cards for small collections', () async {
      final cards = List.generate(100, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      // For small collection, should return all cards
      final result = await performanceService.loadCardsBatched(cards, 0);
      expect(result.length, 100);
      expect(result, equals(cards));
    });

    test('should return all cards when optimization is disabled', () async {
      performanceService.setOptimizationEnabled(false);
      
      final cards = List.generate(1000, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      // Should return all cards even for large collection when optimization disabled
      final result = await performanceService.loadCardsBatched(cards, 0);
      expect(result.length, 1000);
      expect(result, equals(cards));
    });

    test('should handle edge cases in batched loading', () async {
      final cards = List.generate(75, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      // Request batch at end
      final endBatch = await performanceService.loadCardsBatched(cards, 700);
      expect(endBatch.length, 75); // Should return all since collection is small
      
      // For large collection, test partial batch at end
      final largeCards = List.generate(1060, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      final partialBatch = await performanceService.loadCardsBatched(largeCards, 1040);
      expect(partialBatch.length, 20); // Only 20 remaining cards
    });

    test('should provide optimization suggestions', () {
      // For small collection with good performance
      var suggestions = performanceService.getOptimizationSuggestions(100, 50.0);
      expect(suggestions, isEmpty);
      
      // For large collection
      suggestions = performanceService.getOptimizationSuggestions(800, 50.0);
      expect(suggestions.length, 1);
      expect(suggestions.first, contains('Grande collection'));
      
      // For very large collection
      suggestions = performanceService.getOptimizationSuggestions(3000, 50.0);
      expect(suggestions.length, 1);
      expect(suggestions.first, contains('très grande'));
      
      // For slow loading
      suggestions = performanceService.getOptimizationSuggestions(100, 250.0);
      expect(suggestions.length, 1);
      expect(suggestions.first, contains('Temps de chargement'));
      
      // For large collection with slow loading
      suggestions = performanceService.getOptimizationSuggestions(800, 250.0);
      expect(suggestions.length, 2);
    });

    test('should optimize memory for different collection sizes', () {
      final deckWithStats = DeckWithStats(
        id: 1,
        name: 'Test Deck',
        description: 'Test Description',
        cardCount: 100,
        lastAccessed: DateTime.now(),
        createdAt: DateTime.now(),
        dueTodayCount: 5,
        averagePerformance: 0.8,
      );
      
      // Should not throw any errors
      expect(() => performanceService.optimizeMemoryForCollection(deckWithStats), returnsNormally);
      
      // Test with large collection
      final largeDeck = DeckWithStats(
        id: 2,
        name: 'Large Deck',
        description: 'Large Description',
        cardCount: 800,
        lastAccessed: DateTime.now(),
        createdAt: DateTime.now(),
        dueTodayCount: 20,
        averagePerformance: 0.7,
      );
      expect(() => performanceService.optimizeMemoryForCollection(largeDeck), returnsNormally);
      
      // Test with very large collection
      final veryLargeDeck = DeckWithStats(
        id: 3,
        name: 'Very Large Deck',
        description: 'Very Large Description',
        cardCount: 3000,
        lastAccessed: DateTime.now(),
        createdAt: DateTime.now(),
        dueTodayCount: 100,
        averagePerformance: 0.6,
      );
      expect(() => performanceService.optimizeMemoryForCollection(veryLargeDeck), returnsNormally);
    });

    test('should skip memory optimization when disabled', () {
      performanceService.setOptimizationEnabled(false);
      
      final deckWithStats = DeckWithStats(
        id: 1,
        name: 'Test Deck',
        description: 'Test Description',
        cardCount: 3000,
        lastAccessed: DateTime.now(),
        createdAt: DateTime.now(),
        dueTodayCount: 100,
        averagePerformance: 0.6,
      );
      
      // Should not throw any errors and should skip optimization
      expect(() => performanceService.optimizeMemoryForCollection(deckWithStats), returnsNormally);
    });

    test('should handle preload media when optimization disabled', () async {
      performanceService.setOptimizationEnabled(false);
      
      final cards = List.generate(10, (index) => FlashCard(
        id: index,
        deckId: 1,
        frontText: 'Front $index',
        backText: 'Back $index',
        tags: 'tag$index',
        createdAt: DateTime.now(),
        interval: 1,
        easeFactor: 2.5,
      ));
      
      // Should not throw any errors when optimization is disabled
      expect(() => performanceService.preloadMediaForCards(cards, 0), returnsNormally);
    });

    test('should handle cleanup temp media gracefully', () async {
      // Should not throw any errors even if temp directory doesn't exist
      expect(() => performanceService.cleanupTempMedia(), returnsNormally);
    });
  });
}
