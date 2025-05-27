class Deck {
  final int id;
  final String name;
  final String description;
  final int cardCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? color;
  final String? icon;

  const Deck({
    required this.id,
    required this.name,
    required this.description,
    required this.cardCount,
    required this.createdAt,
    this.updatedAt,
    this.color,
    this.icon,
  });

  Deck copyWith({
    int? id,
    String? name,
    String? description,
    int? cardCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? color,
    String? icon,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Deck &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.cardCount == cardCount &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.color == color &&
        other.icon == icon;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      cardCount,
      createdAt,
      updatedAt,
      color,
      icon,
    );
  }

  @override
  String toString() {
    return 'Deck(id: $id, name: $name, description: $description, cardCount: $cardCount, createdAt: $createdAt, updatedAt: $updatedAt, color: $color, icon: $icon)';
  }
}
