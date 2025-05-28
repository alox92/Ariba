import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/repositories/deck_repository_impl.dart';

import 'deck_repository_impl_test.mocks.dart';

@GenerateMocks([DecksDao])
void main() {
  late DeckRepositoryImpl repository;
  late MockDecksDao mockDecksDao;

  setUp(() {
    mockDecksDao = MockDecksDao();
    repository = DeckRepositoryImpl(mockDecksDao);
  });

  group('DeckRepositoryImpl watchDecks Tests', () {
    test('should return stream of Right<List<Deck>> when data is fetched successfully', () async {
      // Arrange
      final mockDeckDataList = [
        DeckEntityData(
          id: 1,
          name: 'Test Deck 1',
          description: 'Description 1',
          cardCount: 5,
          createdAt: DateTime(2023),
          lastAccessed: DateTime(2023, 1, 3),
        ),
        DeckEntityData(
          id: 2,
          name: 'Test Deck 2',
          description: 'Description 2',
          cardCount: 3,
          createdAt: DateTime(2023, 2),
          lastAccessed: DateTime(2023, 2, 3),
        ),
      ];

      when(mockDecksDao.watchAllDecks())
          .thenAnswer((_) => Stream.value(mockDeckDataList));      // Act
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
  });
}
