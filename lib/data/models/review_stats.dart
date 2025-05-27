// FICHIER DÉPRÉCIÉ - Les définitions de tables sont maintenant dans lib/data/tables/
// Ce fichier sera supprimé car il crée des conflits avec les classes générées par Drift
// Les vraies définitions sont dans:
// - lib/data/tables/review_stats.dart pour ReviewStats
// - lib/data/database.g.dart pour les classes générées automatiquement

class ReviewStatsData {
  final int id;
  final int cardId;
  final DateTime date;
  final double performanceRating;
  final int timeSpentMs;

  ReviewStatsData({
    required this.id,
    required this.cardId,
    required this.date,
    required this.performanceRating,
    required this.timeSpentMs,
  });
}
