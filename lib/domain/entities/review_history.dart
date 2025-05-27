/// Entité représentant l'historique d'une révision
class ReviewHistory {
  final int id;
  final int cardId;
  final DateTime reviewDate;
  final int quality; // 0-5 selon l'algorithme SM-2
  final double easinessFactor;
  final int intervalDays;
  final int repetitions;
  final Duration responseTime; // Temps de réponse
  final bool wasCorrect;
  
  const ReviewHistory({
    required this.id,
    required this.cardId,
    required this.reviewDate,
    required this.quality,
    required this.easinessFactor,
    required this.intervalDays,
    required this.repetitions,
    required this.responseTime,
    required this.wasCorrect,
  });

  /// Copie avec modifications
  ReviewHistory copyWith({
    int? id,
    int? cardId,
    DateTime? reviewDate,
    int? quality,
    double? easinessFactor,
    int? intervalDays,
    int? repetitions,
    Duration? responseTime,
    bool? wasCorrect,
  }) {
    return ReviewHistory(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      reviewDate: reviewDate ?? this.reviewDate,
      quality: quality ?? this.quality,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      repetitions: repetitions ?? this.repetitions,
      responseTime: responseTime ?? this.responseTime,
      wasCorrect: wasCorrect ?? this.wasCorrect,
    );
  }

  @override  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ReviewHistory &&
        other.id == id &&
        other.cardId == cardId &&
        other.reviewDate == reviewDate &&
        other.quality == quality &&
        other.easinessFactor == easinessFactor &&
        other.intervalDays == intervalDays &&
        other.repetitions == repetitions &&
        other.responseTime == responseTime &&
        other.wasCorrect == wasCorrect;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      cardId,
      reviewDate,
      quality,
      easinessFactor,
      intervalDays,
      repetitions,
      responseTime,
      wasCorrect,
    );
  }

  @override
  String toString() {
    return 'ReviewHistory('
        'id: $id, '
        'cardId: $cardId, '
        'reviewDate: $reviewDate, '
        'quality: $quality, '
        'easinessFactor: $easinessFactor, '
        'intervalDays: $intervalDays, '
        'repetitions: $repetitions, '
        'responseTime: $responseTime, '
        'wasCorrect: $wasCorrect'
        ')';
  }
}
