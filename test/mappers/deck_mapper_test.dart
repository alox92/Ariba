import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/mappers/deck_mapper.dart';

void main() {
  test('DeckEntityData toDomain should work', () {
    final deckData = DeckEntityData(
      id: 1,
      name: 'Test Deck',
      description: 'Test Description',
      cardCount: 5,
      createdAt: DateTime(2023),
      lastAccessed: DateTime(2023, 1, 3),
    );

    final deck = deckData.toDomain();

    expect(deck.id, 1);
    expect(deck.name, 'Test Deck');
    expect(deck.description, 'Test Description');
    expect(deck.cardCount, 5);
    expect(deck.createdAt, DateTime(2023));
    expect(deck.updatedAt, DateTime(2023, 1, 3));
  });
}
