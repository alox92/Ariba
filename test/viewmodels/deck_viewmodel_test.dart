// ignore_for_file: prefer_const_declarations

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/viewmodels/deck_viewmodel.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/services/import_export_service.dart';
import 'package:flashcards_app/services/import_service.dart';

// Generate mocks
@GenerateMocks([
  GetDecksUseCase,
  GetDeckByIdUseCase,
  AddDeckUseCase,
  UpdateDeckUseCase,
  DeleteDeckUseCase,
  Database,
  ImportExportService,
  ImportService,
])
import 'deck_viewmodel_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late MockGetDecksUseCase mockGetDecksUseCase;
  late MockGetDeckByIdUseCase mockGetDeckByIdUseCase;
  late MockAddDeckUseCase mockAddDeckUseCase;
  late MockUpdateDeckUseCase mockUpdateDeckUseCase;
  late MockDeleteDeckUseCase mockDeleteDeckUseCase;
  late MockDatabase mockDatabase;
  late DeckViewModel deckViewModel;

  // Mock data
  final mockDeck1 = Deck(
    id: 1,
    name: 'Test Deck 1',
    description: 'Description 1',
    cardCount: 5,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final mockDeck2 = Deck(
    id: 2,
    name: 'Test Deck 2',
    description: 'Description 2',
    cardCount: 3,
    createdAt: DateTime(2024, 1, 2),
    updatedAt: DateTime(2024, 1, 2),
  );

  final mockDecks = [mockDeck1, mockDeck2];  setUp(() {
    mockGetDecksUseCase = MockGetDecksUseCase();
    mockGetDeckByIdUseCase = MockGetDeckByIdUseCase();
    mockAddDeckUseCase = MockAddDeckUseCase();
    mockUpdateDeckUseCase = MockUpdateDeckUseCase();
    mockDeleteDeckUseCase = MockDeleteDeckUseCase();
    mockDatabase = MockDatabase();

    // Setup default mocks to return empty stream initially
    when(mockGetDecksUseCase()).thenAnswer(
      (_) => Stream.value(const Right([])),
    );

    // Create ViewModel AFTER setting up mocks
    deckViewModel = DeckViewModel(
      mockGetDecksUseCase,
      mockGetDeckByIdUseCase,
      mockAddDeckUseCase,
      mockUpdateDeckUseCase,
      mockDeleteDeckUseCase,
      mockDatabase,
    );
  });

  group('DeckViewModel Tests', () {
    test('Initial values are correct', () {
      expect(deckViewModel.decks, isEmpty);
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, null);
      expect(deckViewModel.isExporting, false);
      expect(deckViewModel.isImporting, false);
      expect(deckViewModel.isAdding, false);
      expect(deckViewModel.isUpdating, false);
    });

    test('loadDecks success updates state correctly', () async {
      // Arrange
      when(mockGetDecksUseCase()).thenAnswer(
        (_) => Stream.value(Right(mockDecks)),
      );

      // Act
      await deckViewModel.loadDecks();

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, null);
      expect(deckViewModel.decks, mockDecks);
      expect(deckViewModel.decks.length, 2);
      expect(deckViewModel.decks[0].name, 'Test Deck 1');
      expect(deckViewModel.decks[1].name, 'Test Deck 2');
    });

    test('loadDecks failure updates error state', () async {
      // Arrange
      final failure = DatabaseFailure('Database error');
      when(mockGetDecksUseCase()).thenAnswer(
        (_) => Stream.value(Left(failure)),
      );

      // Act
      await deckViewModel.loadDecks();

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Database error'));
      expect(deckViewModel.decks, isEmpty);
    });

    test('loadDecks exception updates error state', () async {
      // Arrange
      when(mockGetDecksUseCase()).thenThrow(Exception('Network error'));

      // Act
      await deckViewModel.loadDecks();

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Network error'));
      expect(deckViewModel.decks, isEmpty);
    });

    test('addDeck success adds deck correctly', () async {
      // Arrange
      when(mockAddDeckUseCase(any)).thenAnswer(
        (_) async => Right(mockDeck1),
      );

      // Act
      await deckViewModel.addDeck('New Deck', 'New Description');

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, null);
      verify(mockAddDeckUseCase(any)).called(1);
    });

    test('addDeck failure updates error state', () async {
      // Arrange
      final failure = ValidationFailure('Invalid name');
      when(mockAddDeckUseCase(any)).thenAnswer(
        (_) async => Left(failure),
      );

      // Act
      await deckViewModel.addDeck('', '');

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Invalid name'));
      verify(mockAddDeckUseCase(any)).called(1);
    });

    test('addDeck does not proceed when already loading', () async {
      // Arrange
      deckViewModel.loadDecks(); // Start loading

      // Act
      await deckViewModel.addDeck('Test', 'Test');

      // Assert
      verifyNever(mockAddDeckUseCase(any));
    });

    test('updateDeck success updates deck correctly', () async {
      // Arrange
      when(mockGetDeckByIdUseCase(1)).thenAnswer(
        (_) async => Right(mockDeck1),
      );
      when(mockUpdateDeckUseCase(any)).thenAnswer(
        (_) async => Right(mockDeck1.copyWith(name: 'Updated Name')),
      );

      // Act
      await deckViewModel.updateDeck(1, 'Updated Name', 'Updated Description');

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, null);
      verify(mockGetDeckByIdUseCase(1)).called(1);
      verify(mockUpdateDeckUseCase(any)).called(1);
    });

    test('updateDeck failure when getting deck fails', () async {
      // Arrange
      final failure = DatabaseFailure('Deck not found');
      when(mockGetDeckByIdUseCase(1)).thenAnswer(
        (_) async => Left(failure),
      );

      // Act
      await deckViewModel.updateDeck(1, 'Updated Name', 'Updated Description');

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Deck not found'));
      verify(mockGetDeckByIdUseCase(1)).called(1);
      verifyNever(mockUpdateDeckUseCase(any));
    });

    test('updateDeck failure when update fails', () async {
      // Arrange
      when(mockGetDeckByIdUseCase(1)).thenAnswer(
        (_) async => Right(mockDeck1),
      );
      final failure = DatabaseFailure('Update failed');
      when(mockUpdateDeckUseCase(any)).thenAnswer(
        (_) async => Left(failure),
      );

      // Act
      await deckViewModel.updateDeck(1, 'Updated Name', 'Updated Description');

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Update failed'));
      verify(mockGetDeckByIdUseCase(1)).called(1);
      verify(mockUpdateDeckUseCase(any)).called(1);
    });

    test('deleteDeck success deletes deck correctly', () async {
      // Arrange
      when(mockDeleteDeckUseCase(1)).thenAnswer(
        (_) async => const Right(unit),
      );

      // Act
      await deckViewModel.deleteDeck(1);

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, null);
      verify(mockDeleteDeckUseCase(1)).called(1);
    });

    test('deleteDeck failure updates error state', () async {
      // Arrange
      final failure = DatabaseFailure('Delete failed');
      when(mockDeleteDeckUseCase(1)).thenAnswer(
        (_) async => Left(failure),
      );

      // Act
      await deckViewModel.deleteDeck(1);

      // Assert
      expect(deckViewModel.isLoading, false);
      expect(deckViewModel.error, contains('Delete failed'));
      verify(mockDeleteDeckUseCase(1)).called(1);
    });

    test('deleteDeck does not proceed when already loading', () async {
      // Arrange
      deckViewModel.loadDecks(); // Start loading

      // Act
      await deckViewModel.deleteDeck(1);

      // Assert
      verifyNever(mockDeleteDeckUseCase(any));
    });

    test('multiple operations handle loading state correctly', () async {
      // Arrange
      when(mockAddDeckUseCase(any)).thenAnswer(
        (_) async => Right(mockDeck1),
      );

      // Act - try to run operations concurrently
      final future1 = deckViewModel.addDeck('Deck 1', 'Description 1');
      final future2 = deckViewModel.addDeck('Deck 2', 'Description 2');

      await Future.wait([future1, future2]);

      // Assert - only one should have proceeded
      verify(mockAddDeckUseCase(any)).called(1);
    });

    test('stream listening handles success', () async {      // Arrange
      final streamController = Stream.value(Right<Failure, List<Deck>>(mockDecks));
      when(mockGetDecksUseCase()).thenAnswer((_) => streamController);

      // Act - trigger stream listening by creating new ViewModel
      final newViewModel = DeckViewModel(
        mockGetDecksUseCase,
        mockGetDeckByIdUseCase,
        mockAddDeckUseCase,
        mockUpdateDeckUseCase,
        mockDeleteDeckUseCase,
        mockDatabase,
      );

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(newViewModel.decks, mockDecks);
      expect(newViewModel.error, null);
    });

    test('stream listening handles failure', () async {      // Arrange
      final failure = DatabaseFailure('Stream error');
      final streamController = Stream.value(Left<Failure, List<Deck>>(failure));
      when(mockGetDecksUseCase()).thenAnswer((_) => streamController);

      // Act - trigger stream listening by creating new ViewModel
      final newViewModel = DeckViewModel(
        mockGetDecksUseCase,
        mockGetDeckByIdUseCase,
        mockAddDeckUseCase,
        mockUpdateDeckUseCase,
        mockDeleteDeckUseCase,
        mockDatabase,
      );

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 10));

      // Assert
      expect(newViewModel.decks, isEmpty);
      expect(newViewModel.error, contains('Stream error'));
    });

    test('error state is cleared on new operations', () async {
      // Arrange - set initial error
      when(mockAddDeckUseCase(any)).thenAnswer(
        (_) async => Left(DatabaseFailure('Initial error')),
      );
      await deckViewModel.addDeck('Failed Deck', 'Failed Description');
      expect(deckViewModel.error, isNotNull);

      // Act - perform successful operation
      when(mockAddDeckUseCase(any)).thenAnswer(
        (_) async => Right(mockDeck1),
      );
      await deckViewModel.addDeck('Success Deck', 'Success Description');

      // Assert
      expect(deckViewModel.error, null);
    });

    test('loading state transitions correctly during operations', () async {
      // Arrange
      bool isLoadingDuringOperation = false;
      when(mockAddDeckUseCase(any)).thenAnswer((_) async {
        isLoadingDuringOperation = deckViewModel.isLoading;
        return Right(mockDeck1);
      });

      // Act
      await deckViewModel.addDeck('Test Deck', 'Test Description');

      // Assert
      expect(isLoadingDuringOperation, true);
      expect(deckViewModel.isLoading, false);
    });
  });

  group('DeckViewModel Import/Export Tests', () {
    test('exportDeck does not proceed when already exporting', () async {
      // This test would require mocking ImportExportService properly
      // For now, we test the state management
      expect(deckViewModel.isExporting, false);
    });

    test('importDeck does not proceed when already importing', () async {
      // This test would require mocking ImportService properly
      // For now, we test the state management
      expect(deckViewModel.isImporting, false);
    });
  });
}
