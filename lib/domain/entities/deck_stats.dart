class DeckStats {
  final int deckId;
  final int totalCards;
  final int newCards;
  final int dueCards;
  final int reviewedToday;
  final double averageEasinessFactor;
  final int longestStreak;
  final DateTime? lastReviewDate;

  const DeckStats({
    required this.deckId,
    required this.totalCards,
    required this.newCards,
    required this.dueCards,
    required this.reviewedToday,
    required this.averageEasinessFactor,
    required this.longestStreak,
    this.lastReviewDate,
  });

  DeckStats copyWith({
    int? deckId,
    int? totalCards,
    int? newCards,
    int? dueCards,
    int? reviewedToday,
    double? averageEasinessFactor,
    int? longestStreak,
    DateTime? lastReviewDate,
  }) {
    return DeckStats(
      deckId: deckId ?? this.deckId,
      totalCards: totalCards ?? this.totalCards,
      newCards: newCards ?? this.newCards,
      dueCards: dueCards ?? this.dueCards,
      reviewedToday: reviewedToday ?? this.reviewedToday,
      averageEasinessFactor: averageEasinessFactor ?? this.averageEasinessFactor,
      longestStreak: longestStreak ?? this.longestStreak,
      lastReviewDate: lastReviewDate ?? this.lastReviewDate,
    );
  }
  @override
  bool operator ==(covariant DeckStats other) {
    if (identical(this, other)) {
      return true;
    }
  
    return
      other.deckId == deckId &&
      other.totalCards == totalCards &&
      other.newCards == newCards &&
      other.dueCards == dueCards &&
      other.reviewedToday == reviewedToday &&
      other.averageEasinessFactor == averageEasinessFactor &&
      other.longestStreak == longestStreak &&
      other.lastReviewDate == lastReviewDate;
  }

  @override
  int get hashCode {
    return deckId.hashCode ^
      totalCards.hashCode ^
      newCards.hashCode ^
      dueCards.hashCode ^
      reviewedToday.hashCode ^
      averageEasinessFactor.hashCode ^
      longestStreak.hashCode ^
      lastReviewDate.hashCode;
  }

  @override
  String toString() {
    return 'DeckStats(deckId: $deckId, totalCards: $totalCards, newCards: $newCards, dueCards: $dueCards, reviewedToday: $reviewedToday, averageEasinessFactor: $averageEasinessFactor, longestStreak: $longestStreak, lastReviewDate: $lastReviewDate)';
  }
}
