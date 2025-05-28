import 'package:dartz/dartz.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/mappers/card_mapper.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final CardsDao _cardsDao;

  CardRepositoryImpl(this._cardsDao);

  @override
  Stream<Either<Failure, List<Card>>> watchCardsByDeck(int deckId) {
    try {
      return _cardsDao.watchCardsForDeck(deckId).map((cardDataList) {
        try {
          final cards = cardDataList.map((cardData) => cardData.toDomain()).toList();
          return Right<Failure, List<Card>>(cards);
        } catch (e) {
          return Left<Failure, List<Card>>(DatabaseFailure('Erreur lors du mapping des cartes: ${e.toString()}'));
        }
      });
    } catch (e) {
      return Stream.value(Left(DatabaseFailure('Erreur lors de la récupération des cartes: ${e.toString()}')));
    }
  }

  @override
  Stream<Either<Failure, List<Card>>> watchCardsDueForReview(int deckId) {
    try {
      final now = DateTime.now();
      return _cardsDao.watchCardsForDeck(deckId).map((cardDataList) {
        try {          final dueCards = cardDataList
              .map((cardData) => cardData.toDomain())
              .where((card) => card.nextReviewDate != null && (card.nextReviewDate!.isBefore(now) || card.nextReviewDate!.isAtSameMomentAs(now)))
              .toList();
          return Right<Failure, List<Card>>(dueCards);
        } catch (e) {
          return Left<Failure, List<Card>>(DatabaseFailure('Erreur lors du mapping des cartes dues: ${e.toString()}'));
        }
      });    } catch (e) {
      return Stream.value(Left(DatabaseFailure('Erreur lors de la récupération des cartes dues: ${e.toString()}')));
    }
  }

  @override
  Future<Either<Failure, List<Card>>> getCardsForDeck(int deckId) async {
    try {
      final cardDataList = await _cardsDao.getCardsForDeck(deckId);
      final cards = cardDataList.map((cardData) => cardData.toDomain()).toList();
      return Right(cards);
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la récupération des cartes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Card>> getCard(int cardId) async {
    try {
      final cardData = await _cardsDao.getCardById(cardId);
      if (cardData == null) {
        return Left(DatabaseFailure('Carte non trouvée avec l\'ID: $cardId'));
      }
      return Right(cardData.toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la récupération de la carte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Card>> addCard(Card card) async {
    try {
      final cardCompanion = card.toCompanion();
      final cardId = await _cardsDao.addCard(cardCompanion);
      
      // Récupérer la carte créée avec l'ID généré
      final createdCardData = await _cardsDao.getCardById(cardId);
      if (createdCardData == null) {
        return const Left(DatabaseFailure('Erreur lors de la récupération de la carte créée'));
      }
      return Right(createdCardData.toDomain());
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de l\'ajout de la carte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Card>> updateCard(Card card) async {
    try {
      final cardCompanion = card.toCompanion();
      final success = await _cardsDao.updateCard(cardCompanion);
      
      if (success) {
        final updatedCardData = await _cardsDao.getCardById(card.id);
        if (updatedCardData == null) {
          return const Left(DatabaseFailure('Erreur lors de la récupération de la carte mise à jour'));
        }
        return Right(updatedCardData.toDomain());
      } else {
        return const Left(DatabaseFailure('Échec de la mise à jour de la carte'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la mise à jour de la carte: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCard(int cardId) async {
    try {
      final deletedCount = await _cardsDao.deleteCard(cardId);
      
      if (deletedCount > 0) {
        return const Right(unit);
      } else {
        return Left(DatabaseFailure('Aucune carte trouvée avec l\'ID: $cardId'));
      }
    } catch (e) {
      return Left(DatabaseFailure('Erreur lors de la suppression de la carte: ${e.toString()}'));
    }
  }
}
