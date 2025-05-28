import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

import 'package:flashcards_app/viewmodels/card_viewmodel.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/services/media_service.dart';

@GenerateMocks([
  GetCardsByDeckUseCase,
  AddCardUseCase,
  UpdateCardUseCase,
  DeleteCardUseCase,
  GetCardUseCase,
  UpdateDeckCardCountUseCase,
  MediaService,
])
import 'card_viewmodel_working_test.mocks.dart';

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
    difficulty: 2,
    reviewCount: 1,
    easinessFactor: 2.6,
    repetitions: 1,
    intervalDays: 6,
    nextReviewDate: DateTime.now().add(const Duration(days: 6)),
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  final mockCards = [mockCard1, mockCard2];

  setUp(() {
    mockGetCardsByDeckUseCase = MockGetCardsByDeckUseCase();
    mockAddCardUseCase = MockAddCardUseCase();
    mockUpdateCardUseCase = MockUpdateCardUseCase();
    mockDeleteCardUseCase = MockDeleteCardUseCase();
    mockGetCardUseCase = MockGetCardUseCase();
    mockUpdateDeckCardCountUseCase = MockUpdateDeckCardCountUseCase();
    mockMediaService = MockMediaService();

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

  group('CardViewModel Tests', () {
    test('initial state is correct', () {
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      expect(cardViewModel.cards, isEmpty);
      expect(cardViewModel.currentCard, null);
      expect(cardViewModel.currentIndex, 0);
    });

    test('loadCardsForDeck loads cards successfully', () async {
      // Arrange
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>(mockCards)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.cards.length, 2);
      expect(cardViewModel.cards[0].frontText, 'Question 1');
      expect(cardViewModel.cards[1].frontText, 'Question 2');
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
    });

    test('loadCardsForDeck handles error correctly', () async {      // Arrange
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(const Left<Failure, List<domain.Card>>(DatabaseFailure('Test error'))),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.cards, isEmpty);
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, isNotNull);
    });

    test('addCard adds card successfully', () async {
      // Arrange
      when(mockAddCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateDeckCardCountUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>([mockCard1])),
      );

      // Act
      final result = await cardViewModel.addCard(1, 'New Question', 'New Answer');

      // Assert
      expect(result, isNotNull);
      expect(cardViewModel.error, null);
      expect(cardViewModel.isLoading, false);
    });    test('updateCard updates card successfully', () async {
      // Arrange
      when(mockGetCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockUpdateCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(Right<Failure, List<domain.Card>>([mockCard1])),
      );

      // Act
      await cardViewModel.updateCard(1, 'Updated Question', 'Updated Answer', 1);

      // Assert
      expect(cardViewModel.error, null);
      expect(cardViewModel.isLoading, false);
    });    test('deleteCard deletes card successfully', () async {
      // Arrange
      when(mockGetCardUseCase.call(any)).thenAnswer(
        (_) async => Right<Failure, domain.Card>(mockCard1),
      );
      when(mockDeleteCardUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );
      when(mockUpdateDeckCardCountUseCase.call(any)).thenAnswer(
        (_) async => const Right<Failure, Unit>(unit),
      );      when(mockMediaService.deleteMedia(any)).thenAnswer(
        (_) async => {},
      );
      when(mockGetCardsByDeckUseCase.call(any)).thenAnswer(
        (_) => Stream.value(const Right<Failure, List<domain.Card>>([])),
      );

      // Act
      await cardViewModel.deleteCard(1, 1);

      // Assert
      expect(cardViewModel.error, null);
      expect(cardViewModel.isLoading, false);
    });

    test('nextCard updates current index correctly', () {
      // Arrange - set up cards first
      cardViewModel.cards.addAll(mockCards);

      // Act
      cardViewModel.nextCard();

      // Assert
      expect(cardViewModel.currentIndex, 1);
    });

    test('previousCard updates current index correctly', () {
      // Arrange - set up cards and move to second card
      cardViewModel.cards.addAll(mockCards);
      cardViewModel.nextCard(); // Move to index 1
      
      // Act
      cardViewModel.previousCard();

      // Assert
      expect(cardViewModel.currentIndex, 0);
    });

    test('hasNextCard returns correct boolean', () {
      // Arrange
      cardViewModel.cards.addAll(mockCards);

      // Assert
      expect(cardViewModel.hasNextCard, true); // At index 0, has next
      
      cardViewModel.nextCard(); // Move to index 1
      expect(cardViewModel.hasNextCard, false); // At last index, no next
    });

    test('hasPreviousCard returns correct boolean', () {
      // Arrange
      cardViewModel.cards.addAll(mockCards);

      // Assert
      expect(cardViewModel.hasPreviousCard, false); // At index 0, no previous
      
      cardViewModel.nextCard(); // Move to index 1
      expect(cardViewModel.hasPreviousCard, true); // Not at first index, has previous
    });

    test('error handling for failed operations', () async {      // Arrange
      when(mockAddCardUseCase.call(any)).thenAnswer(
        (_) async => const Left<Failure, domain.Card>(DatabaseFailure('Test error')),
      );

      // Act
      await cardViewModel.addCard(1, 'Test', 'Test');

      // Assert
      expect(cardViewModel.error, isNotNull);
      expect(cardViewModel.isLoading, false);
    });
  });
}
