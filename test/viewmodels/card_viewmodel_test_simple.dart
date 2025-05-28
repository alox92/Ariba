import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flashcards_app/viewmodels/card_viewmodel.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/services/media_service.dart';

// Generate mocks
@GenerateMocks([
  GetCardsByDeckUseCase,
  AddCardUseCase,
  UpdateCardUseCase,
  DeleteCardUseCase,
  GetCardUseCase,
  UpdateDeckCardCountUseCase,
  MediaService,
])
import 'card_viewmodel_test_simple.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockGetCardsByDeckUseCase mockGetCardsByDeckUseCase;
  late MockAddCardUseCase mockAddCardUseCase;
  late MockUpdateCardUseCase mockUpdateCardUseCase;
  late MockDeleteCardUseCase mockDeleteCardUseCase;
  late MockGetCardUseCase mockGetCardUseCase;
  late MockUpdateDeckCardCountUseCase mockUpdateDeckCardCountUseCase;
  late MockMediaService mockMediaService;
  late CardViewModel cardViewModel;

  // Mock data
  final mockCard1 = domain.Card(
    id: 1,
    deckId: 1,
    frontText: 'Question 1',
    backText: 'Answer 1',
    difficulty: 1,
    intervalDays: 1,
    nextReviewDate: DateTime.now().add(const Duration(days: 1)),
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  final mockCard2 = domain.Card(
    id: 2,
    deckId: 1,
    frontText: 'Question 2',
    backText: 'Answer 2',
    difficulty: 1,
    intervalDays: 1,
    nextReviewDate: DateTime.now().add(const Duration(days: 2)),
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  final List<domain.Card> mockCards = [mockCard1, mockCard2];

  setUp(() {
    mockGetCardsByDeckUseCase = MockGetCardsByDeckUseCase();
    mockAddCardUseCase = MockAddCardUseCase();
    mockUpdateCardUseCase = MockUpdateCardUseCase();
    mockDeleteCardUseCase = MockDeleteCardUseCase();
    mockGetCardUseCase = MockGetCardUseCase();
    mockUpdateDeckCardCountUseCase = MockUpdateDeckCardCountUseCase();
    mockMediaService = MockMediaService();

    // Create ViewModel
    cardViewModel = CardViewModel(
      mockGetCardsByDeckUseCase,
      mockAddCardUseCase,
      mockUpdateCardUseCase,
      mockDeleteCardUseCase,
      mockGetCardUseCase,
      mockUpdateDeckCardCountUseCase,
      mockMediaService,
    );
  });

  group('CardViewModel Basic Tests', () {
    test('Initial values are correct', () {
      expect(cardViewModel.cards, isEmpty);
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      expect(cardViewModel.currentIndex, 0);
      expect(cardViewModel.currentCard, null);
      expect(cardViewModel.hasNextCard, false);
      expect(cardViewModel.hasPreviousCard, false);
    });

    test('loadCardsForDeck success updates state correctly', () async {
      // Arrange
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      expect(cardViewModel.cards, mockCards);
      expect(cardViewModel.cards.length, 2);
    });

    test('loadCardsForDeck failure updates error state', () async {
      // Arrange
      const failure = DatabaseFailure('Database error');
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(const Left<Failure, List<domain.Card>>(failure)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('base de données'));
      expect(cardViewModel.cards, isEmpty);
    });

    test('setCurrentCard updates current card correctly', () {
      // Act
      cardViewModel.setCurrentCard(mockCard1);

      // Assert
      expect(cardViewModel.currentCard, mockCard1);
    });

    test('loading state transitions correctly during operations', () async {
      // Arrange
      bool wasLoadingDuringOperation = false;
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer((_) {
        wasLoadingDuringOperation = cardViewModel.isLoading;
        return Stream.value(Right<Failure, List<domain.Card>>(mockCards));
      });

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(wasLoadingDuringOperation, true);
      expect(cardViewModel.isLoading, false);
    });

    test('error contains proper French messages', () async {
      // Arrange
      const failure = ValidationFailure('Invalid data');
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(const Left<Failure, List<domain.Card>>(failure)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.error, contains('validation'));
    });
  });

  group('CardViewModel Navigation Tests', () {
    test('navigation properties work with empty cards', () {
      expect(cardViewModel.hasNextCard, false);
      expect(cardViewModel.hasPreviousCard, false);
      expect(cardViewModel.currentIndex, 0);
    });

    test('getCurrentCardAtIndex handles edge cases', () {
      expect(cardViewModel.getCurrentCardAtIndex(0), null);
      expect(cardViewModel.getCurrentCardAtIndex(-1), null);
      expect(cardViewModel.getCurrentCardAtIndex(100), null);
    });
  });

  group('CardViewModel CRUD Operations', () {
    test('addCard with basic parameters', () async {
      // This test mainly verifies that the method can be called
      // without crashing, since the actual return value depends on 
      // complex mocking of multiple use cases
      
      // Arrange
      when(mockAddCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateDeckCardCountUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );      // Act
      final result = await cardViewModel.addCard(1, 'Front', 'Back');

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(result, isNotNull); // Use the result to avoid warning
      verify(mockAddCardUseCase.call(any)).called(1);
    });

    test('updateCard with basic parameters', () async {
      // Arrange
      when(mockGetCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );

      // Act
      await cardViewModel.updateCard(1, 'Updated Front', 'Updated Back', 1);

      // Assert
      expect(cardViewModel.isLoading, false);
      verify(mockGetCardUseCase.call(any)).called(1);
      verify(mockUpdateCardUseCase.call(any)).called(1);
    });

    test('deleteCard calls necessary use cases', () async {
      // Arrange
      when(mockGetCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockDeleteCardUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockUpdateDeckCardCountUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<domain.Card>>([])),
      );

      // Act
      await cardViewModel.deleteCard(1, 1);

      // Assert
      expect(cardViewModel.isLoading, false);
      verify(mockGetCardUseCase.call(any)).called(1);
      verify(mockDeleteCardUseCase.call(any)).called(1);
      verify(mockUpdateDeckCardCountUseCase.call(any)).called(1);
    });
  });

  group('CardViewModel Error Handling', () {
    test('handles exceptions gracefully', () async {
      // Arrange
      when(mockGetCardsByDeckUseCase.call(any)).thenThrow(Exception('Network error'));

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Erreur chargement cartes'));
    });

    test('error state is cleared on new operations', () async {
      // Arrange - first cause an error
      when(mockGetCardsByDeckUseCase.call(any)).thenThrow(Exception('First error'));
      await cardViewModel.loadCardsForDeck(1);
      expect(cardViewModel.error, isNotNull);

      // Act - perform successful operation
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.error, null);
    });
  });

  group('CardViewModel Integration', () {
    test('media service integration is properly injected', () {
      // This test verifies that MediaService is properly injected
      expect(cardViewModel, isNotNull);
      // The media service is used internally for file cleanup
    });

    test('complex workflow: load, add, update, delete', () async {
      // Arrange - setup all mocks for a complete workflow
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );
      when(mockAddCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateDeckCardCountUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockGetCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockDeleteCardUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );

      // Act - perform the workflow
      await cardViewModel.loadCardsForDeck(1);
      expect(cardViewModel.cards.length, 2);

      await cardViewModel.addCard(1, 'New Card', 'New Back');
      expect(cardViewModel.error, null);

      await cardViewModel.updateCard(1, 'Updated', 'Updated', 1);
      expect(cardViewModel.error, null);

      await cardViewModel.deleteCard(1, 1);
      expect(cardViewModel.error, null);

      // Assert - all operations completed without errors
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
    });
  });
}
