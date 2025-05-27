part of 'package:flashcards_app/data/database.dart';

@DriftAccessor(tables: [CardEntity])
class CardsDao extends DatabaseAccessor<Database> with _$CardsDaoMixin {
  CardsDao(super.db);

  // Fonctions de base CRUD (Create, Read, Update, Delete)
  Future<List<CardEntityData>> getAllCards() => select(cardEntity).get();

  Future<List<CardEntityData>> getCardsForDeck(int deckId) {
    return (select(cardEntity)..where((c) => c.deckId.equals(deckId))).get();
  }

  // Méthode pour observer les cartes d'un deck spécifique (stream)
  Stream<List<CardEntityData>> watchCardsForDeck(int deckId) {
    return (select(cardEntity)..where((c) => c.deckId.equals(deckId))).watch();
  }

  // Méthode pour obtenir le nombre de cartes dans un deck
  Future<int> getCardCountForDeck(int deckId) async {
    final countExp = cardEntity.id.count();
    final query = selectOnly(cardEntity)
      ..where(cardEntity.deckId.equals(deckId))
      ..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  // Méthode pour obtenir le nombre total de cartes
  Future<int> getTotalCardCount() async {
    final countExp = cardEntity.id.count();
    final query = selectOnly(cardEntity)..addColumns([countExp]);
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }

  // Méthode pour obtenir la distribution des facteurs de facilité
  Future<Map<String, int>> getEaseFactorDistribution() async {
    final cards = await select(cardEntity).get();
    final distribution = <String, int>{};

    for (final card in cards) {
      final easeFactor = card.easeFactor;
      final range = _getEaseFactorRange(easeFactor);
      distribution[range] = (distribution[range] ?? 0) + 1;
    }

    return distribution;
  }

  // Fonction utilitaire pour la distribution des facteurs de facilité
  String _getEaseFactorRange(double easeFactor) {
    if (easeFactor < 1.5) {
      return '< 1.5';
    }
    if (easeFactor < 2.0) {
      return '1.5 - 2.0';
    }
    if (easeFactor < 2.5) {
      return '2.0 - 2.5';
    }
    if (easeFactor < 3.0) {
      return '2.5 - 3.0';
    }
    return '≥ 3.0';
  }

  Future<CardEntityData?> getCardById(int id) {
    return (select(cardEntity)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  // Méthode pour ajouter une nouvelle carte
  Future<int> addCard(CardEntityCompanion cardCompanion) {
    return into(cardEntity).insert(cardCompanion);
  }

  // Méthode pour mettre à jour une carte existante
  Future<bool> updateCard(CardEntityCompanion cardCompanion) {
    return update(cardEntity).replace(cardCompanion);
  }

  Future<int> deleteCard(int id) =>
      (delete(cardEntity)..where((c) => c.id.equals(id))).go();

  Future<void> deleteCardsForDeck(int deckId) {
    return (delete(cardEntity)..where((c) => c.deckId.equals(deckId))).go();
  }

  // Par exemple, pour la révision :
  // Future<List<CardEntityData>> getDueCardsForDeck(int deckId, DateTime now) {
  //   return (select(cardEntity)
  //         ..where((c) => c.deckId.equals(deckId))
  //         ..where((c) => c.lastReviewed.isSmallerThanValue(now))) // Exemple simpliste
  //       .get();
  // }
}
