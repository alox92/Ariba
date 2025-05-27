import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart'; // Import UseCases
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_app/data/database.dart'; // Already imports CardsDao and DecksDao
import 'package:flashcards_app/services/performance_service.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart'; // Import for ThemeMode
import 'package:flashcards_app/services/theme_service.dart';
import 'package:provider/provider.dart'; // Import Provider package
import 'package:flashcards_app/viewmodels/deck_viewmodel.dart'; // Import DeckViewModel
import 'package:flashcards_app/domain/repositories/deck_repository.dart'; // Import DeckRepository
import 'package:flashcards_app/ui/home_screen.dart'; // Import HomeScreen

// Créer des classes de base abstraites pour les mocks
abstract class MockDatabaseBase implements Database {}

abstract class MockThemeServiceBase implements ThemeService {}

abstract class MockPerformanceServiceBase implements PerformanceService {}

// Define abstract base classes for DAOs from database.dart
abstract class MockCardsDaoBase implements CardsDao {}

abstract class MockDecksDaoBase implements DecksDao {}

// Define abstract base class for DeckRepository
abstract class MockDeckRepositoryBase implements DeckRepository {}

// Define abstract base classes for UseCases
abstract class MockGetDecksUseCaseBase implements GetDecksUseCase {}
abstract class MockGetDeckByIdUseCaseBase implements GetDeckByIdUseCase {}
abstract class MockAddDeckUseCaseBase implements AddDeckUseCase {}
abstract class MockUpdateDeckUseCaseBase implements UpdateDeckUseCase {}
abstract class MockDeleteDeckUseCaseBase implements DeleteDeckUseCase {}

// Définir les mocks qui étendent les classes abstraites
class MockDatabase extends Mock implements MockDatabaseBase {
  @override
  CardsDao get cardsDao =>
      super.noSuchMethod(Invocation.getter(#cardsDao),
          returnValueForMissingStub: MockCardsDao()) ??
      MockCardsDao();

  @override
  DecksDao get decksDao =>
      super.noSuchMethod(Invocation.getter(#decksDao),
          returnValueForMissingStub: MockDecksDao()) ??
      MockDecksDao();
}

class MockThemeService extends Mock implements MockThemeServiceBase {
  @override
  ThemeMode get themeMode =>
      super.noSuchMethod(Invocation.getter(#themeMode),
          returnValueForMissingStub: ThemeMode.system) ??
      ThemeMode.system;

  @override
  ThemeData getThemeData({required Brightness brightness}) =>
      super.noSuchMethod(
          Invocation.method(#getThemeData, [], {#brightness: brightness}),
          returnValueForMissingStub: ThemeData.light(),
          returnValue: ThemeData
              .light() // Ensure a non-null ThemeData is always returned
          ) ??
      ThemeData.light(); // Fallback to ThemeData.light()
}

class MockPerformanceService extends Mock
    implements MockPerformanceServiceBase {
  // Add a getter that can be stubbed
  @override
  ValueNotifier<ThemeMode> get themeModeNotifier => super.noSuchMethod(
        Invocation.getter(#themeModeNotifier),
        returnValue: ValueNotifier(ThemeMode.system),
        returnValueForMissingStub: ValueNotifier(ThemeMode.system),
      );

  // Add a getter for optimizationEnabled that can be stubbed
  @override
  bool get optimizationEnabled => super.noSuchMethod(
        Invocation.getter(#optimizationEnabled),
        returnValue: true, // Default stub value
        returnValueForMissingStub: true, // Default stub value for missing stub
      );
}

// Define mock DAO classes
class MockCardsDao extends Mock implements MockCardsDaoBase {}

class MockDecksDao extends Mock implements MockDecksDaoBase {
  @override
  Stream<List<DeckEntityData>> watchAllDecks() =>
      super.noSuchMethod(
        Invocation.method(#watchAllDecks, []),
        returnValue: Stream.value(<DeckEntityData>[]),
        returnValueForMissingStub: Stream.value(<DeckEntityData>[]),
      ) ??
      Stream.value(<DeckEntityData>[]); // Fallback
}

// Define MockDeckRepository
class MockDeckRepository extends Mock implements MockDeckRepositoryBase {
  @override
  Stream<Either<Failure, List<Deck>>> watchDecks() => super.noSuchMethod(
        Invocation.method(#watchDecks, []),
        returnValue: Stream.value(Right<Failure, List<Deck>>([])),
        returnValueForMissingStub: Stream.value(Right<Failure, List<Deck>>([])),
      ) ??
      Stream.value(Right<Failure, List<Deck>>([]));
}

// Define Mock UseCases
class MockGetDecksUseCase extends Mock implements MockGetDecksUseCaseBase {
  @override
  Stream<Either<Failure, List<Deck>>> call() => super.noSuchMethod(
        Invocation.method(#call, []),
        returnValue: Stream.value(Right<Failure, List<Deck>>([])),
        returnValueForMissingStub: Stream.value(Right<Failure, List<Deck>>([])),
      ) ?? Stream.value(Right<Failure, List<Deck>>([]));
}
class MockGetDeckByIdUseCase extends Mock implements MockGetDeckByIdUseCaseBase {}
class MockAddDeckUseCase extends Mock implements MockAddDeckUseCaseBase {}
class MockUpdateDeckUseCase extends Mock implements MockUpdateDeckUseCaseBase {}
class MockDeleteDeckUseCase extends Mock implements MockDeleteDeckUseCaseBase {}

void main() {
  TestWidgetsFlutterBinding
      .ensureInitialized(); // Ensure bindings are initialized

  testWidgets('Home screen test', (WidgetTester tester) async {
    final database = MockDatabase();
    final performanceService = MockPerformanceService();
    final themeService = MockThemeService();
    final decksDao = MockDecksDao(); 
    final deckRepository = MockDeckRepository(); 

    // Instantiate Mock UseCases
    final getDecksUseCase = MockGetDecksUseCase();
    final getDeckByIdUseCase = MockGetDeckByIdUseCase();
    final addDeckUseCase = MockAddDeckUseCase();
    final updateDeckUseCase = MockUpdateDeckUseCase();
    final deleteDeckUseCase = MockDeleteDeckUseCase();

    // Stub the themeModeNotifier getter for PerformanceService mock
    when(performanceService.themeModeNotifier)
        .thenReturn(ValueNotifier(ThemeMode.system));
    when(performanceService.optimizationEnabled)
        .thenReturn(true); // Add other necessary stubs

    // Stub themeService.themeMode
    when(themeService.themeMode).thenReturn(ThemeMode.system);
    // Explicitly stub getThemeData for both Brightness.light and Brightness.dark
    when(themeService.getThemeData(brightness: Brightness.light))
        .thenReturn(ThemeData.light());
    when(themeService.getThemeData(brightness: Brightness.dark))
        .thenReturn(ThemeData.dark());

    // Stub the decksDao getter for the Database mock
    when(database.decksDao).thenReturn(decksDao);

    // Stub the watchAllDecks method for the DecksDao mock (used by DeckRepository)
    when(decksDao.watchAllDecks())
        .thenAnswer((_) => Stream.value(<DeckEntityData>[]));

    // Stub the watchDecks method for the DeckRepository mock (used by GetDecksUseCase)
    when(deckRepository.watchDecks())
        .thenAnswer((_) => Stream.value(Right<Failure, List<Deck>>([])));    // Stub the call method for GetDecksUseCase
    when(getDecksUseCase.call()) // Stream return expected  
        .thenAnswer((_) => deckRepository.watchDecks());

    // Create ViewModel instance
    final deckViewModel = DeckViewModel(
        getDecksUseCase, 
        getDeckByIdUseCase, 
        addDeckUseCase, 
        updateDeckUseCase, 
        deleteDeckUseCase, 
        database // Added database back as the last argument
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Database>.value(value: database),
          Provider<DeckRepository>.value(value: deckRepository),
          ChangeNotifierProvider<DeckViewModel>.value(value: deckViewModel),
          Provider<PerformanceService>.value(value: performanceService),
          ChangeNotifierProvider<ThemeService>.value(value: themeService),
        ],
        // Pump MaterialApp directly with HomeScreen to isolate it
        child: MaterialApp(
          theme: themeService.getThemeData(brightness: Brightness.light),
          darkTheme: themeService.getThemeData(brightness: Brightness.dark),
          themeMode: themeService.themeMode,
          home: const HomeScreen(),
        ),
      ),
    );

    // Now explicitly load data and wait
    await deckViewModel.loadDecks();
    await tester.pumpAndSettle();

    // Add debugDumpApp to see the widget tree
    debugDumpApp();

    // Vérifier la présence du titre de l'application
    expect(find.text('Mes Paquets'), findsOneWidget);
  });
}
