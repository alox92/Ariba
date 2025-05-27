import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/deck_repository.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';

import 'deck_usecases_test.mocks.dart';

@GenerateMocks([DeckRepository])
void main() {
  late MockDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockDeckRepository();
  });

  group('DeckUseCases Tests', () {
    group('GetDecksUseCase', () {
      late GetDecksUseCase useCase;

      setUp(() {
        useCase = GetDecksUseCase(mockRepository);
      });

      test('should return stream of decks from repository', () async {
        // Arrange
        final decks = [          Deck(
            id: 1,
            name: 'Test Deck 1',
            description: 'Description 1',
            cardCount: 5,
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 2),
          ),
          Deck(
            id: 2,
            name: 'Test Deck 2',
            description: 'Description 2',
            cardCount: 3,
            createdAt: DateTime(2023, 2, 1),
            updatedAt: DateTime(2023, 2, 2),
          ),
        ];

        when(mockRepository.watchDecks())
            .thenAnswer((_) => Stream.value(Right(decks)));        // Act
        final result = useCase.call();

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
        
        final returnedDecks = actualResult.fold((l) => null, (r) => r);
        expect(returnedDecks, equals(decks));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final failure = DatabaseFailure('Database error');
        when(mockRepository.watchDecks())
            .thenAnswer((_) => Stream.value(Left(failure)));        // Act
        final result = useCase.call();

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final returnedFailure = actualResult.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('GetDeckByIdUseCase', () {
      late GetDeckByIdUseCase useCase;

      setUp(() {
        useCase = GetDeckByIdUseCase(mockRepository);
      });

      test('should return deck when valid id is provided', () async {
        // Arrange
        const deckId = 1;        final deck = Deck(
          id: deckId,
          name: 'Test Deck',
          description: 'Test Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        when(mockRepository.getDeckById(deckId))
            .thenAnswer((_) async => Right(deck));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final returnedDeck = result.fold((l) => null, (r) => r);
        expect(returnedDeck, equals(deck));
        
        verify(mockRepository.getDeckById(deckId)).called(1);
      });

      test('should return ValidationFailure when invalid id is provided', () async {
        // Arrange
        const invalidId = 0;

        // Act
        final result = await useCase.call(invalidId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('ID du deck invalide'));
        
        verifyNever(mockRepository.getDeckById(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        final failure = DatabaseFailure('Deck not found');
        when(mockRepository.getDeckById(deckId))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('AddDeckUseCase', () {
      late AddDeckUseCase useCase;

      setUp(() {
        useCase = AddDeckUseCase(mockRepository);
      });

      test('should add deck when valid params are provided', () async {
        // Arrange
        final params = AddDeckParams(
          name: 'New Deck',
          description: 'New Description',
        );        final createdDeck = Deck(
          id: 1,
          name: 'New Deck',
          description: 'New Description',
          cardCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockRepository.addDeck(any))
            .thenAnswer((_) async => Right(createdDeck));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isRight(), true);
        
        final returnedDeck = result.fold((l) => null, (r) => r);
        expect(returnedDeck, equals(createdDeck));
        
        verify(mockRepository.addDeck(any)).called(1);
      });

      test('should return ValidationFailure when name is empty', () async {
        // Arrange
        final params = AddDeckParams(
          name: '',
          description: 'Description',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le nom du deck ne peut pas être vide'));
        
        verifyNever(mockRepository.addDeck(any));
      });

      test('should return ValidationFailure when name is too long', () async {
        // Arrange
        final params = AddDeckParams(
          name: 'a' * 101, // 101 characters
          description: 'Description',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('100 caractères'));
        
        verifyNever(mockRepository.addDeck(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final params = AddDeckParams(
          name: 'New Deck',
          description: 'New Description',
        );

        final failure = DatabaseFailure('Database error');
        when(mockRepository.addDeck(any))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('UpdateDeckUseCase', () {
      late UpdateDeckUseCase useCase;

      setUp(() {
        useCase = UpdateDeckUseCase(mockRepository);
      });      test('should update deck when valid deck is provided', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        when(mockRepository.updateDeck(any))
            .thenAnswer((_) async => Right(deck));

        // Act
        final result = await useCase.call(deck);

        // Assert
        expect(result.isRight(), true);
        
        final returnedDeck = result.fold((l) => null, (r) => r);
        expect(returnedDeck!.name, 'Updated Deck');
        expect(returnedDeck.updatedAt, isA<DateTime>());
        
        verify(mockRepository.updateDeck(any)).called(1);
      });      test('should return ValidationFailure when deck id is invalid', () async {
        // Arrange
        final deck = Deck(
          id: 0, // Invalid ID
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        // Act
        final result = await useCase.call(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('ID du deck invalide'));
        
        verifyNever(mockRepository.updateDeck(any));
      });      test('should return ValidationFailure when deck name is empty', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: '', // Empty name
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        // Act
        final result = await useCase.call(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le nom du deck ne peut pas être vide'));
        
        verifyNever(mockRepository.updateDeck(any));
      });      test('should return ValidationFailure when deck name is too long', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'a' * 101, // Too long
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        // Act
        final result = await useCase.call(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('100 caractères'));
        
        verifyNever(mockRepository.updateDeck(any));
      });      test('should return failure when repository fails', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 2),
        );

        final failure = DatabaseFailure('Update failed');
        when(mockRepository.updateDeck(any))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('DeleteDeckUseCase', () {
      late DeleteDeckUseCase useCase;

      setUp(() {
        useCase = DeleteDeckUseCase(mockRepository);
      });

      test('should delete deck when valid id is provided', () async {
        // Arrange
        const deckId = 1;
        when(mockRepository.deleteDeck(deckId))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final returnedUnit = result.fold((l) => null, (r) => r);
        expect(returnedUnit, equals(unit));
        
        verify(mockRepository.deleteDeck(deckId)).called(1);
      });

      test('should return ValidationFailure when invalid id is provided', () async {
        // Arrange
        const invalidId = 0;

        // Act
        final result = await useCase.call(invalidId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('ID du deck invalide'));
        
        verifyNever(mockRepository.deleteDeck(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        final failure = DatabaseFailure('Delete failed');
        when(mockRepository.deleteDeck(deckId))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('UpdateDeckCardCountUseCase', () {
      late UpdateDeckCardCountUseCase useCase;

      setUp(() {
        useCase = UpdateDeckCardCountUseCase(mockRepository);
      });

      test('should update card count when valid id is provided', () async {
        // Arrange
        const deckId = 1;
        when(mockRepository.updateCardCount(deckId))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final returnedUnit = result.fold((l) => null, (r) => r);
        expect(returnedUnit, equals(unit));
        
        verify(mockRepository.updateCardCount(deckId)).called(1);
      });

      test('should return ValidationFailure when invalid id is provided', () async {
        // Arrange
        const invalidId = 0;

        // Act
        final result = await useCase.call(invalidId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('ID du deck invalide'));
        
        verifyNever(mockRepository.updateCardCount(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        final failure = DatabaseFailure('Update failed');
        when(mockRepository.updateCardCount(deckId))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });
  });
}
