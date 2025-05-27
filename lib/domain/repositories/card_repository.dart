import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

abstract class CardRepository {
  Stream<Either<Failure, List<Card>>> watchCardsByDeck(int deckId);
  Stream<Either<Failure, List<Card>>> watchCardsDueForReview(int deckId);
  Future<Either<Failure, List<Card>>> getCardsForDeck(int deckId);
  Future<Either<Failure, Card>> getCard(int cardId);
  Future<Either<Failure, Card>> addCard(Card card);
  Future<Either<Failure, Card>> updateCard(Card card);
  Future<Either<Failure, Unit>> deleteCard(int cardId);
}
