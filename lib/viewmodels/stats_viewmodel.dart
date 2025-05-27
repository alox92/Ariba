// Pour `max` et `min`
import 'package:flutter/material.dart';
import 'package:drift/drift.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/models/review_stats.dart';
import 'package:flashcards_app/data/models/daily_aggregated_stats.dart'; // Import the new model

class StatsViewModel extends ChangeNotifier {
  final Database _database; // Ajout de la base de données complète
  late final StatsDao _statsDao; // Garder pour les requêtes spécifiques
  late final DecksDao _decksDao;
  late final CardsDao _cardsDao;

  // --- États internes ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // --- Données Statistiques (Par Paquet) ---
  int _cardsInDeck = 0;
  List<ReviewStatsData> _reviewStatsForDeck = [];
  Map<int, int> _performanceDistributionForDeck = {};
  List<Map<String, dynamic>> _dailyStatsForDeck = [];
  double _averagePerformanceForDeck = 0.0;
  Map<String, int> _upcomingReviewsForDeck = {};
  Map<String, int> _easeFactorDistributionForDeck = {};
  List<DailyAggregatedStats> _aggregatedReviewStatsByDay =
      []; // New list for aggregated stats

  // --- Données Statistiques (Globales) ---
  int _globalDeckCount = 0;
  int _globalCardCount = 0;
  int _globalReviewCount = 0;
  int _globalUpcomingReviewsCount = 0;

  // --- Constructeur ---
  StatsViewModel(this._database) {
    _statsDao = _database.statsDao;
    _decksDao = _database.decksDao;
    _cardsDao = _database.cardsDao;
  }

  // --- Getters Publics ---
  int get cardsInDeck => _cardsInDeck;
  List<ReviewStatsData> get reviewStatsByDate =>
      _reviewStatsForDeck; // Utiliser le même nom que l'UI
  Map<int, int> get performanceDistribution => _performanceDistributionForDeck;
  List<Map<String, dynamic>> get dailyStats => _dailyStatsForDeck;
  double get averageSuccessRate =>
      _averagePerformanceForDeck / 5.0; // Convertir perf 0-5 en 0-1
  int get reviewCount => _reviewStatsForDeck.length;
  Map<String, int> get upcomingReviews => _upcomingReviewsForDeck;
  Map<String, int> get easeFactorDistribution => _easeFactorDistributionForDeck;
  List<DailyAggregatedStats> get aggregatedReviewStatsByDay =>
      _aggregatedReviewStatsByDay; // Getter for new list

  // Getters Globaux
  int get globalDeckCount => _globalDeckCount;
  int get globalCardCount => _globalCardCount;
  int get globalReviewCount => _globalReviewCount;
  int get globalUpcomingReviewsCount => _globalUpcomingReviewsCount;

  // --- Méthodes de Chargement ---
  Future<void> loadStatsForDeck(int deckId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charger les données de performance
      _reviewStatsForDeck = await _statsDao.getStatsForDeck(deckId);
      _performanceDistributionForDeck =
          await _statsDao.getPerformanceDistribution(deckId);
      // _dailyStatsForDeck = await _statsDao.getDailyStats(deckId); // Keep original for now if used elsewhere
      _averagePerformanceForDeck =
          await _statsDao.getAverageDeckPerformance(deckId);
      _cardsInDeck = await _cardsDao.getCardCountForDeck(deckId);
      _upcomingReviewsForDeck = await _calculateUpcomingReviews(deckId);
      _easeFactorDistributionForDeck =
          await _cardsDao.getEaseFactorDistribution();

      // Load and process aggregated daily stats
      final dailyStatsMaps = await _statsDao.getDailyStats(deckId);
      _aggregatedReviewStatsByDay = dailyStatsMaps
          .map((map) => DailyAggregatedStats.fromMap(map))
          .toList();
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques du paquet: $e';
      debugPrint(_error);
      _resetDeckStats(); // Réinitialiser en cas d'erreur
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadGlobalStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _globalDeckCount = await _decksDao.getTotalDeckCount();
      _globalCardCount = await _cardsDao.getTotalCardCount();
      _globalReviewCount = await _statsDao.getTotalReviewCount();

      // Calculer le nombre total de révisions à venir (tous decks confondus)
      final upcomingMap = await _calculateUpcomingReviews(null);
      _globalUpcomingReviewsCount =
          upcomingMap.values.fold(0, (sum, count) => sum + count);

      // Réinitialiser les stats par paquet si on passe en mode global
      _resetDeckStats();
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques globales: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Méthodes Privées ---
  void _resetDeckStats() {
    _cardsInDeck = 0;
    _reviewStatsForDeck = [];
    _performanceDistributionForDeck = {};
    _dailyStatsForDeck = [];
    _averagePerformanceForDeck = 0.0;
    _upcomingReviewsForDeck = {};
    _easeFactorDistributionForDeck = {};
    _aggregatedReviewStatsByDay = []; // Reset the new list
  }

  Future<Map<String, int>> _calculateUpcomingReviews(int? deckId) async {
    final cards = deckId == null
        ? await _cardsDao.getAllCards()
        : await _cardsDao.getCardsForDeck(deckId);

    final Map<String, int> upcoming = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // final formatter = DateFormat('dd/MM'); // Removed unused local variable

    for (final card in cards) {
      if (card.interval > 0 && card.lastReviewed != null) {
        final lastReviewedNonNull = card.lastReviewed!;
        final lastReviewedDay = DateTime(lastReviewedNonNull.year,
            lastReviewedNonNull.month, lastReviewedNonNull.day);
        final dueDate = lastReviewedDay.add(Duration(days: card.interval));

        if (dueDate.isAfter(today)) {
          final daysUntilDue = dueDate.difference(today).inDays;
          String label;
          if (daysUntilDue == 1) {
            label = 'Demain';
          } else if (daysUntilDue <= 7) {
            label = 'Ds ${daysUntilDue}j'; // Dans X jours
          } else if (daysUntilDue <= 14) {
            label = '> 1 sem';
          } else if (daysUntilDue <= 30) {
            label = '> 2 sem';
          } else {
            label = '> 1 mois';
          }
          // Alternative: afficher la date
          // label = formatter.format(dueDate);

          upcoming[label] = (upcoming[label] ?? 0) + 1;
        }
      }
    }
    // Trier par date implicite (pas parfait, mais regroupe par labels courants)
    final sortedKeys = upcoming.keys.toList()
      ..sort((a, b) {
        // Logique de tri basique pour les labels définis
        const order = {
          'Demain': 1,
          'Ds 2j': 2,
          'Ds 3j': 3,
          'Ds 4j': 4,
          'Ds 5j': 5,
          'Ds 6j': 6,
          'Ds 7j': 7,
          '> 1 sem': 8,
          '> 2 sem': 9,
          '> 1 mois': 10,
        };
        return (order[a] ?? 99).compareTo(order[b] ?? 99);
      });

    return Map.fromEntries(sortedKeys.map((k) => MapEntry(k, upcoming[k]!)));
  }

  // --- Méthodes d'action (gardées pour compatibilité tests/potentiel futur) ---
  Future<void> addReviewStat(
    int cardId,
    int performanceRating,
    int timeSpentMs,
  ) async {
    try {
      final stat = ReviewStatsCompanion(
        cardId: Value(cardId),
        reviewDate: Value(DateTime.now()),
        performanceRating: Value(performanceRating),
        timeSpentMs: Value(timeSpentMs),
      );

      await _statsDao.addStats(stat);

      // Noter que nous ne rechargeons pas les statistiques ici,
      // car cela serait inefficace lors d'une session de révision
    } catch (e) {
      _error = 'Erreur lors de l\'ajout de la statistique: $e';
      debugPrint(_error);
    }
  }

  // Charger les statistiques pour une période
  Future<void> loadStatsForPeriod(DateTime startDate, DateTime endDate,
      {int? deckId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviewStatsForDeck =
          await _statsDao.getStatsForPeriod(startDate, endDate, deckId: deckId);

      // Si un deckId est fourni, charger également les autres statistiques
      if (deckId != null) {
        _performanceDistributionForDeck =
            await _statsDao.getPerformanceDistribution(deckId);
        _dailyStatsForDeck = await _statsDao.getDailyStats(deckId);
        _averagePerformanceForDeck =
            await _statsDao.getAverageDeckPerformance(deckId);
      }
    } catch (e) {
      _error = 'Erreur lors du chargement des statistiques: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculer un score d'efficacité d'étude basé sur les performances et le temps
  double calculateStudyEfficiency(int deckId) {
    if (_reviewStatsForDeck.isEmpty) {
      return 0.0;
    }

    // Formule simplifiée: moyenne des performances / (temps moyen en secondes / 10)
    final totalPerformance = _reviewStatsForDeck.fold<int>(
        0, (sum, stat) => sum + stat.performanceRating.round());
    final totalTime =
        _reviewStatsForDeck.fold<int>(0, (sum, stat) => sum + stat.timeSpentMs);

    final avgPerformance = totalPerformance / _reviewStatsForDeck.length;
    final avgTimeSeconds = (totalTime / _reviewStatsForDeck.length) / 1000;

    if (avgTimeSeconds <= 0) {
      return 0.0;
    }

    return avgPerformance / (avgTimeSeconds / 10);
  }

  double get averageDeckPerformance => _averagePerformanceForDeck;

  // Ajouté pour compatibilité avec les tests et l'UI
  Future<List<Map<String, dynamic>>> getStatsByPeriod(
      int deckId, DateTime start, DateTime end) async {
    return await _statsDao.getDailyStats(deckId);
  }

  // Ajouté pour compatibilité avec les tests
  Future<void> recordCardReview(
      int cardId, int performanceRating, int timeSpentMs) async {
    await addReviewStat(cardId, performanceRating, timeSpentMs);
  }

  int getTotalReviews() {
    return dailyStats.fold<int>(
        0, (sum, stat) => sum + (stat['review_count'] as int));
  }
}
