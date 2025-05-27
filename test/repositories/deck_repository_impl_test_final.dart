import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/repositories/deck_repository_impl.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

import 'deck_repository_impl_test.mocks.dart';

@GenerateMocks([DecksDao])
void main() {
  late DeckRepositoryImpl repository;
  late MockDecksDao mockDecksDao;

  setUp(() {
    mockDecksDao = MockDecksDao();
    repository = DeckRepositoryImpl(mockDecksDao);
  });

  group('DeckRepositoryImpl Tests', () {
    group('watchDecks', () {
      test('should return stream of Right<List<Deck>> when data is fetched successfully', () async {
        // Arrange
        final mockDeckDataList = [
          DeckEntityData(
            id: 1,
            name: 'Test Deck 1',
            description: 'Description 1',
            cardCount: 5,
            createdAt: DateTime(2023, 1, 1),
            lastAccessed: DateTime(2023, 1, 3),
          ),
          DeckEntityData(
            id: 2,
            name: 'Test Deck 2',
            description: 'Description 2',
            cardCount: 3,
            createdAt: DateTime(2023, 2, 1),
            lastAccessed: DateTime(2023, 2, 3),
          ),
        ];

        when(mockDecksDao.watchAllDecks())
            .thenAnswer((_) => Stream.value(mockDeckDataList));

        // Act
        final result = repository.watchDecks();

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isRight(), true);
        
        final decks = actualResult.fold((l) => null, (r) => r);
        expect(decks, isNotNull);
        expect(decks!.length, 2);
        expect(decks[0].name, 'Test Deck 1');
        expect(decks[1].name, 'Test Deck 2');
      });

      test('should return stream of Left<DatabaseFailure> when mapping fails', () async {
        // Arrange
        when(mockDecksDao.watchAllDecks())
            .thenAnswer((_) => Stream.value([null as dynamic]));

        // Act
        final result = repository.watchDecks();

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
      });

      test('should return stream of Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        when(mockDecksDao.watchAllDecks())
            .thenThrow(Exception('Database error'));

        // Act
        final result = repository.watchDecks();

        // Assert
        final actualResult = await result.first;
        expect(actualResult.isLeft(), true);
        
        final failure = actualResult.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Database error'));
      });
    });

    group('getDeckById', () {
      test('should return Right<Deck> when deck is found', () async {
        // Arrange
        const deckId = 1;
        final mockDeckData = DeckEntityData(
          id: deckId,
          name: 'Test Deck',
          description: 'Test Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          lastAccessed: DateTime(2023, 1, 3),
        );

        when(mockDecksDao.getDeckById(deckId))
            .thenAnswer((_) async => mockDeckData);

        // Act
        final result = await repository.getDeckById(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final deck = result.fold((l) => null, (r) => r);
        expect(deck, isNotNull);
        expect(deck!.id, deckId);
        expect(deck.name, 'Test Deck');
        expect(deck.description, 'Test Description');
      });

      test('should return Left<DatabaseFailure> when dao throws exception', () async {
        // Arrange
        const deckId = 1;
        when(mockDecksDao.getDeckById(deckId))
            .thenThrow(Exception('Deck not found'));

        // Act
        final result = await repository.getDeckById(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Deck not found'));
      });
    });

    group('addDeck', () {
      test('should return Right<Deck> when deck is added successfully', () async {
        // Arrange
        final deck = Deck(
          id: 0,
          name: 'New Deck',
          description: 'New Description',
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        const generatedId = 1;
        final createdDeckData = DeckEntityData(
          id: generatedId,
          name: 'New Deck',
          description: 'New Description',
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          lastAccessed: DateTime(2023, 1, 1),
        );

        when(mockDecksDao.addDeck(any))
            .thenAnswer((_) async => generatedId);
        when(mockDecksDao.getDeckById(generatedId))
            .thenAnswer((_) async => createdDeckData);

        // Act
        final result = await repository.addDeck(deck);

        // Assert
        expect(result.isRight(), true);
        
        final createdDeck = result.fold((l) => null, (r) => r);
        expect(createdDeck, isNotNull);
        expect(createdDeck!.id, generatedId);
        expect(createdDeck.name, 'New Deck');

        verify(mockDecksDao.addDeck(any)).called(1);
        verify(mockDecksDao.getDeckById(generatedId)).called(1);
      });

      test('should return Left<DatabaseFailure> when addDeck fails', () async {
        // Arrange
        final deck = Deck(
          id: 0,
          name: 'New Deck',
          description: 'New Description',
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 1),
        );

        when(mockDecksDao.addDeck(any))
            .thenThrow(Exception('Insert failed'));

        // Act
        final result = await repository.addDeck(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Insert failed'));
      });
    });

    group('updateDeck', () {
      test('should return Right<Deck> when deck is updated successfully', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 3),
        );

        final updatedDeckData = DeckEntityData(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          lastAccessed: DateTime(2023, 1, 3),
        );

        when(mockDecksDao.updateDeck(any))
            .thenAnswer((_) async => true);
        when(mockDecksDao.getDeckById(1))
            .thenAnswer((_) async => updatedDeckData);

        // Act
        final result = await repository.updateDeck(deck);

        // Assert
        expect(result.isRight(), true);
        
        final updatedDeck = result.fold((l) => null, (r) => r);
        expect(updatedDeck, isNotNull);
        expect(updatedDeck!.name, 'Updated Deck');

        verify(mockDecksDao.updateDeck(any)).called(1);
        verify(mockDecksDao.getDeckById(1)).called(1);
      });

      test('should return Left<DatabaseFailure> when update returns false', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 3),
        );

        when(mockDecksDao.updateDeck(any))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.updateDeck(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Échec de la mise à jour'));
      });

      test('should return Left<DatabaseFailure> when updateDeck throws exception', () async {
        // Arrange
        final deck = Deck(
          id: 1,
          name: 'Updated Deck',
          description: 'Updated Description',
          cardCount: 5,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 3),
        );

        when(mockDecksDao.updateDeck(any))
            .thenThrow(Exception('Update failed'));

        // Act
        final result = await repository.updateDeck(deck);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Update failed'));
      });
    });

    group('deleteDeck', () {
      test('should return Right<Unit> when deck is deleted successfully', () async {
        // Arrange
        const deckId = 1;

        when(mockDecksDao.deleteDeck(deckId))
            .thenAnswer((_) async => 1); // 1 row deleted

        // Act
        final result = await repository.deleteDeck(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final unit = result.fold((l) => null, (r) => r);
        expect(unit, isNotNull);

        verify(mockDecksDao.deleteDeck(deckId)).called(1);
      });

      test('should return Left<DatabaseFailure> when no deck is deleted', () async {
        // Arrange
        const deckId = 1;

        when(mockDecksDao.deleteDeck(deckId))
            .thenAnswer((_) async => 0); // 0 rows deleted

        // Act
        final result = await repository.deleteDeck(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Aucun deck trouvé'));
      });

      test('should return Left<DatabaseFailure> when deleteDeck throws exception', () async {
        // Arrange
        const deckId = 1;

        when(mockDecksDao.deleteDeck(deckId))
            .thenThrow(Exception('Delete failed'));

        // Act
        final result = await repository.deleteDeck(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Delete failed'));
      });
    });

    group('updateCardCount', () {
      test('should return Right<Unit> when card count is updated successfully', () async {
        // Arrange
        const deckId = 1;

        when(mockDecksDao.updateCardCount(deckId))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateCardCount(deckId);

        // Assert
        expect(result.isRight(), true);
        
        final unit = result.fold((l) => null, (r) => r);
        expect(unit, isNotNull);

        verify(mockDecksDao.updateCardCount(deckId)).called(1);
      });

      test('should return Left<DatabaseFailure> when updateCardCount throws exception', () async {
        // Arrange
        const deckId = 1;

        when(mockDecksDao.updateCardCount(deckId))
            .thenThrow(Exception('Update card count failed'));

        // Act
        final result = await repository.updateCardCount(deckId);

        // Assert
        expect(result.isLeft(), true);
        
        final failure = result.fold((l) => l as DatabaseFailure, (r) => throw Exception('Expected failure'));
        expect(failure, isA<DatabaseFailure>());
        expect(failure.message, contains('Update card count failed'));
      });
    });
  });
}
