class Card {
  final int id;
  final int deckId;
  final String frontText;
  final String backText;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? frontImagePath;
  final String? backImagePath;
  final String? frontAudioPath;
  final String? backAudioPath;
  final String? tags;
  final int difficulty;
  final DateTime? lastReviewed;
  final int reviewCount;
  final double easinessFactor;
  final int repetitions;
  final int intervalDays;
  final DateTime? nextReviewDate;

  const Card({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.createdAt,
    this.updatedAt,
    this.frontImagePath,
    this.backImagePath,
    this.frontAudioPath,
    this.backAudioPath,
    this.tags,
    this.difficulty = 0,
    this.lastReviewed,
    this.reviewCount = 0,
    this.easinessFactor = 2.5,
    this.repetitions = 0,
    this.intervalDays = 0,
    this.nextReviewDate,
  });
  Card copyWith({
    int? id,
    int? deckId,
    String? frontText,
    String? backText,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? frontImagePath,
    String? backImagePath,
    String? frontAudioPath,
    String? backAudioPath,
    String? tags,
    int? difficulty,
    DateTime? lastReviewed,
    int? reviewCount,
    double? easinessFactor,
    int? repetitions,
    int? intervalDays,
    DateTime? nextReviewDate,
  }) {
    return Card(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      frontAudioPath: frontAudioPath ?? this.frontAudioPath,
      backAudioPath: backAudioPath ?? this.backAudioPath,
      tags: tags ?? this.tags,
      difficulty: difficulty ?? this.difficulty,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      reviewCount: reviewCount ?? this.reviewCount,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      repetitions: repetitions ?? this.repetitions,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReviewDate: nextReviewDate ?? this.nextReviewDate,
    );
  }
  bool get hasImages => frontImagePath != null || backImagePath != null;
  bool get hasAudio => frontAudioPath != null || backAudioPath != null;
  bool get hasTags => tags != null && tags!.isNotEmpty;
  bool get isReviewed => lastReviewed != null;
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Card &&
        other.id == id &&
        other.deckId == deckId &&
        other.frontText == frontText &&
        other.backText == backText &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.frontImagePath == frontImagePath &&
        other.backImagePath == backImagePath &&
        other.frontAudioPath == frontAudioPath &&
        other.backAudioPath == backAudioPath &&
        other.tags == tags &&
        other.difficulty == difficulty &&
        other.lastReviewed == lastReviewed &&
        other.reviewCount == reviewCount &&
        other.easinessFactor == easinessFactor &&
        other.repetitions == repetitions &&
        other.intervalDays == intervalDays &&
        other.nextReviewDate == nextReviewDate;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      deckId,
      frontText,
      backText,
      createdAt,
      updatedAt,
      frontImagePath,
      backImagePath,
      frontAudioPath,
      backAudioPath,
      tags,
      difficulty,
      lastReviewed,
      reviewCount,
      easinessFactor,
      repetitions,
      intervalDays,
      nextReviewDate,    );
  }

  /// Getter pour compatibilité avec l'ancien code
  DateTime get nextReview => nextReviewDate ?? DateTime.now();

  @override
  String toString() {
    return 'Card(id: $id, deckId: $deckId, frontText: $frontText, backText: $backText, createdAt: $createdAt, updatedAt: $updatedAt, frontImagePath: $frontImagePath, backImagePath: $backImagePath, frontAudioPath: $frontAudioPath, backAudioPath: $backAudioPath, tags: $tags, difficulty: $difficulty, lastReviewed: $lastReviewed, reviewCount: $reviewCount, easinessFactor: $easinessFactor, repetitions: $repetitions, intervalDays: $intervalDays, nextReviewDate: $nextReviewDate)';
  }
}
