# Architecture de l'Application Ariba

## Vue d'Ensemble

Ariba suit les principes de la **Clean Architecture** proposée par Uncle Bob (Robert C. Martin), garantissant une séparation claire des responsabilités et une maintenabilité optimale.

## Principes Architecturaux

### 1. Indépendance des Frameworks
- L'architecture ne dépend pas de l'existence d'une bibliothèque particulière
- Le framework Flutter sert d'outil de livraison, pas de contrainte architecturale

### 2. Testabilité
- La logique métier peut être testée sans UI, base de données ou serveur web
- Tests unitaires complets pour chaque couche

### 3. Indépendance de l'UI
- L'interface utilisateur peut changer facilement sans affecter le reste du système
- Possible de passer d'une UI mobile à web sans changer la logique métier

### 4. Indépendance de la Base de Données
- Possibilité de changer de SQLite vers PostgreSQL, MongoDB ou autre
- Les entités métier ne sont pas liées au stockage

## Structure des Couches

### Domain Layer (Couche Domaine)
```
lib/domain/
├── entities/           # Entités métier pures
│   ├── card.dart
│   ├── deck.dart
│   ├── study_session.dart
│   └── performance_stats.dart
├── usecases/          # Cas d'usage métier
│   ├── deck/
│   │   ├── create_deck.dart
│   │   ├── get_decks.dart
│   │   └── delete_deck.dart
│   ├── card/
│   │   ├── create_card.dart
│   │   ├── update_card.dart
│   │   └── get_cards_for_study.dart
│   └── study/
│       ├── start_study_session.dart
│       ├── record_answer.dart
│       └── calculate_next_review.dart
└── repositories/      # Interfaces des repositories
    ├── deck_repository.dart
    ├── card_repository.dart
    └── performance_repository.dart
```

**Responsabilités :**
- Définit les entités métier (Card, Deck, StudySession)
- Contient la logique métier pure dans les use cases
- Définit les contrats (interfaces) pour les repositories
- Aucune dépendance externe

### Data Layer (Couche Données)
```
lib/data/
├── database/          # Configuration base de données
│   ├── app_database.dart
│   ├── tables/
│   │   ├── cards_table.dart
│   │   ├── decks_table.dart
│   │   └── study_sessions_table.dart
│   └── migrations/
├── repositories/      # Implémentation des repositories
│   ├── deck_repository_impl.dart
│   ├── card_repository_impl.dart
│   └── performance_repository_impl.dart
├── mappers/          # Conversion modèles DB ↔ Entités
│   ├── card_mapper.dart
│   ├── deck_mapper.dart
│   └── study_session_mapper.dart
└── models/           # Modèles de données (DTOs)
    ├── card_model.dart
    ├── deck_model.dart
    └── study_session_model.dart
```

**Responsabilités :**
- Implémente les interfaces définies dans le Domain
- Gère la persistance des données avec Drift/SQLite
- Convertit entre modèles de données et entités métier
- Gère les migrations de base de données

### Presentation Layer (Couche Présentation)
```
lib/ui/               # Interface utilisateur
├── screens/          # Écrans de l'application
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── widgets/
│   ├── deck/
│   │   ├── deck_list_screen.dart
│   │   ├── deck_detail_screen.dart
│   │   ├── create_deck_screen.dart
│   │   └── widgets/
│   ├── study/
│   │   ├── study_mode_selection_screen.dart
│   │   ├── quiz_screen.dart
│   │   ├── speed_round_screen.dart
│   │   ├── matching_game_screen.dart
│   │   └── widgets/
│   └── settings/
│       ├── settings_screen.dart
│       ├── theme_settings_screen.dart
│       └── performance_settings_screen.dart
├── components/       # Composants réutilisables
│   ├── card_widget.dart
│   ├── deck_card.dart
│   ├── progress_indicator.dart
│   └── theme_selector.dart
└── themes/          # Définitions des thèmes
    ├── app_theme.dart
    ├── color_schemes.dart
    └── text_styles.dart

lib/viewmodels/       # ViewModels (Provider)
├── deck_viewmodel.dart
├── card_viewmodel.dart
├── study_viewmodel.dart
├── performance_viewmodel.dart
└── theme_viewmodel.dart
```

**Responsabilités :**
- Gère l'affichage et les interactions utilisateur
- ViewModels coordonnent entre UI et Use Cases
- Gestion d'état avec Provider
- Widgets réutilisables et thématisation

### Services Layer (Couche Services)
```
lib/services/
├── theme_service.dart         # Gestion des thèmes
├── performance_service.dart   # Optimisations performance
├── media_service.dart         # Gestion médias
├── import_export_service.dart # Import/Export données
├── notification_service.dart  # Notifications
└── analytics_service.dart     # Collecte métriques
```

**Responsabilités :**
- Services transversaux de l'application
- Gestion des préférences utilisateur
- Optimisations de performance
- Gestion des médias et notifications

### Core Layer (Couche Noyau)
```
lib/core/
├── constants/        # Constantes globales
│   ├── app_constants.dart
│   └── theme_constants.dart
├── utils/           # Utilitaires
│   ├── date_utils.dart
│   ├── validation_utils.dart
│   └── performance_utils.dart
├── errors/          # Gestion d'erreurs
│   ├── failures.dart
│   └── exceptions.dart
└── app_paths.dart   # Exports centralisés
```

## Flux de Données

### 1. Action Utilisateur → UI
```
User Input → Widget → ViewModel → Use Case → Repository → Database
```

### 2. Réponse Base de Données → UI
```
Database → Repository → Mapper → Entity → Use Case → ViewModel → Widget → UI Update
```

## Gestion d'État

### Provider Pattern
- **ViewModels** : Héritent de `ChangeNotifier`
- **UI** : Utilise `Consumer<T>` et `Provider.of<T>`
- **Injection** : `MultiProvider` dans le main.dart

```dart
// Exemple d'injection
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => DeckViewModel()),
    ChangeNotifierProvider(create: (_) => StudyViewModel()),
    ChangeNotifierProvider(create: (_) => ThemeViewModel()),
  ],
  child: MyApp(),
)
```

## Injection de Dépendances

### Service Locator Pattern
Utilisation de `get_it` pour l'injection de dépendances :

```dart
// Configuration dans main.dart
void configureDependencies() {
  // Repositories
  getIt.registerLazySingleton<DeckRepository>(
    () => DeckRepositoryImpl(getIt()),
  );
  
  // Use Cases
  getIt.registerLazySingleton(() => GetDecks(getIt()));
  getIt.registerLazySingleton(() => CreateDeck(getIt()));
  
  // Services
  getIt.registerLazySingleton(() => ThemeService());
}
```

## Navigation

### Go Router
Navigation déclarative avec routes typées :

```dart
// Configuration des routes
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: '/deck/:id',
          builder: (context, state) => DeckDetailScreen(
            deckId: state.params['id']!,
          ),
        ),
      ],
    ),
  ],
);
```

## Tests

### Structure des Tests
```
test/
├── unit/
│   ├── domain/
│   │   ├── entities/
│   │   └── usecases/
│   ├── data/
│   │   ├── repositories/
│   │   └── mappers/
│   └── viewmodels/
├── widget/
├── integration/
└── mocks/
```

### Stratégie de Test
1. **Tests Unitaires** : Use Cases et ViewModels
2. **Tests de Widget** : Composants UI individuels
3. **Tests d'Intégration** : Flux complets utilisateur
4. **Mocks** : Isolation des dépendances

## Principes SOLID

### Single Responsibility Principle (SRP)
- Chaque classe a une seule raison de changer
- Use Cases focalisés sur une action métier

### Open/Closed Principle (OCP)
- Extensions via interfaces et injection
- Nouveaux providers sans modification du code existant

### Liskov Substitution Principle (LSP)
- Implémentations interchangeables des repositories
- Abstraction via interfaces

### Interface Segregation Principle (ISP)
- Interfaces spécifiques et focalisées
- Pas de dépendances inutiles

### Dependency Inversion Principle (DIP)
- Dépendance vers les abstractions
- High-level modules indépendants des détails

## Avantages de cette Architecture

1. **Maintenabilité** : Code organisé et découplé
2. **Testabilité** : Isolation complète des couches
3. **Évolutivité** : Ajout de features sans impact
4. **Réutilisabilité** : Composants modulaires
5. **Performance** : Optimisations ciblées par couche

## Diagrammes

### Diagramme de Dépendances
```
┌─────────────────┐
│   Presentation  │ ─┐
└─────────────────┘  │
                     ▼
┌─────────────────┐ ┌─────────────────┐
│     Domain      │ │    Services     │
└─────────────────┘ └─────────────────┘
         ▲                   ▲
         │                   │
┌─────────────────┐         │
│      Data       │ ────────┘
└─────────────────┘
```

Cette architecture garantit une application robuste, maintenable et évolutive, parfaitement adaptée aux besoins d'une application d'apprentissage moderne.
