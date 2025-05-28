// ignore_for_file: prefer_const_declarations

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flashcards_app/viewmodels/card_viewmodel.dart';
import 'package:flashcards_app/domain/entities/card.dart';
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
import 'card_viewmodel_test.mocks.dart';

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
  final mockCard1 = Card(
    id: 1,
    deckId: 1,
    frontText: 'Front 1',
    backText: 'Back 1',
    tags: 'tag1,tag2',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    lastReviewed: DateTime(2024),
    intervalDays: 1,
  );

  final mockCard2 = Card(
    id: 2,
    deckId: 1,
    frontText: 'Front 2',
    backText: 'Back 2',
    tags: 'tag3',
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
    lastReviewed: DateTime(2024, 1, 2),
    intervalDays: 2,
    easinessFactor: 2.6,
    reviewCount: 1,
    frontImagePath: '/path/to/front.jpg',
    backImagePath: '/path/to/back.jpg',
    frontAudioPath: '/path/to/front.mp3',
    backAudioPath: '/path/to/back.mp3',
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

    // Create ViewModel
    cardViewModel = CardViewModel(
      mockGetCardsByDeckUseCase,
      mockAddCardUseCase,
      mockUpdateCardUseCase,
      mockDeleteCardUseCase,
      mockGetCardUseCase,
      mockUpdateDeckCardCountUseCase,
      mockMediaService,
    );    // Setup default mocks
    when(mockUpdateDeckCardCountUseCase(any)).thenAnswer(
      (_) async => const Right(unit),
    );
  });

  group('CardViewModel Tests', () {
    test('Initial values are correct', () {
      expect(cardViewModel.cards, isEmpty);
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      expect(cardViewModel.currentCard, null);
      expect(cardViewModel.currentIndex, 0);
      expect(cardViewModel.hasNextCard, false);
      expect(cardViewModel.hasPreviousCard, false);
    });

    test('loadCardsForDeck success updates state correctly', () async {
      // Arrange
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right(mockCards)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      expect(cardViewModel.cards, mockCards);
      expect(cardViewModel.cards.length, 2);
      expect(cardViewModel.cards[0].frontText, 'Front 1');
      expect(cardViewModel.cards[1].frontText, 'Front 2');
    });

    test('loadCardsForDeck failure updates error state', () async {
      // Arrange
      const failure = DatabaseFailure('Database error');
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(const Left(failure)),
      );

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Database error'));
      expect(cardViewModel.cards, isEmpty);
    });

    test('loadCardsForDeck exception updates error state', () async {
      // Arrange
      when(mockGetCardsByDeckUseCase(1)).thenThrow(Exception('Network error'));

      // Act
      await cardViewModel.loadCardsForDeck(1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Network error'));
      expect(cardViewModel.cards, isEmpty);
    });

    test('addCard success adds card correctly', () async {
      // Arrange
      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard1),
      );
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard1])),
      );

      // Act
      final result = await cardViewModel.addCard(
        1,
        'Front 1',
        'Back 1',
        tags: 'tag1,tag2',
      );

      // Assert
      expect(result, mockCard1);
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      verify(mockAddCardUseCase(any)).called(1);
      verify(mockUpdateDeckCardCountUseCase(1)).called(1);
    });

    test('addCard failure updates error state', () async {
      // Arrange
      const failure = ValidationFailure('Invalid content');
      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => const Left(failure),
      );

      // Act
      final result = await cardViewModel.addCard(1, '', '');

      // Assert
      expect(result, null);
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Invalid content'));
      verify(mockAddCardUseCase(any)).called(1);
    });    test('addCardWithMedia processes images correctly', () async {
      // Arrange
      when(mockMediaService.processImage('/temp/image.jpg'))
          .thenAnswer((_) async => '/processed/image.jpg');
      when(mockMediaService.processImage('/temp/back.jpg'))
          .thenAnswer((_) async => '/processed/back.jpg');
      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard2),
      );
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard2])),
      );

      // Act
      final result = await cardViewModel.addCardWithMedia(
        'Front',
        'Back',
        1,
        frontImagePath: '/temp/image.jpg',
        backImagePath: '/temp/back.jpg',
      );

      // Assert
      expect(result, mockCard2);
      verify(mockMediaService.processImage('/temp/image.jpg')).called(1);
      verify(mockMediaService.processImage('/temp/back.jpg')).called(1);
      verify(mockAddCardUseCase(any)).called(1);
    });

    test('addCardWithMedia handles media processing error', () async {
      // Arrange
      when(mockMediaService.processImage(any))
          .thenThrow(Exception('Media processing failed'));

      // Act & Assert
      expect(
        () async => await cardViewModel.addCardWithMedia(
          'Front',
          'Back',
          1,
          frontImagePath: '/temp/image.jpg',
        ),
        throwsException,
      );
      expect(cardViewModel.error, contains('média'));
    });    test('updateCard success updates card correctly', () async {
      // Arrange
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => Right(mockCard1),
      );
      when(mockUpdateCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard1),
      );
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard1])),
      );

      // Act
      await cardViewModel.updateCard(
        1,
        'Updated Front',
        'Updated Back',
        1,
        tags: 'updated',
      );

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      verify(mockGetCardUseCase(1)).called(1);
      verify(mockUpdateCardUseCase(any)).called(1);
    });

    test('updateCard failure when getting card fails', () async {
      // Arrange
      const failure = DatabaseFailure('Card not found');
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      // Act
      await cardViewModel.updateCard(1, 'Front', 'Back', 1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Card not found'));
      verify(mockGetCardUseCase(1)).called(1);
      verifyNever(mockUpdateCardUseCase(any));
    });

    test('updateCardWithMedia handles media changes correctly', () async {
      // Arrange
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => Right(mockCard2),
      );
      when(mockMediaService.processImage('/new/image.jpg'))
          .thenAnswer((_) async => '/processed/new.jpg');      when(mockMediaService.deleteMedia('/path/to/front.jpg'))
          .thenAnswer((_) async => true);
      when(mockUpdateCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard2),
      );
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard2])),
      );

      // Act
      await cardViewModel.updateCardWithMedia(
        1,
        'Updated Front',
        'Updated Back',
        '/new/image.jpg',
        null, // Remove back image
        null,
        null,
        1,
      );

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      verify(mockMediaService.processImage('/new/image.jpg')).called(1);
      verify(mockMediaService.deleteMedia('/path/to/front.jpg')).called(1);
      verify(mockMediaService.deleteMedia('/path/to/back.jpg')).called(1);
    });

    test('deleteCard success deletes card and media correctly', () async {
      // Arrange
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => Right(mockCard2),
      );
      when(mockDeleteCardUseCase(1)).thenAnswer(
        (_) async => const Right(unit),
      );
      when(mockMediaService.deleteMedia(any)).thenAnswer((_) async => true);
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(const Right([])),
      );

      // Act
      await cardViewModel.deleteCard(1, 1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, null);
      verify(mockGetCardUseCase(1)).called(1);
      verify(mockDeleteCardUseCase(1)).called(1);
      verify(mockUpdateDeckCardCountUseCase(1)).called(1);
      verify(mockMediaService.deleteMedia('/path/to/front.jpg')).called(1);
      verify(mockMediaService.deleteMedia('/path/to/back.jpg')).called(1);
      verify(mockMediaService.deleteMedia('/path/to/front.mp3')).called(1);
      verify(mockMediaService.deleteMedia('/path/to/back.mp3')).called(1);
    });

    test('deleteCard handles missing card gracefully', () async {
      // Arrange
      const failure = DatabaseFailure('Card not found');
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      // Act
      await cardViewModel.deleteCard(1, 1);

      // Assert
      expect(cardViewModel.isLoading, false);
      expect(cardViewModel.error, contains('Card not found'));
      verify(mockGetCardUseCase(1)).called(1);
      verifyNever(mockDeleteCardUseCase(any));
    });

    test('navigation methods work correctly', () async {
      // Arrange - load cards first
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right(mockCards)),
      );
      await cardViewModel.loadCardsForDeck(1);

      // Test initial state
      expect(cardViewModel.currentIndex, 0);
      expect(cardViewModel.hasPreviousCard, false);
      expect(cardViewModel.hasNextCard, true);

      // Test next card
      cardViewModel.nextCard();
      expect(cardViewModel.currentIndex, 1);
      expect(cardViewModel.currentCard, mockCard2);
      expect(cardViewModel.hasPreviousCard, true);
      expect(cardViewModel.hasNextCard, false);

      // Test previous card
      cardViewModel.previousCard();
      expect(cardViewModel.currentIndex, 0);
      expect(cardViewModel.currentCard, mockCard1);
      expect(cardViewModel.hasPreviousCard, false);
      expect(cardViewModel.hasNextCard, true);

      // Test boundaries
      cardViewModel.previousCard(); // Should not change
      expect(cardViewModel.currentIndex, 0);

      cardViewModel.nextCard();
      cardViewModel.nextCard(); // Should not change
      expect(cardViewModel.currentIndex, 1);
    });

    test('markCardAsReviewed updates card correctly', () async {
      // Arrange
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => Right(mockCard1),
      );      when(mockUpdateCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard1),
      );

      // Act
      await cardViewModel.markCardAsReviewed(1, 4, 3, 2.7);

      // Assert
      expect(cardViewModel.error, null);
      verify(mockGetCardUseCase(1)).called(1);
      verify(mockUpdateCardUseCase(any)).called(1);
    });

    test('markCardAsReviewed handles failure gracefully', () async {
      // Arrange
      const failure = DatabaseFailure('Update failed');
      when(mockGetCardUseCase(1)).thenAnswer(
        (_) async => const Left(failure),
      );

      // Act
      await cardViewModel.markCardAsReviewed(1, 4, 3, 2.7);

      // Assert
      expect(cardViewModel.error, contains('Update failed'));
      verify(mockGetCardUseCase(1)).called(1);
      verifyNever(mockUpdateCardUseCase(any));
    });

    test('error messages are properly formatted', () async {
      // Test different failure types
      const databaseFailure = DatabaseFailure('DB error');
      const validationFailure = ValidationFailure('Validation error');
      const unknownFailure = UnknownFailure('Network error');

      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => const Left(databaseFailure),
      );
      await cardViewModel.addCard(1, 'Front', 'Back');
      expect(cardViewModel.error, contains('base de données'));

      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => const Left(validationFailure),
      );
      await cardViewModel.addCard(1, 'Front', 'Back');
      expect(cardViewModel.error, contains('validation'));

      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => const Left(unknownFailure),
      );
      await cardViewModel.addCard(1, 'Front', 'Back');
      expect(cardViewModel.error, contains('inconnue'));
    });

    test('loading state is managed correctly during operations', () async {
      // Arrange
      bool isLoadingDuringAdd = false;
      when(mockAddCardUseCase(any)).thenAnswer((_) async {
        isLoadingDuringAdd = cardViewModel.isLoading;
        return Right(mockCard1);
      });
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard1])),
      );

      // Act
      await cardViewModel.addCard(1, 'Front', 'Back');

      // Assert
      expect(isLoadingDuringAdd, true);
      expect(cardViewModel.isLoading, false);
    });

    test('error state is cleared on new operations', () async {
      // Arrange - set initial error
      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => const Left(DatabaseFailure('Initial error')),
      );
      await cardViewModel.addCard(1, 'Failed', 'Failed');
      expect(cardViewModel.error, isNotNull);

      // Act - perform successful operation
      when(mockAddCardUseCase(any)).thenAnswer(
        (_) async => Right(mockCard1),
      );
      when(mockGetCardsByDeckUseCase(1)).thenAnswer(
        (_) => Stream.value(Right([mockCard1])),
      );
      await cardViewModel.addCard(1, 'Success', 'Success');

      // Assert
      expect(cardViewModel.error, null);
    });
  });
}
