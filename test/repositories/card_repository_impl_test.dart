import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/repositories/card_repository_impl.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

import 'card_repository_impl_test.mocks.dart';

@GenerateMocks([CardsDao])
void main() {
  late CardRepositoryImpl repository;
  late MockCardsDao mockCardsDao;

  setUp(() {
    mockCardsDao = MockCardsDao();
    repository = CardRepositoryImpl(mockCardsDao);
  });

  group('CardRepositoryImpl Tests', () {
    group('watchCardsByDeck', () {
      test('should return stream of Right<List<Card>> when data is fetched successfully', () async {
        // Arrange
        const deckId = 1;
        final mockCardDataList = [
          CardEntityData(
            id: 1,
            deckId: deckId,
            frontText: 'Front 1',
            backText: 'Back 1',
            tags: 'test',
            frontImage: null,
            backImage: null,
            frontAudio: null,
            backAudio: null,
            createdAt: DateTime(2023, 1, 1),
            lastReviewed: DateTime(2023, 1, 2),
            interval: 1,
            easeFactor: 2.5,
          ),
          CardEntityData(
            id: 2,
            deckId: deckId,
            frontText: 'Front 2',
            backText: 'Back 2',
            tags: 'test',
            frontImage: null,
            backImage: null,
            frontAudio: null,
            backAudio: null,
            createdAt: DateTime(2023, 1, 1),
            lastReviewed: DateTime(2023, 1, 2),
            interval: 2,
            easeFactor: 2.6,
          ),
        ];
        
        when(mockCardsDao.watchCardsForDeck(deckId))
            .thenAnswer((_) => Stream.value(mockCardDataList));

        // Act
        final result = repository.watchCardsByDeck(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
        
        final cards = actualResult.fold((l) => null, (r) => r);
        expect(cards, isNotNull);
        expect(cards!.length, 2);
        expect(cards[0].frontText, 'Front 1');
        expect(cards[1].frontText, 'Front 2');
      });

      test('should return stream of Left<DatabaseFailure> when mapping fails', () async {
        // Arrange
        const deckId = 1;
        when(mockCardsDao.watchCardsForDeck(deckId))
            .thenAnswer((_) => Stream.value([null as dynamic]));

        // Act
        final result = repository.watchCardsByDeck(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
          final failure = actualResult.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
      });

      test('should return stream of Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        const deckId = 1;
        when(mockCardsDao.watchCardsForDeck(deckId))
            .thenThrow(Exception('Database error'));

        // Act
        final result = repository.watchCardsByDeck(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Database error'));
      });
    });

    group('watchCardsDueForReview', () {
      test('should return only cards due for review', () async {
        // Arrange
        const deckId = 1;
        final now = DateTime.now();
        final pastDate = now.subtract(const Duration(days: 1));
        final futureDate = now.add(const Duration(days: 1));

        final mockCardDataList = [
          CardEntityData(
            id: 1,
            deckId: deckId,
            frontText: 'Due Card',
            backText: 'Back 1',
            tags: 'test',
            frontImage: null,
            backImage: null,
            frontAudio: null,
            backAudio: null,
            createdAt: pastDate,
            lastReviewed: pastDate,
            interval: 1,
            easeFactor: 2.5,
          ),
          CardEntityData(
            id: 2,
            deckId: deckId,
            frontText: 'Not Due Card',
            backText: 'Back 2',
            tags: 'test',
            frontImage: null,
            backImage: null,
            frontAudio: null,
            backAudio: null,
            createdAt: futureDate,
            lastReviewed: futureDate,
            interval: 10,
            easeFactor: 2.6,
          ),
        ];
        
        when(mockCardsDao.watchCardsForDeck(deckId))
            .thenAnswer((_) => Stream.value(mockCardDataList));

        // Act
        final result = repository.watchCardsDueForReview(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
          final cards = actualResult.fold((l) => null, (r) => r);
        expect(cards, isNotNull);
        expect(cards!.length, 1);
        expect(cards[0].frontText, 'Due Card');
      });

      test('should return stream of Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        const deckId = 1;
        when(mockCardsDao.watchCardsForDeck(deckId))
            .thenThrow(Exception('Database error'));

        // Act
        final result = repository.watchCardsDueForReview(deckId);

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Database error'));
      });
    });

    group('getCardsForDeck', () {
      test('should return Right<List<Card>> when cards are found', () async {
        // Arrange
        const deckId = 1;
        final mockCardDataList = [
          CardEntityData(
            id: 1,
            deckId: deckId,
            frontText: 'Front 1',
            backText: 'Back 1',
            tags: 'test',
            frontImage: null,
            backImage: null,
            frontAudio: null,
            backAudio: null,
            createdAt: DateTime(2023, 1, 1),
            lastReviewed: DateTime(2023, 1, 2),
            interval: 1,
            easeFactor: 2.5,
          ),
        ];

        when(mockCardsDao.getCardsForDeck(deckId))
            .thenAnswer((_) async => mockCardDataList);

        // Act
        final result = await repository.getCardsForDeck(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final cards = result.fold((l) => null, (r) => r);
        expect(cards, isNotNull);
        expect(cards!.length, 1);
        expect(cards[0].frontText, 'Front 1');
      });

      test('should return Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        const deckId = 1;
        when(mockCardsDao.getCardsForDeck(deckId))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getCardsForDeck(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Database error'));
      });
    });

    group('getCard', () {
      test('should return Right<Card> when card is found', () async {
        // Arrange
        const cardId = 1;
        final mockCardData = CardEntityData(
          id: cardId,
          deckId: 1,
          frontText: 'Front Text',
          backText: 'Back Text',
          tags: 'test',
          frontImage: null,
          backImage: null,
          frontAudio: null,
          backAudio: null,
          createdAt: DateTime(2023, 1, 1),
          lastReviewed: DateTime(2023, 1, 2),
          interval: 1,
          easeFactor: 2.5,
        );

        when(mockCardsDao.getCardById(cardId))
            .thenAnswer((_) async => mockCardData);

        // Act
        final result = await repository.getCard(cardId);

        // Assert
        expect(result.isRight(), true);
        
        final card = result.fold((l) => null, (r) => r);
        expect(card, isNotNull);
        expect(card!.id, cardId);
        expect(card.frontText, 'Front Text');
      });

      test('should return Left<DatabaseFailure> when card is not found', () async {
        // Arrange
        const cardId = 1;
        when(mockCardsDao.getCardById(cardId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCard(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Carte non trouvée'));
      });

      test('should return Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        const cardId = 1;
        when(mockCardsDao.getCardById(cardId))
            .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.getCard(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Database error'));
      });
    });

    group('addCard', () {
      test('should return Right<Card> when card is added successfully', () async {
        // Arrange
        final card = Card(
          id: 0, // Will be generated
          deckId: 1,
          frontText: 'New Front',
          backText: 'New Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'new',
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

        const generatedId = 1;
        final createdCardData = CardEntityData(
          id: generatedId,
          deckId: 1,
          frontText: 'New Front',
          backText: 'New Back',
          tags: 'new',
          frontImage: null,
          backImage: null,
          frontAudio: null,
          backAudio: null,
          createdAt: DateTime(2023, 1, 1),
          lastReviewed: null,
          interval: 1,
          easeFactor: 2.5,
        );

        when(mockCardsDao.addCard(any))
            .thenAnswer((_) async => generatedId);
        when(mockCardsDao.getCardById(generatedId))
            .thenAnswer((_) async => createdCardData);

        // Act
        final result = await repository.addCard(card);

        // Assert
        expect(result.isRight(), true);
        
        final createdCard = result.fold((l) => null, (r) => r);
        expect(createdCard, isNotNull);
        expect(createdCard!.id, generatedId);
        expect(createdCard.frontText, 'New Front');

        verify(mockCardsDao.addCard(any)).called(1);
        verify(mockCardsDao.getCardById(generatedId)).called(1);
      });

      test('should return Left<DatabaseFailure> when getCardById returns null after insert', () async {
        // Arrange
        final card = Card(
          id: 0,
          deckId: 1,
          frontText: 'New Front',
          backText: 'New Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'new',
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

        const generatedId = 1;
        when(mockCardsDao.addCard(any))
            .thenAnswer((_) async => generatedId);
        when(mockCardsDao.getCardById(generatedId))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.addCard(card);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Erreur lors de la récupération'));
      });

      test('should return Left<DatabaseFailure> when addCard throws exception', () async {
        // Arrange
        final card = Card(
          id: 0,
          deckId: 1,
          frontText: 'New Front',
          backText: 'New Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'new',
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

        when(mockCardsDao.addCard(any))
            .thenThrow(Exception('Insert failed'));

        // Act
        final result = await repository.addCard(card);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Insert failed'));
      });
    });

    group('updateCard', () {
      test('should return Right<Card> when card is updated successfully', () async {
        // Arrange
        final card = Card(
          id: 1,
          deckId: 1,
          frontText: 'Updated Front',
          backText: 'Updated Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'updated',
          difficulty: 2,
          reviewCount: 1,
          lastReviewed: DateTime.now(),
          repetitions: 1,
          easinessFactor: 2.6,
          intervalDays: 3,
          nextReviewDate: DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime.now(),
        );

        final updatedCardData = CardEntityData(
          id: 1,
          deckId: 1,
          frontText: 'Updated Front',
          backText: 'Updated Back',
          tags: 'updated',
          frontImage: null,
          backImage: null,
          frontAudio: null,
          backAudio: null,
          createdAt: DateTime(2023, 1, 1),
          lastReviewed: DateTime.now(),
          interval: 3,
          easeFactor: 2.6,
        );

        when(mockCardsDao.updateCard(any))
            .thenAnswer((_) async => true);
        when(mockCardsDao.getCardById(1))
            .thenAnswer((_) async => updatedCardData);

        // Act
        final result = await repository.updateCard(card);

        // Assert
        expect(result.isRight(), true);
        
        final updatedCard = result.fold((l) => null, (r) => r);
        expect(updatedCard, isNotNull);
        expect(updatedCard!.frontText, 'Updated Front');

        verify(mockCardsDao.updateCard(any)).called(1);
        verify(mockCardsDao.getCardById(1)).called(1);
      });

      test('should return Left<DatabaseFailure> when update returns false', () async {
        // Arrange
        final card = Card(
          id: 1,
          deckId: 1,
          frontText: 'Updated Front',
          backText: 'Updated Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'updated',
          difficulty: 2,
          reviewCount: 1,
          lastReviewed: DateTime.now(),
          repetitions: 1,
          easinessFactor: 2.6,
          intervalDays: 3,
          nextReviewDate: DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime.now(),
        );

        when(mockCardsDao.updateCard(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.updateCard(card);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Échec de la mise à jour'));
      });

      test('should return Left<DatabaseFailure> when updateCard throws exception', () async {
        // Arrange
        final card = Card(
          id: 1,
          deckId: 1,
          frontText: 'Updated Front',
          backText: 'Updated Back',
          frontImagePath: null,
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: null,
          tags: 'updated',
          difficulty: 2,
          reviewCount: 1,
          lastReviewed: DateTime.now(),
          repetitions: 1,
          easinessFactor: 2.6,
          intervalDays: 3,
          nextReviewDate: DateTime.now().add(const Duration(days: 3)),
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime.now(),
        );

        when(mockCardsDao.updateCard(any))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateCard(card);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Update failed'));
      });
    });

    group('deleteCard', () {
      test('should return Right<Unit> when card is deleted successfully', () async {
        // Arrange
        const cardId = 1;

        when(mockCardsDao.deleteCard(cardId))
            .thenAnswer((_) async => 1); // 1 row deleted

        // Act
        final result = await repository.deleteCard(cardId);

        // Assert
        expect(result.isRight(), true);
        
        final unit = result.fold((l) => null, (r) => r);
        expect(unit, isNotNull);

        verify(mockCardsDao.deleteCard(cardId)).called(1);
      });

      test('should return Left<DatabaseFailure> when no card is deleted', () async {
        // Arrange
        const cardId = 1;

        when(mockCardsDao.deleteCard(cardId))
            .thenAnswer((_) async => 0); // 0 rows deleted

        // Act
        final result = await repository.deleteCard(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Aucune carte trouvée'));
      });

      test('should return Left<DatabaseFailure> when deleteCard throws exception', () async {
        // Arrange
        const cardId = 1;

        when(mockCardsDao.deleteCard(cardId))
            .thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteCard(cardId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l, (r) => null);
        expect(failure, isA<DatabaseFailure>());
        expect(failure!.message, contains('Delete failed'));
      });
    });
  });
}
