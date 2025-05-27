import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Removed shared_preferences import; routing handles onboarding

import 'data/database.dart'; // Import the Database class
// Import repositories and their implementations
import 'domain/repositories/deck_repository.dart';
import 'domain/repositories/card_repository.dart';
import 'data/repositories/deck_repository_impl.dart';
import 'data/repositories/card_repository_impl.dart';

// Import Use Cases
import 'domain/usecases/deck_usecases.dart';
import 'domain/usecases/card_usecases.dart';
import 'domain/usecases/review_usecases.dart';

import 'viewmodels/deck_viewmodel.dart';
import 'viewmodels/card_viewmodel.dart';
import 'viewmodels/stats_viewmodel.dart';
// ReviewViewModel is now provided in AppRouter for its specific route
// import 'viewmodels/review_viewmodel.dart';
// Screen imports are no longer needed here, GoRouter handles them
// import 'ui/home_screen.dart';
import 'services/media_service.dart';
import 'services/import_export_service.dart';
import 'services/import_service.dart';
import 'services/performance_service.dart';
import 'services/performance_optimization_service.dart';
import 'services/memory_manager.dart';
import 'services/dependency_manager.dart';
import 'ui/animations/ui_animation_manager.dart';
import 'services/theme_service.dart'; // Import ThemeService
// import 'ui/deck_detail_screen.dart';
// import 'ui/edit_card_screen.dart';
// import 'ui/review_screen.dart';
// import 'ui/stats_screen.dart';
// import 'ui/theme_settings_screen.dart';
// import 'ui/performance_settings_screen.dart';
// import 'ui/quill_test_screen.dart';
import 'ui/theme/app_theme.dart';
import 'ui/routes/app_router.dart'; // Import the AppRouter

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = Database();
  final performanceService = PerformanceService();
  final themeService = ThemeService();
  
  // Initialize new performance services
  final performanceOptimizationService = PerformanceOptimizationService();
  final memoryManager = MemoryManager.instance;
  final dependencyManager = DependencyManager.instance;
  final animationManager = UIAnimationManager.instance;

  await Future.wait<void>([
    performanceService.initialize(),
    themeService.initialize(),
    performanceOptimizationService.initialize(),
    dependencyManager.initialize(),
  ]);
  
  // Initialize memory manager and animation manager synchronously
  memoryManager.initialize();
  animationManager.initialize(performanceOptimizationService);

  runApp(MyApp(
    database: database,
    performanceService: performanceService,
    themeService: themeService,
    performanceOptimizationService: performanceOptimizationService,
    memoryManager: memoryManager,
    dependencyManager: dependencyManager,
    animationManager: animationManager,
  ));
}

class MyApp extends StatelessWidget {
  final Database database;
  final PerformanceService performanceService;
  final ThemeService themeService;
  final PerformanceOptimizationService performanceOptimizationService;
  final MemoryManager memoryManager;
  final DependencyManager dependencyManager;
  final UIAnimationManager animationManager;

  late final CardRepository cardRepository;
  late final DeckRepository deckRepository;
  late final MediaService mediaService;
  late final ImportExportService importExportService;
  late final ImportService importService;

  // Deck Use Cases
  late final GetDecksUseCase getDecksUseCase;
  late final GetDeckByIdUseCase getDeckByIdUseCase;
  late final AddDeckUseCase addDeckUseCase;
  late final UpdateDeckUseCase updateDeckUseCase;
  late final DeleteDeckUseCase deleteDeckUseCase;

  // Card Use Cases
  late final GetCardsByDeckUseCase getCardsByDeckUseCase;
  late final AddCardUseCase addCardUseCase;
  late final UpdateCardUseCase updateCardUseCase;
  late final DeleteCardUseCase deleteCardUseCase;
  late final GetCardUseCase getCardUseCase;
  late final UpdateDeckCardCountUseCase updateDeckCardCountUseCase;

  // Review Use Cases
  late final ReviewCardUseCase reviewCardUseCase;

  MyApp({
    super.key,
    required this.database,
    required this.performanceService,
    required this.themeService,
    required this.performanceOptimizationService,
    required this.memoryManager,
    required this.dependencyManager,
    required this.animationManager,
  }): cardRepository = CardRepositoryImpl(database.cardsDao),
        deckRepository = DeckRepositoryImpl(database.decksDao),
        mediaService = MediaService(),
        importService = ImportService(database),
        importExportService = ImportExportService(database) {
    // Initialize Deck Use Cases
    getDecksUseCase = GetDecksUseCase(deckRepository);
    getDeckByIdUseCase = GetDeckByIdUseCase(deckRepository);
    addDeckUseCase = AddDeckUseCase(deckRepository);
    updateDeckUseCase = UpdateDeckUseCase(deckRepository);
    deleteDeckUseCase = DeleteDeckUseCase(deckRepository);

    // Initialize Card Use Cases
    getCardsByDeckUseCase = GetCardsByDeckUseCase(cardRepository);
    addCardUseCase = AddCardUseCase(cardRepository);
    updateCardUseCase = UpdateCardUseCase(cardRepository);
    deleteCardUseCase = DeleteCardUseCase(cardRepository);
    getCardUseCase = GetCardUseCase(cardRepository);
    updateDeckCardCountUseCase = UpdateDeckCardCountUseCase(deckRepository);

    // Initialize Review Use Cases
    reviewCardUseCase = ReviewCardUseCase(cardRepository);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(      providers: [
        Provider<Database>.value(value: database),
        Provider<DecksDao>.value(value: database.decksDao),
        Provider<CardsDao>.value(value: database.cardsDao),
        Provider<DeckRepository>.value(value: deckRepository),
        Provider<CardRepository>.value(value: cardRepository),
        Provider<MediaService>.value(value: mediaService),
        Provider<ImportExportService>.value(value: importExportService),        Provider<ImportService>.value(value: importService),
        
        // Performance Services
        Provider<PerformanceService>.value(value: performanceService),
        Provider<PerformanceOptimizationService>.value(value: performanceOptimizationService),
        Provider<MemoryManager>.value(value: memoryManager),
        Provider<DependencyManager>.value(value: dependencyManager),
        Provider<UIAnimationManager>.value(value: animationManager),
        
        // Provide Use Cases
        Provider<GetDecksUseCase>.value(value: getDecksUseCase),
        Provider<GetDeckByIdUseCase>.value(value: getDeckByIdUseCase),
        Provider<AddDeckUseCase>.value(value: addDeckUseCase),
        Provider<UpdateDeckUseCase>.value(value: updateDeckUseCase),
        Provider<DeleteDeckUseCase>.value(value: deleteDeckUseCase),
        Provider<GetCardsByDeckUseCase>.value(value: getCardsByDeckUseCase),
        Provider<AddCardUseCase>.value(value: addCardUseCase),
        Provider<UpdateCardUseCase>.value(value: updateCardUseCase),
        Provider<DeleteCardUseCase>.value(value: deleteCardUseCase),
        Provider<GetCardUseCase>.value(value: getCardUseCase),
        Provider<UpdateDeckCardCountUseCase>.value(value: updateDeckCardCountUseCase),
        Provider<ReviewCardUseCase>.value(value: reviewCardUseCase),
        
        ChangeNotifierProvider<DeckViewModel>(
          create: (context) => DeckViewModel(
            getDecksUseCase,
            getDeckByIdUseCase,
            addDeckUseCase,
            updateDeckUseCase,
            deleteDeckUseCase,
            database,
          ),
        ),
        ChangeNotifierProvider<CardViewModel>(
          create: (context) => CardViewModel(
            getCardsByDeckUseCase,
            addCardUseCase,
            updateCardUseCase,
            deleteCardUseCase,
            getCardUseCase,
            updateDeckCardCountUseCase,
            context.read<MediaService>(),
          ),
        ),
        ChangeNotifierProvider<StatsViewModel>(
          create: (context) => StatsViewModel(
            context.read<Database>(),
          ),
        ),
      ],
      child: ChangeNotifierProvider<ThemeService>.value(
        value: themeService,
        child: Consumer<ThemeService>(
          builder: (context, themeSvc, _) => MaterialApp.router(
            title: 'Flashcards App',
            theme: AppTheme.getThemeData(brightness: Brightness.light),
            darkTheme: AppTheme.getThemeData(brightness: Brightness.dark),
            themeMode: themeSvc.themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''),
              Locale('fr', ''),
            ],
            routerConfig: AppRouter.router, // Use GoRouter configuration
          ),
        ),
      ),
    );
  }

  // _generateRoute method removed
  // _errorRoute method removed
}

// _DeckDetailScreenWithProvider removed
// _EditCardScreenWithProvider removed
