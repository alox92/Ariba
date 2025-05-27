part of '../database.dart';

@DriftAccessor(tables: [DeckEntity])
class DecksDao extends DatabaseAccessor<Database> with _$DecksDaoMixin {
  DecksDao(super.db);

  // Get all decks (existing method)
  Future<List<DeckEntityData>> getAllDecks() => select(deckEntity).get();

  // Watch all decks (returns a stream for reactive updates)
  Stream<List<DeckEntityData>> watchAllDecks() => select(deckEntity).watch();

  // Get a single deck by ID
  Future<DeckEntityData> getDeckById(int id) {
    return (select(deckEntity)..where((d) => d.id.equals(id))).getSingle();
  }

  // Watch a single deck by ID
  Stream<DeckEntityData?> watchDeckById(int id) =>
      (select(deckEntity)..where((tbl) => tbl.id.equals(id)))
          .watchSingleOrNull();

  // Insert a new deck
  Future<int> addDeck(DeckEntityCompanion deck) {
    return into(deckEntity).insert(deck);
  }

  // Update an existing deck
  Future<bool> updateDeck(DeckEntityCompanion deck) {
    return update(deckEntity).replace(deck);
  }

  // Delete a deck (and its associated cards)
  Future<int> deleteDeck(int id) {
    return transaction(() async {
      // D'abord, supprimer toutes les cartes du deck
      final cardsToDelete = await (db.select(db.cardEntity)
            ..where((c) => c.deckId.equals(id)))
          .get();

      for (final card in cardsToDelete) {
        await db.delete(db.cardEntity).delete(card);
      }

      // Ensuite, supprimer le deck lui-même
      return (delete(deckEntity)..where((d) => d.id.equals(id))).go();
    });
  }

  // Update card count for a specific deck
  Future<void> updateCardCount(int deckId) async {
    final cardCount = await (db.select(db.cardEntity)
          ..where((c) => c.deckId.equals(deckId)))
        .get()
        .then((cards) => cards.length);

    await (update(deckEntity)..where((d) => d.id.equals(deckId)))
        .write(DeckEntityCompanion(cardCount: Value(cardCount)));
  }

  // Méthode ajoutée
  Future<int> getTotalDeckCount() async {
    final countExp = deckEntity.id.count();
    final query = selectOnly(deckEntity)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}
