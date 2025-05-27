import 'package:flashcards_app/data/database.dart';

/// Entité métier représentant un deck avec ses statistiques
class DeckWithStats {
  final int id;
  final String name;
  final String description;
  final int cardCount;
  final DateTime lastAccessed;
  final DateTime createdAt;
  final int dueTodayCount;
  final double averagePerformance;

  const DeckWithStats({
    required this.id,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.lastAccessed,
    required this.createdAt,
    this.dueTodayCount = 0,
    this.averagePerformance = 0.0,
  });

  /// Créer depuis une entité de données de deck
  factory DeckWithStats.fromDeckEntity(
    DeckEntityData deck, {
    int dueTodayCount = 0,
    double averagePerformance = 0.0,
  }) {
    return DeckWithStats(
      id: deck.id,
      name: deck.name,
      description: deck.description ?? '',
      cardCount: deck.cardCount,
      lastAccessed: deck.lastAccessed,
      createdAt: deck.createdAt,
      dueTodayCount: dueTodayCount,
      averagePerformance: averagePerformance,
    );
  }

  DeckWithStats copyWith({
    int? id,
    String? name,
    String? description,
    int? cardCount,
    DateTime? lastAccessed,
    DateTime? createdAt,
    int? dueTodayCount,
    double? averagePerformance,
  }) {
    return DeckWithStats(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      createdAt: createdAt ?? this.createdAt,
      dueTodayCount: dueTodayCount ?? this.dueTodayCount,
      averagePerformance: averagePerformance ?? this.averagePerformance,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DeckWithStats &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.cardCount == cardCount &&
        other.lastAccessed == lastAccessed &&
        other.createdAt == createdAt &&
        other.dueTodayCount == dueTodayCount &&
        other.averagePerformance == averagePerformance;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      cardCount,
      lastAccessed,
      createdAt,
      dueTodayCount,
      averagePerformance,
    );
  }

  @override
  String toString() {
    return 'DeckWithStats(id: $id, name: $name, description: $description, cardCount: $cardCount, lastAccessed: $lastAccessed, createdAt: $createdAt, dueTodayCount: $dueTodayCount, averagePerformance: $averagePerformance)';
  }
}
