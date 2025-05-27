part of 'package:flashcards_app/data/database.dart';

@DriftAccessor(tables: [ReviewStats, CardEntity])
class StatsDao extends DatabaseAccessor<Database> with _$StatsDaoMixin {
  StatsDao(super.db);

  // Récupérer tous les stats pour une carte spécifique
  Future<List<ReviewStatsData>> getStatsForCard(int cardId) async {
    final result = await (select(reviewStats)
          ..where((stats) => stats.cardId.equals(cardId)))
        .get();
    return result
        .map((driftStat) => ReviewStatsData(
              id: driftStat.id,
              cardId: driftStat.cardId,
              date: driftStat.reviewDate,
              performanceRating: driftStat.performanceRating.toDouble(),
              timeSpentMs: driftStat.timeSpentMs,
            ))
        .toList();
  }

  // Récupérer les stats pour un paquet spécifique
  Future<List<ReviewStatsData>> getStatsForDeck(int deckId) async {
    final query = select(reviewStats).join([
      innerJoin(cardEntity, cardEntity.id.equalsExp(reviewStats.cardId)),
    ])
      ..where(cardEntity.deckId.equals(deckId));

    final rows = await query.get();
    return rows.map((row) {
      final driftStat = row.readTable(reviewStats);
      return ReviewStatsData(
        id: driftStat.id,
        cardId: driftStat.cardId,
        date: driftStat.reviewDate,
        performanceRating: driftStat.performanceRating.toDouble(),
        timeSpentMs: driftStat.timeSpentMs,
      );
    }).toList();
  }

  // Récupérer les stats pour une période spécifique
  Future<List<ReviewStatsData>> getStatsForPeriod(
      DateTime startDate, DateTime endDate,
      {int? deckId}) async {
    var query = select(reviewStats).join([
      innerJoin(cardEntity, cardEntity.id.equalsExp(reviewStats.cardId)),
    ])
      ..where(reviewStats.reviewDate.isBetweenValues(startDate, endDate));

    if (deckId != null) {
      query = query..where(cardEntity.deckId.equals(deckId));
    }

    final rows = await query.get();
    return rows.map((row) {
      final driftStat = row.readTable(reviewStats);
      return ReviewStatsData(
        id: driftStat.id,
        cardId: driftStat.cardId,
        date: driftStat.reviewDate,
        performanceRating: driftStat.performanceRating.toDouble(),
        timeSpentMs: driftStat.timeSpentMs,
      );
    }).toList();
  }

  // Ajouter une nouvelle entrée de statistiques
  Future<int> addStats(ReviewStatsCompanion statsData) {
    return into(reviewStats).insert(statsData);
  }

  // Supprimer les stats pour une carte
  Future<int> deleteStatsForCard(int cardId) {
    return (delete(reviewStats)..where((s) => s.cardId.equals(cardId))).go();
  }

  // Supprimer les stats pour un paquet
  Future<int> deleteStatsForDeck(int deckId) async {
    // D'abord, obtenir tous les IDs de cartes du paquet
    final cardIds = await (select(cardEntity)
          ..where((card) => card.deckId.equals(deckId)))
        .map((card) => card.id)
        .get();

    if (cardIds.isEmpty) {
      return 0;
    }

    // Ensuite, supprimer les stats pour ces cartes
    return (delete(reviewStats)..where((s) => s.cardId.isIn(cardIds))).go();
  }

  // Obtenir la performance moyenne pour un paquet
  Future<double> getAverageDeckPerformance(int deckId) async {
    final statsList = await getStatsForDeck(deckId);
    if (statsList.isEmpty) {
      return 0.0;
    }
    final totalRating = statsList.fold<double>(
        0.0, (sum, stat) => sum + stat.performanceRating);
    return totalRating / statsList.length;
  }

  // Obtenir la distribution des performances pour un paquet
  Future<Map<int, int>> getPerformanceDistribution(int deckId) async {
    final statsList = await getStatsForDeck(deckId);

    // Initialiser la distribution avec des zéros
    final distribution = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    // Compter les occurrences de chaque note de performance
    for (final stat in statsList) {
      final rating = stat.performanceRating.round();
      if (rating >= 1 && rating <= 5) {
        distribution[rating] = (distribution[rating] ?? 0) + 1;
      }
    }

    return distribution;
  }

  // Obtenir les statistiques quotidiennes pour un paquet
  Future<List<Map<String, dynamic>>> getDailyStats(int deckId) async {
    // Cette requête SQL personnalisée groupe les stats par jour
    final query = customSelect(
      '''
      SELECT
        date(review_date) as day,
        COUNT(*) as review_count,
        AVG(performance_rating) as avg_performance
      FROM review_stats
      INNER JOIN card_entity ON review_stats.card_id = card_entity.id
      WHERE card_entity.deck_id = ?
      GROUP BY date(review_date)
      ORDER BY day
      ''',
      variables: [Variable.withInt(deckId)],
      readsFrom: {reviewStats, cardEntity},
    );

    final rows = await query.get();
    return rows.map((row) => row.data).toList();
  }

  // Méthode ajoutée
  Future<int> getTotalReviewCount({int? deckId}) async {
    final countExp = reviewStats.id.count();
    final query = selectOnly(reviewStats)..addColumns([countExp]);

    if (deckId != null) {
      query.join(
          [innerJoin(cardEntity, cardEntity.id.equalsExp(reviewStats.cardId))]);
      query.where(cardEntity.deckId.equals(deckId));
    }

    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
