import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/card_repository.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';

import 'card_usecases_test.mocks.dart';

@GenerateMocks([CardRepository])
void main() {
  late MockCardRepository mockRepository;

  setUp(() {
    mockRepository = MockCardRepository();
  });

  group('CardUseCases Tests', () {
    group('AddCardUseCase', () {
      late AddCardUseCase useCase;

      setUp(() {
        useCase = AddCardUseCase(mockRepository);
      });

      test('should add card when valid params are provided', () async {
        // Arrange
        final params = AddCardParams(
          deckId: 1,
          frontText: 'Front Text',
          backText: 'Back Text',
          tags: 'test',
        );

        final createdCard = Card(
          id: 1,
          deckId: 1,
          frontText: 'Front Text',
          backText: 'Back Text',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'test',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockRepository.addCard(any))
            .thenAnswer((_) async => Right(createdCard));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isRight(), true);
        
        final returnedCard = result.fold((l) => null, (r) => r);
        expect(returnedCard, equals(createdCard));
        
        verify(mockRepository.addCard(any)).called(1);
      });

      test('should return ValidationFailure when front text is empty', () async {
        // Arrange
        final params = AddCardParams(
          deckId: 1,
          frontText: '',
          backText: 'Back Text',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le recto de la carte ne peut pas être vide'));
        
        verifyNever(mockRepository.addCard(any));
      });

      test('should return ValidationFailure when back text is empty', () async {
        // Arrange
        final params = AddCardParams(
          deckId: 1,
          frontText: 'Front Text',
          backText: '',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le verso de la carte ne peut pas être vide'));
        
        verifyNever(mockRepository.addCard(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final params = AddCardParams(
          deckId: 1,
          frontText: 'Front Text',
          backText: 'Back Text',
        );

        final failure = DatabaseFailure('Database error');
        when(mockRepository.addCard(any))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('UpdateCardUseCase', () {
      late UpdateCardUseCase useCase;

      setUp(() {
        useCase = UpdateCardUseCase(mockRepository);
      });

      test('should update card when valid params are provided', () async {
        // Arrange
        final originalCard = Card(
          id: 1,
          deckId: 1,
          frontText: 'Original Front',
          backText: 'Original Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'original',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final params = UpdateCardParams(
          card: originalCard,
          frontText: 'Updated Front',
          backText: 'Updated Back',
          tags: 'updated',
        );

        final updatedCard = originalCard.copyWith(
          frontText: 'Updated Front',
          backText: 'Updated Back',
          tags: 'updated',
          updatedAt: DateTime.now(),
        );

        when(mockRepository.updateCard(any))
            .thenAnswer((_) async => Right(updatedCard));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isRight(), true);
        
        final returnedCard = result.fold((l) => null, (r) => r);
        expect(returnedCard!.frontText, 'Updated Front');
        expect(returnedCard.backText, 'Updated Back');
        expect(returnedCard.tags, 'updated');
        
        verify(mockRepository.updateCard(any)).called(1);
      });

      test('should return ValidationFailure when front text is empty', () async {
        // Arrange
        final originalCard = Card(
          id: 1,
          deckId: 1,
          frontText: 'Original Front',
          backText: 'Original Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'original',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final params = UpdateCardParams(
          card: originalCard,
          frontText: '',
          backText: 'Updated Back',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le recto de la carte ne peut pas être vide'));
        
        verifyNever(mockRepository.updateCard(any));
      });

      test('should return ValidationFailure when back text is empty', () async {
        // Arrange
        final originalCard = Card(
          id: 1,
          deckId: 1,
          frontText: 'Original Front',
          backText: 'Original Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'original',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final params = UpdateCardParams(
          card: originalCard,
          frontText: 'Updated Front',
          backText: '',
        );

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('Le verso de la carte ne peut pas être vide'));
        
        verifyNever(mockRepository.updateCard(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        final originalCard = Card(
          id: 1,
          deckId: 1,
          frontText: 'Original Front',
          backText: 'Original Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'original',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final params = UpdateCardParams(
          card: originalCard,
          frontText: 'Updated Front',
          backText: 'Updated Back',
        );

        final failure = DatabaseFailure('Update failed');
        when(mockRepository.updateCard(any))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(params);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('DeleteCardUseCase', () {
      late DeleteCardUseCase useCase;

      setUp(() {
        useCase = DeleteCardUseCase(mockRepository);
      });

      test('should delete card when valid id is provided', () async {
        // Arrange
        const cardId = 1;
        when(mockRepository.deleteCard(cardId))
            .thenAnswer((_) async => const Right(unit));

        // Act
        final result = await useCase.call(cardId);

        // Assert
        expect(result.isRight(), true);
        
        final returnedUnit = result.fold((l) => null, (r) => r);
        expect(returnedUnit, equals(unit));
        
        verify(mockRepository.deleteCard(cardId)).called(1);
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
        expect(failure!.message, contains('L\'ID de la carte doit être valide'));
        
        verifyNever(mockRepository.deleteCard(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const cardId = 1;
        final failure = DatabaseFailure('Delete failed');
        when(mockRepository.deleteCard(cardId))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('GetCardsByDeckUseCase', () {
      late GetCardsByDeckUseCase useCase;

      setUp(() {
        useCase = GetCardsByDeckUseCase(mockRepository);
      });

      test('should return stream of cards when valid deck id is provided', () async {
        // Arrange
        const deckId = 1;
        final cards = [
          Card(
            id: 1,
            deckId: deckId,
            frontText: 'Front 1',
            backText: 'Back 1',
            frontImagePath: null,
            backImagePath: null,
            frontAudioPath: null,
            backAudioPath: null,
            tags: 'test',
            difficulty: 1,
            reviewCount: 0,
            lastReviewed: null,
            repetitions: 0,
            easinessFactor: 2.5,
            intervalDays: 1,
            nextReviewDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Card(
            id: 2,
            deckId: deckId,
            frontText: 'Front 2',
            backText: 'Back 2',
            frontImagePath: null,
            backImagePath: null,
            frontAudioPath: null,
            backAudioPath: null,
            tags: 'test',
            difficulty: 1,
            reviewCount: 0,
            lastReviewed: null,
            repetitions: 0,
            easinessFactor: 2.5,
            intervalDays: 1,
            nextReviewDate: DateTime.now(),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockRepository.watchCardsByDeck(deckId))
            .thenAnswer((_) => Stream.value(Right(cards)));        // Act
        final result = useCase.call(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
          final returnedCards = actualResult.fold((l) => null, (r) => r);
        expect(returnedCards, equals(cards));
      });

      test('should return ValidationFailure when invalid deck id is provided', () async {
        // Arrange
        const invalidDeckId = 0;

        // Act
        final result = useCase.call(invalidDeckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('L\'ID du deck doit être valide'));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        final failure = DatabaseFailure('Database error');        when(mockRepository.watchCardsByDeck(deckId))
            .thenAnswer((_) => Stream.value(Left(failure)));

        // Act
        final result = useCase.call(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final returnedFailure = actualResult.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('GetCardsDueForReviewUseCase', () {
      late GetCardsDueForReviewUseCase useCase;

      setUp(() {
        useCase = GetCardsDueForReviewUseCase(mockRepository);
      });

      test('should return stream of due cards when valid deck id is provided', () async {
        // Arrange
        const deckId = 1;
        final dueCards = [
          Card(
            id: 1,
            deckId: deckId,
            frontText: 'Due Card',
            backText: 'Back Text',
            frontImagePath: null,
            backImagePath: null,
            frontAudioPath: null,
            backAudioPath: null,
            tags: 'test',
            difficulty: 1,
            reviewCount: 0,
            lastReviewed: null,
            repetitions: 0,
            easinessFactor: 2.5,
            intervalDays: 1,
            nextReviewDate: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockRepository.watchCardsDueForReview(deckId))
            .thenAnswer((_) => Stream.value(Right(dueCards)));        // Act
        final result = useCase.call(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
        
        final returnedCards = actualResult.fold((l) => null, (r) => r);
        expect(returnedCards, equals(dueCards));
      });      test('should return ValidationFailure when invalid deck id is provided', () async {
        // Arrange
        const invalidDeckId = 0;

        // Act
        final result = useCase.call(invalidDeckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l, (r) => null);
        expect(failure, isA<ValidationFailure>());
        expect(failure!.message, contains('L\'ID du deck doit être valide'));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const deckId = 1;
        final failure = DatabaseFailure('Database error');
        when(mockRepository.watchCardsDueForReview(deckId))
            .thenAnswer((_) => Stream.value(Left(failure)));        // Act
        final result = useCase.call(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final returnedFailure = actualResult.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });

    group('GetCardUseCase', () {
      late GetCardUseCase useCase;

      setUp(() {
        useCase = GetCardUseCase(mockRepository);
      });

      test('should return card when valid id is provided', () async {
        // Arrange
        const cardId = 1;
        final card = Card(
          id: cardId,
          deckId: 1,
          frontText: 'Front Text',
          backText: 'Back Text',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'test',
          difficulty: 1,
          reviewCount: 0,
          lastReviewed: null,
          repetitions: 0,
          easinessFactor: 2.5,
          intervalDays: 1,
          nextReviewDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        when(mockRepository.getCard(cardId))
            .thenAnswer((_) async => Right(card));

        // Act
        final result = await useCase.call(cardId);

        // Assert
        expect(result.isRight(), true);
        
        final returnedCard = result.fold((l) => null, (r) => r);
        expect(returnedCard, equals(card));
        
        verify(mockRepository.getCard(cardId)).called(1);
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
        expect(failure!.message, contains('L\'ID de la carte doit être valide'));
        
        verifyNever(mockRepository.getCard(any));
      });

      test('should return failure when repository fails', () async {
        // Arrange
        const cardId = 1;
        final failure = DatabaseFailure('Card not found');
        when(mockRepository.getCard(cardId))
            .thenAnswer((_) async => Left(failure));

        // Act
        final result = await useCase.call(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final returnedFailure = result.fold((l) => l, (r) => null);
        expect(returnedFailure, equals(failure));
      });
    });
  });
}
