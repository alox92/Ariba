import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

abstract class DeckRepository {
  Stream<Either<Failure, List<Deck>>> watchDecks();
  Future<Either<Failure, Deck>> getDeckById(int id);
  Future<Either<Failure, Deck>> addDeck(Deck deck);
  Future<Either<Failure, Deck>> updateDeck(Deck deck);
  Future<Either<Failure, Unit>> deleteDeck(int deckId);
  Future<Either<Failure, Unit>> updateCardCount(int deckId);
}
