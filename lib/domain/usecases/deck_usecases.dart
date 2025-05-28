import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/deck_repository.dart';
import 'package:flashcards_app/domain/usecases/usecase.dart';

class GetDecksUseCase extends NoParamsStreamUseCase<List<Deck>> {
  final DeckRepository repository;

  GetDecksUseCase(this.repository);

  @override
  Stream<Either<Failure, List<Deck>>> call() {
    return repository.watchDecks();
  }
}

class GetDeckByIdUseCase extends UseCase<Deck, int> {
  final DeckRepository repository;

  GetDeckByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Deck>> call(int id) {
    if (id <= 0) {
      return Future.value(const Left(ValidationFailure('ID du deck invalide')));
    }
    return repository.getDeckById(id);
  }
}

class AddDeckParams {
  final String name;
  final String description;

  AddDeckParams({
    required this.name,
    required this.description,
  });
}

class AddDeckUseCase extends UseCase<Deck, AddDeckParams> {
  final DeckRepository repository;

  AddDeckUseCase(this.repository);

  @override
  Future<Either<Failure, Deck>> call(AddDeckParams params) {
    // Validation
    if (params.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Le nom du deck ne peut pas être vide')));
    }
    
    if (params.name.length > 100) {
      return Future.value(const Left(ValidationFailure('Le nom du deck ne peut pas dépasser 100 caractères')));
    }

    // Créer l'entité Deck
    final deck = Deck(
      id: 0, // Sera généré par la base de données
      name: params.name.trim(),
      description: params.description.trim(),
      cardCount: 0,
      createdAt: DateTime.now(),
    );

    return repository.addDeck(deck);
  }
}

class UpdateDeckUseCase extends UseCase<Deck, Deck> {
  final DeckRepository repository;

  UpdateDeckUseCase(this.repository);

  @override
  Future<Either<Failure, Deck>> call(Deck deck) {
    // Validation
    if (deck.id <= 0) {
      return Future.value(const Left(ValidationFailure('ID du deck invalide')));
    }
    
    if (deck.name.trim().isEmpty) {
      return Future.value(const Left(ValidationFailure('Le nom du deck ne peut pas être vide')));
    }
    
    if (deck.name.length > 100) {
      return Future.value(const Left(ValidationFailure('Le nom du deck ne peut pas dépasser 100 caractères')));
    }

    // Mettre à jour avec le timestamp
    final updatedDeck = deck.copyWith(
      updatedAt: DateTime.now(),
    );

    return repository.updateDeck(updatedDeck);
  }
}

class DeleteDeckUseCase extends UseCase<Unit, int> {
  final DeckRepository repository;

  DeleteDeckUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int deckId) {
    if (deckId <= 0) {
      return Future.value(const Left(ValidationFailure('ID du deck invalide')));
    }
    return repository.deleteDeck(deckId);
  }
}

class UpdateDeckCardCountUseCase extends UseCase<Unit, int> {
  final DeckRepository repository;

  UpdateDeckCardCountUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(int deckId) {
    if (deckId <= 0) {
      return Future.value(const Left(ValidationFailure('ID du deck invalide')));
    }
    return repository.updateCardCount(deckId);
  }
}
