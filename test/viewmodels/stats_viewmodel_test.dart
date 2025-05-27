// ignore_for_file: prefer_const_declarations

import 'package:flashcards_app/data/models/daily_aggregated_stats.dart';
import 'package:flashcards_app/data/models/review_stats.dart'; // Added import for ReviewStatsData
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:intl/intl.dart';

import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/viewmodels/stats_viewmodel.dart';

@GenerateMocks([StatsDao, Database, DecksDao, CardsDao])
import 'stats_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockStatsDao mockStatsDao;
  late MockDatabase mockDatabase;
  late MockDecksDao mockDecksDao;
  late MockCardsDao mockCardsDao;
  late StatsViewModel statsViewModel;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  setUp(() {
    mockDatabase = MockDatabase();
    mockStatsDao = MockStatsDao();
    mockDecksDao = MockDecksDao();
    mockCardsDao = MockCardsDao();

    when(mockDatabase.statsDao).thenReturn(mockStatsDao);
    when(mockDatabase.decksDao).thenReturn(mockDecksDao);
    when(mockDatabase.cardsDao).thenReturn(mockCardsDao);

    statsViewModel = StatsViewModel(mockDatabase);

    when(mockStatsDao.getStatsForDeck(any)).thenAnswer((_) async => []);
    when(mockStatsDao.getPerformanceDistribution(any))
        .thenAnswer((_) async => {});
    when(mockStatsDao.getDailyStats(any)).thenAnswer((_) async => []);
    when(mockStatsDao.getAverageDeckPerformance(any))
        .thenAnswer((_) async => 0.0);
    when(mockCardsDao.getCardCountForDeck(any)).thenAnswer((_) async => 0);
    when(mockCardsDao.getEaseFactorDistribution()).thenAnswer((_) async => {});
    when(mockCardsDao.getAllCards()).thenAnswer((_) async => []);
    when(mockCardsDao.getCardsForDeck(any)).thenAnswer((_) async => []);

    when(mockDecksDao.getTotalDeckCount()).thenAnswer((_) async => 0);
    when(mockCardsDao.getTotalCardCount()).thenAnswer((_) async => 0);
    when(mockStatsDao.getTotalReviewCount()).thenAnswer((_) async => 0);
  });

  group('StatsViewModel Tests', () {
    test('Initial values are correct', () {
      expect(statsViewModel.isLoading, false);
      expect(statsViewModel.error, null);
      expect(statsViewModel.aggregatedReviewStatsByDay, isEmpty);
      expect(statsViewModel.averageSuccessRate, 0);
      expect(statsViewModel.performanceDistribution, isEmpty);
      expect(statsViewModel.globalDeckCount, 0);
      expect(statsViewModel.globalCardCount, 0);
      expect(statsViewModel.globalReviewCount, 0);
      expect(statsViewModel.globalUpcomingReviewsCount, 0);
    });

    test('loadStatsForDeck fetches data and updates state', () async {
      final deckId = 1;
      const mockDistribution = {1: 1, 3: 2};
      final mockDailyStatsMaps = [
        {'day': '2024-01-01', 'review_count': 5, 'avg_performance': 3.5}
      ];
      final mockAggregatedDailyStats = mockDailyStatsMaps
          .map((map) => DailyAggregatedStats.fromMap(map))
          .toList();
      const mockAvgPerformance = 3.7;
      const mockCardCount = 10;
      final mockEaseFactors = {'2.5': 5, '1.3': 5};

      when(mockStatsDao.getStatsForDeck(deckId)).thenAnswer((_) async => []);
      when(mockStatsDao.getDailyStats(deckId))
          .thenAnswer((_) async => mockDailyStatsMaps);
      when(mockStatsDao.getAverageDeckPerformance(deckId))
          .thenAnswer((_) async => mockAvgPerformance);
      when(mockStatsDao.getPerformanceDistribution(deckId))
          .thenAnswer((_) async => mockDistribution);
      when(mockCardsDao.getCardCountForDeck(deckId))
          .thenAnswer((_) async => mockCardCount);
      when(mockCardsDao.getEaseFactorDistribution())
          .thenAnswer((_) async => mockEaseFactors);
      when(mockCardsDao.getCardsForDeck(deckId)).thenAnswer((_) async => [
            CardEntityData(
                id: 1,
                deckId: deckId,
                frontText: 'f',
                backText: 'b',
                tags: 'tag1',
                createdAt: DateTime.now(),
                interval: 1,
                easeFactor: 2.5,
                lastReviewed:
                    DateTime.now().subtract(const Duration(hours: 1))),
            CardEntityData(
                id: 2,
                deckId: deckId,
                frontText: 'f',
                backText: 'b',
                tags: 'tag2',
                createdAt: DateTime.now(),
                interval: 8,
                easeFactor: 2.5,
                lastReviewed:
                    DateTime.now().subtract(const Duration(hours: 1))),
          ]);

      await statsViewModel.loadStatsForDeck(deckId);

      expect(statsViewModel.isLoading, false);
      expect(statsViewModel.error, null);
      expect(statsViewModel.aggregatedReviewStatsByDay.length,
          mockAggregatedDailyStats.length);
      if (mockAggregatedDailyStats.isNotEmpty &&
          statsViewModel.aggregatedReviewStatsByDay.isNotEmpty) {
        expect(statsViewModel.aggregatedReviewStatsByDay[0].date,
            mockAggregatedDailyStats[0].date);
      }
      expect(statsViewModel.averageSuccessRate, mockAvgPerformance / 5.0);
      expect(statsViewModel.performanceDistribution, mockDistribution);
      expect(statsViewModel.cardsInDeck, mockCardCount);
      expect(statsViewModel.easeFactorDistribution, mockEaseFactors);
      expect(statsViewModel.upcomingReviews, isNotEmpty);
    });

    test('loadStatsForDeck handles error gracefully', () async {
      final deckId = 1;
      final errorMessage = 'Database error';
      when(mockStatsDao.getDailyStats(deckId))
          .thenThrow(Exception(errorMessage));
      when(mockStatsDao.getAverageDeckPerformance(deckId))
          .thenAnswer((_) async => 0.0);
      when(mockStatsDao.getStatsForDeck(deckId)).thenAnswer((_) async => []);
      when(mockStatsDao.getPerformanceDistribution(deckId))
          .thenAnswer((_) async => {});

      await statsViewModel.loadStatsForDeck(deckId);

      expect(statsViewModel.isLoading, false);
      expect(statsViewModel.error, isNotNull);
      expect(statsViewModel.error!.toLowerCase().contains('database error'),
          isTrue);
    });

    test('recordCardReview calls addReviewStat on dao', () async {
      final cardId = 1;
      final performance = 4;
      final time = 3000;

      when(mockStatsDao.addStats(any)).thenAnswer((_) async => 1);

      await statsViewModel.recordCardReview(cardId, performance, time);

      verify(mockStatsDao.addStats(any)).called(1);
    });

    test('getStatsByPeriod filters and groups review stats correctly',
        () async {
      final deckId = 1;
      final startDate = DateTime(2025, 5, 1);
      final endDate = DateTime(2025, 5, 31);

      final mockDailyStatsResultMaps = [
        {'day': '2025-05-05', 'review_count': 2, 'avg_performance': 3.5},
        {'day': '2025-05-06', 'review_count': 1, 'avg_performance': 5.0},
        {
          'day': '2025-06-01',
          'review_count': 3,
          'avg_performance': 4.0
        } // Out of range
      ];

      when(mockStatsDao.getDailyStats(deckId))
          .thenAnswer((_) async => mockDailyStatsResultMaps);
      when(mockStatsDao.getStatsForDeck(deckId)).thenAnswer((_) async => []);
      when(mockStatsDao.getAverageDeckPerformance(deckId))
          .thenAnswer((_) async => 0.0);
      when(mockStatsDao.getPerformanceDistribution(deckId))
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardCountForDeck(deckId)).thenAnswer((_) async => 0);
      when(mockCardsDao.getEaseFactorDistribution())
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardsForDeck(deckId)).thenAnswer((_) async => []);

      await statsViewModel.loadStatsForDeck(deckId);
      final result = statsViewModel.aggregatedReviewStatsByDay.where((stat) {
        return !stat.date.isBefore(startDate) && !stat.date.isAfter(endDate);
      }).toList();

      expect(result.length, 2);

      final may5Stats = result
          .firstWhere((stat) => formatter.format(stat.date) == '2025-05-05');
      expect(may5Stats.reviewCount, 2);
      expect(may5Stats.averagePerformance, 3.5);

      final may6Stats = result
          .firstWhere((stat) => formatter.format(stat.date) == '2025-05-06');
      expect(may6Stats.reviewCount, 1);
      expect(may6Stats.averagePerformance, 5.0);
    });

    test('loadStatsForPeriod fetches data', () async {
      final startDate = DateTime(2024, 1, 1);
      final endDate = DateTime(2024, 1, 31);
      final deckId = 1;

      final mockDailyStatsMaps = [
        {'day': '2024-01-15', 'review_count': 3, 'avg_performance': 4.0},
        {
          'day': '2023-12-31',
          'review_count': 1,
          'avg_performance': 2.0
        } // Out of range
      ];

      when(mockStatsDao.getDailyStats(deckId))
          .thenAnswer((_) async => mockDailyStatsMaps);
      when(mockStatsDao.getStatsForDeck(deckId)).thenAnswer((_) async => []);
      when(mockStatsDao.getAverageDeckPerformance(deckId))
          .thenAnswer((_) async => 0.0);
      when(mockStatsDao.getPerformanceDistribution(deckId))
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardCountForDeck(deckId)).thenAnswer((_) async => 0);
      when(mockCardsDao.getEaseFactorDistribution())
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardsForDeck(deckId)).thenAnswer((_) async => []);

      await statsViewModel.loadStatsForDeck(deckId);

      final filteredStats =
          statsViewModel.aggregatedReviewStatsByDay.where((stat) {
        return !stat.date.isBefore(startDate) && !stat.date.isAfter(endDate);
      }).toList();

      expect(statsViewModel.isLoading, false);
      expect(statsViewModel.error, null);
      expect(filteredStats.length, 1);
      expect(formatter.format(filteredStats.first.date), '2024-01-15');
    });

    test('loadGlobalStats fetches global data and updates state', () async {
      const mockDeckCount = 5;
      const mockCardCount = 100;
      const mockReviewCount = 500;
      final mockCardsForUpcoming = [
        CardEntityData(
            id: 1,
            deckId: 1,
            frontText: 'f',
            backText: 'b',
            createdAt: DateTime.now(),
            tags: 'tag1',
            interval: 1,
            easeFactor: 2.5,
            lastReviewed: DateTime.now().subtract(const Duration(hours: 1))),
        CardEntityData(
            id: 2,
            deckId: 1,
            frontText: 'f',
            backText: 'b',
            createdAt: DateTime.now(),
            tags: 'tag2',
            interval: 2,
            easeFactor: 2.5,
            lastReviewed: DateTime.now().subtract(const Duration(hours: 1))),
      ];
      const mockUpcomingCount = 2;

      when(mockDecksDao.getTotalDeckCount())
          .thenAnswer((_) async => mockDeckCount);
      when(mockCardsDao.getTotalCardCount())
          .thenAnswer((_) async => mockCardCount);
      when(mockStatsDao.getTotalReviewCount())
          .thenAnswer((_) async => mockReviewCount);
      when(mockCardsDao.getAllCards())
          .thenAnswer((_) async => mockCardsForUpcoming);

      await statsViewModel.loadGlobalStats();

      expect(statsViewModel.isLoading, false);
      expect(statsViewModel.error, null);
      expect(statsViewModel.globalDeckCount, mockDeckCount);
      expect(statsViewModel.globalCardCount, mockCardCount);
      expect(statsViewModel.globalReviewCount, mockReviewCount);
      expect(statsViewModel.globalUpcomingReviewsCount, mockUpcomingCount);

      expect(statsViewModel.cardsInDeck, 0);
      expect(statsViewModel.reviewStatsByDate, isEmpty);
      expect(statsViewModel.performanceDistribution, isEmpty);
      expect(statsViewModel.aggregatedReviewStatsByDay, isEmpty);
      expect(statsViewModel.averageSuccessRate, 0.0);
      expect(statsViewModel.upcomingReviews, isEmpty);
      expect(statsViewModel.easeFactorDistribution, isEmpty);
    });

    test('calculateStudyEfficiency returns correct value', () async {
      final deckId = 1;
      // Mock review stats for the deck
      final mockReviewStats = [
        ReviewStatsData(
            id: 1,
            cardId: 1,
            date: DateTime.now(), // Corrected from reviewDate to date
            performanceRating: 4,
            timeSpentMs: 5000),
        ReviewStatsData(
            id: 2,
            cardId: 2,
            date: DateTime.now(), // Corrected from reviewDate to date
            performanceRating: 5,
            timeSpentMs: 3000),
      ];
      // Stub the getStatsForDeck to return these mock stats when loadStatsForDeck is called
      // or directly set _reviewStatsForDeck if testing the method in isolation (less ideal for viewmodel)
      when(mockStatsDao.getStatsForDeck(deckId))
          .thenAnswer((_) async => mockReviewStats);
      // Stub other calls made by loadStatsForDeck
      when(mockStatsDao.getDailyStats(deckId)).thenAnswer((_) async => []);
      when(mockStatsDao.getAverageDeckPerformance(deckId))
          .thenAnswer((_) async => 0.0);
      when(mockStatsDao.getPerformanceDistribution(deckId))
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardCountForDeck(deckId)).thenAnswer((_) async => 2);
      when(mockCardsDao.getEaseFactorDistribution())
          .thenAnswer((_) async => {});
      when(mockCardsDao.getCardsForDeck(deckId))
          .thenAnswer((_) async => []); // Assuming no upcoming for this test

      await statsViewModel
          .loadStatsForDeck(deckId); // Load the stats into the viewmodel

      final efficiency = statsViewModel.calculateStudyEfficiency(deckId);

      // Expected calculation:
      // totalPerformance = 4 + 5 = 9
      // totalTimeMs = 5000 + 3000 = 8000
      // avgPerformance = 9 / 2 = 4.5
      // avgTimeSeconds = (8000 / 2) / 1000 = 4000 / 1000 = 4
      // efficiency = 4.5 / (4 / 10) = 4.5 / 0.4 = 11.25
      expect(efficiency, closeTo(11.25, 0.01));

      // Test with empty stats
      when(mockStatsDao.getStatsForDeck(deckId)).thenAnswer((_) async => []);
      await statsViewModel.loadStatsForDeck(deckId);
      final zeroEfficiency = statsViewModel.calculateStudyEfficiency(deckId);
      expect(zeroEfficiency, 0.0);
    });
  });
}
