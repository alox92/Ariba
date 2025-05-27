import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/card_repository.dart';
import 'package:flashcards_app/domain/usecases/usecase.dart';

// Add Card Use Case
class AddCardUseCase extends UseCase<Card, AddCardParams> {
  final CardRepository repository;

  AddCardUseCase(this.repository);

  @override
  Future<Either<Failure, Card>> call(AddCardParams params) async {
    // Validation
    if (params.frontText.trim().isEmpty) {
      return Left(ValidationFailure('Le recto de la carte ne peut pas être vide'));
    }
    if (params.backText.trim().isEmpty) {
      return Left(ValidationFailure('Le verso de la carte ne peut pas être vide'));
    }

    final card = Card(
      id: 0, // Sera généré par la base de données
      deckId: params.deckId,
      frontText: params.frontText.trim(),
      backText: params.backText.trim(),
      frontImagePath: params.frontImagePath,
      backImagePath: params.backImagePath,
      frontAudioPath: params.frontAudioPath,
      backAudioPath: params.backAudioPath,
      tags: params.tags,
      difficulty: 0,
      easinessFactor: 2.5, // Valeur par défaut pour l'algorithme SM-2
      intervalDays: 1,
      repetitions: 0,
      reviewCount: 0,
      lastReviewed: null,
      nextReviewDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.addCard(card);
  }
}

class AddCardParams {
  final int deckId;
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final String? frontAudioPath;
  final String? backAudioPath;
  final String? tags;

  AddCardParams({
    required this.deckId,
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    this.frontAudioPath,
    this.backAudioPath,
    this.tags,
  });
}

// Update Card Use Case
class UpdateCardUseCase extends UseCase<Card, UpdateCardParams> {
  final CardRepository repository;

  UpdateCardUseCase(this.repository);

  @override
  Future<Either<Failure, Card>> call(UpdateCardParams params) async {
    // Validation
    if (params.frontText.trim().isEmpty) {
      return Left(ValidationFailure('Le recto de la carte ne peut pas être vide'));
    }
    if (params.backText.trim().isEmpty) {
      return Left(ValidationFailure('Le verso de la carte ne peut pas être vide'));
    }

    final updatedCard = params.card.copyWith(
      frontText: params.frontText.trim(),
      backText: params.backText.trim(),
      frontImagePath: params.frontImagePath,
      backImagePath: params.backImagePath,
      frontAudioPath: params.frontAudioPath,
      backAudioPath: params.backAudioPath,
      tags: params.tags,
      updatedAt: DateTime.now(),
    );

    return await repository.updateCard(updatedCard);
  }
}

class UpdateCardParams {
  final Card card;
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final String? frontAudioPath;
  final String? backAudioPath;
  final String? tags;

  UpdateCardParams({
    required this.card,
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    this.frontAudioPath,
    this.backAudioPath,
    this.tags,
  });
}

// Delete Card Use Case
class DeleteCardUseCase extends UseCase<Unit, int> {
  final CardRepository repository;

  DeleteCardUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int cardId) async {
    if (cardId <= 0) {
      return Left(ValidationFailure('L\'ID de la carte doit être valide'));
    }

    return await repository.deleteCard(cardId);
  }
}

// Get Cards by Deck Use Case
class GetCardsByDeckUseCase extends StreamUseCase<List<Card>, int> {
  final CardRepository repository;

  GetCardsByDeckUseCase(this.repository);

  @override
  Stream<Either<Failure, List<Card>>> call(int deckId) {
    if (deckId <= 0) {
      return Stream.value(Left(ValidationFailure('L\'ID du deck doit être valide')));
    }

    return repository.watchCardsByDeck(deckId);
  }
}

// Get Cards Due for Review Use Case
class GetCardsDueForReviewUseCase extends StreamUseCase<List<Card>, int> {
  final CardRepository repository;

  GetCardsDueForReviewUseCase(this.repository);

  @override
  Stream<Either<Failure, List<Card>>> call(int deckId) {
    if (deckId <= 0) {
      return Stream.value(Left(ValidationFailure('L\'ID du deck doit être valide')));
    }

    return repository.watchCardsDueForReview(deckId);
  }
}

// Get Card Use Case
class GetCardUseCase extends UseCase<Card, int> {
  final CardRepository repository;

  GetCardUseCase(this.repository);

  @override
  Future<Either<Failure, Card>> call(int cardId) async {
    if (cardId <= 0) {
      return Left(ValidationFailure('L\'ID de la carte doit être valide'));
    }

    return await repository.getCard(cardId);
  }
}
