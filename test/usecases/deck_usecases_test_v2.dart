import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/deck_repository.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';

import 'deck_usecases_test_v2.mocks.dart';

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
      });      test('should return stream of decks from repository', () async {
        // Arrange
        final decks = [
          Deck(
            id: 1,
            name: 'Test Deck 1',
            description: 'Description 1',
            cardCount: 5,
            createdAt: DateTime(2023, 1, 1),
            updatedAt: DateTime(2023, 1, 3),
          ),
          Deck(
            id: 2,
            name: 'Test Deck 2',
            description: 'Description 2',
            cardCount: 3,
            createdAt: DateTime(2023, 2, 1),
            updatedAt: DateTime(2023, 2, 3),
          ),
        ];

        when(mockRepository.watchDecks())
            .thenAnswer((_) => Stream.value(Right(decks)));

        // Act
        final resultStream = useCase();

        // Assert
        await expectLater(
          resultStream,
          emits(isA<Right<Failure, List<Deck>>>()),
        );
        
        verify(mockRepository.watchDecks()).called(1);
      });      test('should return failure when repository fails', () async {
        // Arrange
        const failure = DatabaseFailure('Database error');
        when(mockRepository.watchDecks())
            .thenAnswer((_) => Stream.value(const Left(failure)));

        // Act
        final resultStream = useCase();

        // Assert
        await expectLater(
          resultStream,
          emits(isA<Left<Failure, List<Deck>>>()),
        );
        
        verify(mockRepository.watchDecks()).called(1);
      });
    });

    group('GetDeckByIdUseCase', () {
      late GetDeckByIdUseCase useCase;

      setUp(() {
        useCase = GetDeckByIdUseCase(mockRepository);
      });

      test('should return deck when repository returns success', () async {
        // Arrange
        const deckId = 1;
        final deck = Deck(
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
        final result = await useCase(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final actualDeck = result.fold((l) => null, (r) => r);
        expect(actualDeck, isNotNull);
        expect(actualDeck!.id, deckId);
        expect(actualDeck.name, 'Test Deck');
        
        verify(mockRepository.getDeckById(deckId)).called(1);
      });

      test('should return validation failure for invalid ID', () async {
        // Arrange
        const deckId = 0; // Invalid ID

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'ID du deck invalide');
        
        verifyNever(mockRepository.getDeckById(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        const failure = DatabaseFailure('Deck not found');

        when(mockRepository.getDeckById(deckId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<DatabaseFailure>());
        expect(actualFailure!.message, 'Deck not found');
        
        verify(mockRepository.getDeckById(deckId)).called(1);
      });
    });

    group('AddDeckUseCase', () {
      late AddDeckUseCase useCase;

      setUp(() {
        useCase = AddDeckUseCase(mockRepository);
      });

      test('should return created deck when repository returns success', () async {
        // Arrange
        const deckName = 'New Deck';
        const deckDescription = 'New Description';
        final params = AddDeckParams(name: deckName, description: deckDescription);
        
        final createdDeck = Deck(
          id: 1,
          name: deckName,
          description: deckDescription,
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        when(mockRepository.addDeck(any))
            .thenAnswer((_) async => Right(createdDeck));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isRight(), true);
        
        final actualDeck = result.fold((l) => null, (r) => r);
        expect(actualDeck, isNotNull);
        expect(actualDeck!.name, deckName);
        expect(actualDeck.description, deckDescription);
        expect(actualDeck.cardCount, 0);
        
        verify(mockRepository.addDeck(any)).called(1);
      });

      test('should return validation failure for empty name', () async {
        // Arrange
        const deckName = '';
        const deckDescription = 'Description';
        final params = AddDeckParams(name: deckName, description: deckDescription);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'Le nom du deck ne peut pas être vide');
        
        verifyNever(mockRepository.addDeck(any));
      });

      test('should return validation failure for too long name', () async {
        // Arrange
        final deckName = 'a' * 101; // Too long
        const deckDescription = 'Description';
        final params = AddDeckParams(name: deckName, description: deckDescription);

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'Le nom du deck ne peut pas dépasser 100 caractères');
        
        verifyNever(mockRepository.addDeck(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckName = 'New Deck';
        const deckDescription = 'New Description';
        final params = AddDeckParams(name: deckName, description: deckDescription);
        const failure = DatabaseFailure('Failed to create deck');

        when(mockRepository.addDeck(any))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(params);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<DatabaseFailure>());
        expect(actualFailure!.message, 'Failed to create deck');
        
        verify(mockRepository.addDeck(any)).called(1);
      });
    });

    group('UpdateDeckUseCase', () {
      late UpdateDeckUseCase useCase;

      setUp(() {
        useCase = UpdateDeckUseCase(mockRepository);
      });

      test('should return updated deck when repository returns success', () async {
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
        final result = await useCase(deck);

        // Assert
        expect(result.isRight(), true);
        
        final actualDeck = result.fold((l) => null, (r) => r);
        expect(actualDeck, isNotNull);
        expect(actualDeck!.id, 1);
        expect(actualDeck.name, 'Updated Deck');
        expect(actualDeck.description, 'Updated Description');
        
        verify(mockRepository.updateDeck(any)).called(1);
      });

      test('should return validation failure for invalid ID', () async {
        // Arrange
        final deck = Deck(
          id: 0, // Invalid ID
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
        );

        // Act
        final result = await useCase(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'ID du deck invalide');
        
        verifyNever(mockRepository.updateDeck(any));
      });

      test('should return validation failure for empty name', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: '', // Empty name
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
        );

        // Act
        final result = await useCase(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'Le nom du deck ne peut pas être vide');
        
        verifyNever(mockRepository.updateDeck(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
        );
        const failure = DatabaseFailure('Failed to update deck');

        when(mockRepository.updateDeck(any))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<DatabaseFailure>());
        expect(actualFailure!.message, 'Failed to update deck');
        
        verify(mockRepository.updateDeck(any)).called(1);
      });
    });

    group('DeleteDeckUseCase', () {
      late DeleteDeckUseCase useCase;

      setUp(() {
        useCase = DeleteDeckUseCase(mockRepository);
      });

      test('should return unit when repository returns success', () async {
        // Arrange
        const deckId = 1;

        when(mockRepository.deleteDeck(deckId))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final actualUnit = result.fold((l) => null, (r) => r);
        expect(actualUnit, unit);
        
        verify(mockRepository.deleteDeck(deckId)).called(1);
      });

      test('should return validation failure for invalid ID', () async {
        // Arrange
        const deckId = 0; // Invalid ID

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'ID du deck invalide');
        
        verifyNever(mockRepository.deleteDeck(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        const failure = DatabaseFailure('Failed to delete deck');

        when(mockRepository.deleteDeck(deckId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<DatabaseFailure>());
        expect(actualFailure!.message, 'Failed to delete deck');
        
        verify(mockRepository.deleteDeck(deckId)).called(1);
      });
    });

    group('UpdateDeckCardCountUseCase', () {
      late UpdateDeckCardCountUseCase useCase;

      setUp(() {
        useCase = UpdateDeckCardCountUseCase(mockRepository);
      });

      test('should return unit when repository returns success', () async {
        // Arrange
        const deckId = 1;

        when(mockRepository.updateCardCount(deckId))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final actualUnit = result.fold((l) => null, (r) => r);
        expect(actualUnit, unit);
        
        verify(mockRepository.updateCardCount(deckId)).called(1);
      });

      test('should return validation failure for invalid ID', () async {
        // Arrange
        const deckId = 0; // Invalid ID

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<ValidationFailure>());
        expect(actualFailure!.message, 'ID du deck invalide');
        
        verifyNever(mockRepository.updateCardCount(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        const failure = DatabaseFailure('Failed to update card count');

        when(mockRepository.updateCardCount(deckId))
            .thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final actualFailure = result.fold((l) => l, (r) => null);
        expect(actualFailure, isA<DatabaseFailure>());
        expect(actualFailure!.message, 'Failed to update card count');
        
        verify(mockRepository.updateCardCount(deckId)).called(1);
      });
    });
  });
}
