import 'package:dartz/dartz.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/mappers/deck_mapper.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/deck_repository.dart';

class DeckRepositoryImpl implements DeckRepository {
  final DecksDao _decksDao;

  DeckRepositoryImpl(this._decksDao);

  @override
  Stream<Either<Failure, List<Deck>>> watchDecks() {
    try {
      return _decksDao.watchAllDecks().map((deckDataList) {
        try {
          final decks = deckDataList.map((deckData) => deckData.toDomain()).toList();
          return Right<Failure, List<Deck>>(decks);
        } catch (e) {
          return Left<Failure, List<Deck>>(DatabaseFailure('Erreur lors du mapping des decks: ${e.toString()}'));
        }
      });
    } catch (e) {
      return Stream.value(Left(DatabaseFailure('Erreur lors de la récupération des decks: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, Deck>> getDeckById(int id) async {
    try {
      final deckData = await _decksDao.getDeckById(id);
      return Right(deckData.toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la récupération du deck: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Deck>> addDeck(Deck deck) async {
    try {
      final deckCompanion = deck.toCompanion();
      final deckId = await _decksDao.addDeck(deckCompanion);
      
      // Récupérer le deck créé avec l'ID généré
      final createdDeckData = await _decksDao.getDeckById(deckId);
      return Right(createdDeckData.toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de l\'ajout du deck: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Deck>> updateDeck(Deck deck) async {
    try {
      final deckCompanion = deck.toCompanion();
      final success = await _decksDao.updateDeck(deckCompanion);
      
      if (success) {
        final updatedDeckData = await _decksDao.getDeckById(deck.id);
        return Right(updatedDeckData.toDomain());
      } else {
        return Left(DatabaseFailure('Échec de la mise à jour du deck'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la mise à jour du deck: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteDeck(int deckId) async {
    try {
      final deletedCount = await _decksDao.deleteDeck(deckId);
      
      if (deletedCount > 0) {
        return const Right(unit);
      } else {
        return Left(DatabaseFailure('Aucun deck trouvé avec l\'ID: $deckId'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la suppression du deck: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCardCount(int deckId) async {
    try {
      await _decksDao.updateCardCount(deckId);
      return const Right(unit);
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la mise à jour du compteur de cartes: ${e.toString()}'));
    }
  }
}
