# Guide du Développeur - Ariba

## Configuration de l'Environnement de Développement

### Prérequis
- **Flutter SDK** : Version 3.0 ou supérieure
- **Dart SDK** : Version 2.17 ou supérieure
- **IDE** : VS Code ou Android Studio avec plugins Flutter/Dart
- **Git** : Pour le contrôle de version
- **Android Studio** : Pour les émulateurs Android
- **Xcode** : Pour le développement iOS (macOS uniquement)

### Installation et Configuration

#### 1. Configuration Flutter
```bash
# Vérifier l'installation Flutter
flutter doctor

# Activer les plateformes nécessaires
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop
flutter config --enable-linux-desktop
```

#### 2. Configuration du Projet
```bash
# Cloner le repository
git clone https://github.com/yourusername/ariba.git
cd ariba

# Installer les dépendances
flutter pub get

# Générer les fichiers de code
flutter packages pub run build_runner build
```

#### 3. Configuration de l'IDE

**VS Code Extensions Recommandées :**
- Flutter
- Dart
- Flutter Widget Snippets
- Awesome Flutter Snippets
- Flutter Tree
- Error Lens
- GitLens

**Configuration VS Code (`settings.json`) :**
```json
{
  "dart.debugExternalPackageLibraries": true,
  "dart.debugSdkLibraries": true,
  "dart.previewFlutterUiGuides": true,
  "dart.previewFlutterUiGuidesCustomTracking": true,
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

## Structure du Projet Détaillée

### Organisation des Fichiers
```
lib/
├── core/                    # Éléments fondamentaux
│   ├── constants/          # Constantes globales
│   ├── utils/             # Utilitaires
│   ├── errors/            # Gestion d'erreurs
│   └── app_paths.dart     # Exports centralisés
├── domain/                 # Logique métier
│   ├── entities/          # Entités métier
│   ├── usecases/          # Cas d'usage
│   └── repositories/      # Interfaces repositories
├── data/                   # Accès aux données
│   ├── database/          # Base de données
│   ├── repositories/      # Implémentations
│   ├── mappers/          # Mappers entités ↔ modèles
│   └── models/           # Modèles de données
├── ui/                     # Interface utilisateur
│   ├── screens/          # Écrans
│   ├── components/       # Composants réutilisables
│   └── themes/           # Thèmes
├── viewmodels/            # ViewModels Provider
├── services/              # Services transversaux
└── main.dart              # Point d'entrée
```

## Conventions de Code

### Naming Conventions

#### Classes
```dart
// PascalCase pour les classes
class DeckViewModel extends ChangeNotifier { }
class CardRepository { }
class StudySession { }
```

#### Fichiers
```dart
// snake_case pour les fichiers
deck_view_model.dart
card_repository.dart
study_session.dart
```

#### Variables et Fonctions
```dart
// camelCase pour variables et fonctions
String deckName;
int cardCount;
void startStudySession() { }
Future<List<Card>> getCardsForReview() async { }
```

#### Constantes
```dart
// SCREAMING_SNAKE_CASE pour les constantes
const int DEFAULT_CARDS_PER_SESSION = 20;
const String DATABASE_NAME = 'ariba_database';
const Duration DEFAULT_REVIEW_INTERVAL = Duration(days: 1);
```

### Code Style

#### Import Organization
```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:io';

// 2. Flutter libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages
import 'package:provider/provider.dart';
import 'package:drift/drift.dart';

// 4. Internal imports - core
import '../core/constants/app_constants.dart';
import '../core/utils/date_utils.dart';

// 5. Internal imports - domain
import '../domain/entities/card.dart';
import '../domain/usecases/get_decks.dart';

// 6. Internal imports - data
import '../data/repositories/deck_repository_impl.dart';

// 7. Internal imports - UI
import '../ui/components/deck_card.dart';
import '../viewmodels/deck_viewmodel.dart';
```

#### Documentation
```dart
/// Service responsable de la gestion des thèmes de l'application.
/// 
/// Ce service permet de :
/// - Changer le thème de l'application (clair/sombre)
/// - Sauvegarder les préférences utilisateur
/// - Appliquer des thèmes personnalisés
/// 
/// Exemple d'utilisation :
/// ```dart
/// final themeService = ThemeService();
/// await themeService.setThemeMode(ThemeMode.dark);
/// ```
class ThemeService {
  /// Définit le mode de thème de l'application.
  /// 
  /// [themeMode] peut être [ThemeMode.light], [ThemeMode.dark] ou [ThemeMode.system]
  /// Retourne [true] si le changement a réussi, [false] sinon.
  Future<bool> setThemeMode(ThemeMode themeMode) async {
    // Implementation
  }
}
```

## Patterns de Développement

### Use Cases Pattern
```dart
// Interface générique pour tous les use cases
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

// Implémentation d'un use case
class GetDecks implements UseCase<List<Deck>, NoParams> {
  final DeckRepository repository;
  
  GetDecks(this.repository);
  
  @override
  Future<Either<Failure, List<Deck>>> call(NoParams params) async {
    try {
      final decks = await repository.getAllDecks();
      return Right(decks);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

### Repository Pattern
```dart
// Interface dans le domain
abstract class DeckRepository {
  Future<List<Deck>> getAllDecks();
  Future<Deck> getDeckById(String id);
  Future<void> saveDeck(Deck deck);
  Future<void> deleteDeck(String id);
}

// Implémentation dans data
class DeckRepositoryImpl implements DeckRepository {
  final AppDatabase database;
  final DeckMapper mapper;
  
  DeckRepositoryImpl(this.database, this.mapper);
  
  @override
  Future<List<Deck>> getAllDecks() async {
    final deckModels = await database.select(database.decks).get();
    return deckModels.map((model) => mapper.toEntity(model)).toList();
  }
}
```

### ViewModel Pattern
```dart
class DeckViewModel extends ChangeNotifier {
  final GetDecks _getDecks;
  final CreateDeck _createDeck;
  final DeleteDeck _deleteDeck;
  
  List<Deck> _decks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  List<Deck> get decks => _decks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  DeckViewModel(this._getDecks, this._createDeck, this._deleteDeck);
  
  Future<void> loadDecks() async {
    _setLoading(true);
    _clearError();
    
    final result = await _getDecks(NoParams());
    result.fold(
      (failure) => _setError(failure.message),
      (decks) => _setDecks(decks),
    );
    
    _setLoading(false);
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setDecks(List<Deck> decks) {
    _decks = decks;
    notifyListeners();
  }
  
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
```

## Base de Données avec Drift

### Définition des Tables
```dart
// Table des decks
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Table des cartes
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  IntColumn get difficulty => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextReview => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### Database Class
```dart
@DriftDatabase(tables: [Decks, Cards, StudySessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migrations futures
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'ariba_database.sqlite'));
    return NativeDatabase(file);
  });
}
```

## Tests

### Configuration des Tests
```dart
// test/helpers/test_helper.dart
class TestHelper {
  static AppDatabase createTestDatabase() {
    return AppDatabase.forTesting(NativeDatabase.memory());
  }
  
  static MockDeckRepository createMockDeckRepository() {
    return MockDeckRepository();
  }
}

// Mocks
class MockDeckRepository extends Mock implements DeckRepository {}
class MockGetDecks extends Mock implements GetDecks {}
```

### Tests Unitaires
```dart
// test/unit/viewmodels/deck_viewmodel_test.dart
void main() {
  late DeckViewModel viewModel;
  late MockGetDecks mockGetDecks;
  late MockCreateDeck mockCreateDeck;
  
  setUp(() {
    mockGetDecks = MockGetDecks();
    mockCreateDeck = MockCreateDeck();
    viewModel = DeckViewModel(mockGetDecks, mockCreateDeck);
  });
  
  group('DeckViewModel', () {
    test('should load decks successfully', () async {
      // Arrange
      final testDecks = [
        Deck(id: '1', name: 'Test Deck', description: 'Description'),
      ];
      when(mockGetDecks(any)).thenAnswer((_) async => Right(testDecks));
      
      // Act
      await viewModel.loadDecks();
      
      // Assert
      expect(viewModel.decks, equals(testDecks));
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
      verify(mockGetDecks(NoParams())).called(1);
    });
  });
}
```

### Tests de Widget
```dart
// test/widget/components/deck_card_test.dart
void main() {
  testWidgets('DeckCard displays deck information correctly', (tester) async {
    // Arrange
    final deck = Deck(
      id: '1',
      name: 'Test Deck',
      description: 'Test Description',
      cardCount: 10,
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeckCard(deck: deck),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Deck'), findsOneWidget);
    expect(find.text('Test Description'), findsOneWidget);
    expect(find.text('10 cartes'), findsOneWidget);
  });
}
```

## Scripts de Développement

### Makefile
```makefile
# Makefile pour automatiser les tâches courantes

.PHONY: help install build test clean format analyze

help: ## Affiche cette aide
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

install: ## Installe les dépendances
	flutter pub get
	flutter packages pub run build_runner build

build: ## Build l'application pour toutes les plateformes
	flutter build apk --release
	flutter build ios --release
	flutter build web --release

test: ## Lance tous les tests
	flutter test --coverage
	genhtml coverage/lcov.info -o coverage/html

clean: ## Nettoie le projet
	flutter clean
	flutter pub get

format: ## Formate le code
	dart format lib/ test/

analyze: ## Analyse le code
	flutter analyze
	dart fix --dry-run

generate: ## Génère les fichiers de code
	flutter packages pub run build_runner build --delete-conflicting-outputs

watch: ## Mode watch pour la génération de code
	flutter packages pub run build_runner watch
```

### Scripts Dart
```dart
// scripts/generate_feature.dart
import 'dart:io';

void main(List<String> arguments) {
  if (arguments.isEmpty) {
    print('Usage: dart scripts/generate_feature.dart <feature_name>');
    exit(1);
  }
  
  final featureName = arguments[0];
  generateFeature(featureName);
}

void generateFeature(String name) {
  final snakeName = toSnakeCase(name);
  final pascalName = toPascalCase(name);
  
  // Créer les dossiers
  createDirectory('lib/domain/entities');
  createDirectory('lib/domain/usecases/$snakeName');
  createDirectory('lib/data/models');
  createDirectory('lib/ui/screens/$snakeName');
  
  // Générer les fichiers de base
  generateEntity(snakeName, pascalName);
  generateUseCase(snakeName, pascalName);
  generateViewModel(snakeName, pascalName);
  generateScreen(snakeName, pascalName);
  
  print('Feature $name générée avec succès!');
}
```

## Debugging et Profiling

### Flutter Inspector
- Utiliser Flutter Inspector dans VS Code/Android Studio
- Analyser l'arbre des widgets en temps réel
- Identifier les problèmes de performance

### Profiling
```dart
// Profiling des performances
import 'dart:developer' as developer;

void expensiveOperation() {
  developer.Timeline.startSync('expensive_operation');
  try {
    // Code à profiler
  } finally {
    developer.Timeline.finishSync();
  }
}
```

### Logs Structurés
```dart
// lib/core/utils/logger.dart
import 'dart:developer' as developer;

class Logger {
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      level: 500,
      name: 'DEBUG',
      error: error,
      stackTrace: stackTrace,
    );
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      level: 1000,
      name: 'ERROR',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
```

## Bonnes Pratiques

### Performance
1. **Éviter les rebuilds inutiles** : Utiliser `const` constructeurs
2. **Optimiser les listes** : Utiliser `ListView.builder` pour les grandes listes
3. **Caching** : Implémenter un système de cache pour les données fréquemment utilisées
4. **Lazy loading** : Charger les données à la demande

### Sécurité
1. **Validation des entrées** : Toujours valider les données utilisateur
2. **Sanitisation** : Nettoyer les données avant stockage
3. **Chiffrement** : Chiffrer les données sensibles
4. **Authentification** : Implémenter une authentification robuste

### Maintenabilité
1. **Documentation** : Documenter le code complexe
2. **Tests** : Maintenir une couverture de tests élevée
3. **Refactoring** : Refactoriser régulièrement
4. **Code reviews** : Faire réviser le code par les pairs

Ce guide fournit une base solide pour développer efficacement sur le projet Ariba en respectant les meilleures pratiques Flutter et les principes d'architecture propre.
