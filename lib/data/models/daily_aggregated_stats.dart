class DailyAggregatedStats {
  final DateTime date;
  final int reviewCount;
  final double averagePerformance;

  DailyAggregatedStats({
    required this.date,
    required this.reviewCount,
    required this.averagePerformance,
  });

  factory DailyAggregatedStats.fromMap(Map<String, dynamic> map) {
    return DailyAggregatedStats(
      date: DateTime.parse(
          map['day'] as String), // 'day' is a string like 'YYYY-MM-DD'
      reviewCount: map['review_count'] as int,
      averagePerformance: (map['avg_performance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
