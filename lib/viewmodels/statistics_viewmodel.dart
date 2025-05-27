import 'package:flutter/foundation.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';

class StatisticsData {
  final int totalDecks;
  final int totalCards;
  final int cardsStudiedToday;
  final int studyStreak;
  final double averageAccuracy;
  final List<DeckStats> deckStats;
  final List<StudySessionData> recentSessions;

  StatisticsData({
    required this.totalDecks,
    required this.totalCards,
    required this.cardsStudiedToday,
    required this.studyStreak,
    required this.averageAccuracy,
    required this.deckStats,
    required this.recentSessions,
  });
}

class DeckStats {
  final Deck deck;
  final int totalCards;
  final int masteredCards;
  final int reviewCards;
  final int newCards;
  final DateTime? lastStudied;
  final double accuracy;

  DeckStats({
    required this.deck,
    required this.totalCards,
    required this.masteredCards,
    required this.reviewCards,
    required this.newCards,
    this.lastStudied,
    required this.accuracy,
  });

  double get masteryPercentage => totalCards == 0 ? 0.0 : masteredCards / totalCards;
}

class StudySessionData {
  final DateTime date;
  final int cardsStudied;
  final double accuracy;
  final Duration studyTime;

  StudySessionData({
    required this.date,
    required this.cardsStudied,
    required this.accuracy,
    required this.studyTime,
  });
}

class StatisticsViewModel extends ChangeNotifier {
  final GetDecksUseCase _getDecksUseCase;
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;

  StatisticsViewModel({
    required GetDecksUseCase getAllDecksUseCase,
    required GetCardsByDeckUseCase getCardsByDeckUseCase,
  }) : _getDecksUseCase = getAllDecksUseCase,
       _getCardsByDeckUseCase = getCardsByDeckUseCase {
    loadStatistics();
  }

  // State
  StatisticsData? _statisticsData;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String _selectedTimeRange = 'week'; // week, month, year, all

  // Getters
  StatisticsData? get statisticsData => _statisticsData;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  String get selectedTimeRange => _selectedTimeRange;

  Future<void> loadStatistics() async {
    _setLoading(true);
    _clearError();

    try {
      // Listen to the stream of decks
      _getDecksUseCase.call().listen((decksResult) async {
        await decksResult.fold(
          (failure) async {
            _setError('Failed to load statistics: ${failure.message}');
          },
          (decks) async {
            // Calculate statistics for each deck
            final List<DeckStats> deckStats = [];
            int totalCards = 0;
            int totalMasteredCards = 0;
            
            for (final deck in decks) {
              // Listen to the first result from the stream
              await for (final cardsResult in _getCardsByDeckUseCase.call(deck.id)) {
                await cardsResult.fold(
                  (failure) async {
                    // Skip this deck if we can't load cards
                    debugPrint('Failed to load cards for deck ${deck.id}: ${failure.message}');
                  },
                  (cards) async {
                    totalCards += cards.length;
                    
                    // Calculate card statistics
                    final masteredCards = cards.where((card) => card.easinessFactor >= 2.5).length;
                    final reviewCards = cards.where((card) => card.nextReviewDate != null && 
                        card.nextReviewDate!.isBefore(DateTime.now().add(const Duration(days: 1)))).length;
                    final newCards = cards.where((card) => card.nextReviewDate == null).length;
                    
                    totalMasteredCards += masteredCards;
                    
                    // Calculate accuracy (simplified for now)
                    final accuracy = cards.isEmpty ? 0.0 : masteredCards / cards.length;
                    
                    // Find last studied date (simplified)
                    DateTime? lastStudied;
                    for (final card in cards) {
                      if (card.updatedAt != null && 
                          (lastStudied == null || card.updatedAt!.isAfter(lastStudied))) {
                        lastStudied = card.updatedAt;
                      }
                    }
                    
                    deckStats.add(DeckStats(
                      deck: deck,
                      totalCards: cards.length,
                      masteredCards: masteredCards,
                      reviewCards: reviewCards,
                      newCards: newCards,
                      lastStudied: lastStudied,
                      accuracy: accuracy,
                    ));
                  },
                );
                break; // Only take the first result
              }
            }
            
            // Calculate overall statistics
            final cardsStudiedToday = _calculateCardsStudiedToday(deckStats);
            final studyStreak = _calculateStudyStreak(deckStats);
            final averageAccuracy = totalCards == 0 ? 0.0 : totalMasteredCards / totalCards;
            final recentSessions = _generateRecentSessions(deckStats);
            
            _statisticsData = StatisticsData(
              totalDecks: decks.length,
              totalCards: totalCards,
              cardsStudiedToday: cardsStudiedToday,
              studyStreak: studyStreak,
              averageAccuracy: averageAccuracy,
              deckStats: deckStats,
              recentSessions: recentSessions,
            );
            
            _setLoading(false);
            notifyListeners();
          },
        );
      });
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setLoading(false);
    }
  }

  void setTimeRange(String timeRange) {
    if (timeRange != _selectedTimeRange) {
      _selectedTimeRange = timeRange;
      notifyListeners();
      // You could reload statistics filtered by time range here
    }
  }

  int _calculateCardsStudiedToday(List<DeckStats> deckStats) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    int count = 0;
    for (final stat in deckStats) {
      if (stat.lastStudied != null && 
          stat.lastStudied!.isAfter(todayStart)) {
        // This is a simplified calculation
        // In a real app, you'd track individual study sessions
        count += (stat.totalCards * 0.1).round(); // Estimate 10% of cards studied
      }
    }
    return count;
  }
  int _calculateStudyStreak(List<DeckStats> deckStats) {
    // Simplified streak calculation
    // In a real app, you'd track daily study sessions
    final hasStudiedToday = deckStats.any((stat) {
      if (stat.lastStudied == null) {
        return false;
      }
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      return stat.lastStudied!.isAfter(todayStart);
    });
    
    return hasStudiedToday ? 5 : 0; // Simplified: return 5 if studied today, 0 otherwise
  }

  List<StudySessionData> _generateRecentSessions(List<DeckStats> deckStats) {
    // Generate some sample data for recent sessions
    // In a real app, this would come from stored session data
    final sessions = <StudySessionData>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      final cardsStudied = (10 + (i * 3)) - (i * 2); // Vary the number
      final accuracy = 0.7 + (0.05 * (7 - i)); // Improve over time
      final studyTime = Duration(minutes: 15 + (i * 2));
      
      if (cardsStudied > 0) {
        sessions.add(StudySessionData(
          date: date,
          cardsStudied: cardsStudied,
          accuracy: accuracy.clamp(0.0, 1.0),
          studyTime: studyTime,
        ));
      }
    }
    
    return sessions.reversed.toList(); // Most recent first
  }

  void refresh() {
    loadStatistics();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = null;
  }
}
