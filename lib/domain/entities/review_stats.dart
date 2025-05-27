enum ReviewResult {
  easy,
  good,
  hard,
  again,
}

class ReviewStats {
  final int id;
  final int cardId;
  final int deckId;
  final ReviewResult result;
  final DateTime reviewedAt;
  final int timeTakenSeconds;

  const ReviewStats({
    required this.id,
    required this.cardId,
    required this.deckId,
    required this.result,
    required this.reviewedAt,
    required this.timeTakenSeconds,
  });

  ReviewStats copyWith({
    int? id,
    int? cardId,
    int? deckId,
    ReviewResult? result,
    DateTime? reviewedAt,
    int? timeTakenSeconds,
  }) {
    return ReviewStats(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      deckId: deckId ?? this.deckId,
      result: result ?? this.result,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is ReviewStats &&
        other.id == id &&
        other.cardId == cardId &&
        other.deckId == deckId &&
        other.result == result &&
        other.reviewedAt == reviewedAt &&
        other.timeTakenSeconds == timeTakenSeconds;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      cardId,
      deckId,
      result,
      reviewedAt,
      timeTakenSeconds,
    );
  }

  @override
  String toString() {
    return 'ReviewStats(id: $id, cardId: $cardId, deckId: $deckId, result: $result, reviewedAt: $reviewedAt, timeTakenSeconds: $timeTakenSeconds)';
  }
}
