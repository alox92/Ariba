# Référence API - Ariba

## Vue d'Ensemble

Cette documentation présente l'API interne de l'application Ariba, organisée selon l'architecture Clean Architecture. Elle détaille les interfaces, méthodes et modèles de données utilisés dans l'application.

## Structure de l'API

### Couche Domain (Métier)

#### Entités

##### Card Entity
```dart
/// Représente une carte flash dans le système
class Card extends Equatable {
  /// Identifiant unique de la carte
  final String id;
  
  /// Identifiant du deck parent
  final String deckId;
  
  /// Contenu du recto de la carte
  final String front;
  
  /// Contenu du verso de la carte
  final String back;
  
  /// Chemin vers l'image associée (optionnel)
  final String? imagePath;
  
  /// Chemin vers l'audio associé (optionnel)
  final String? audioPath;
  
  /// Niveau de difficulté (0-10)
  final int difficulty;
  
  /// Date de la prochaine révision
  final DateTime? nextReview;
  
  /// Date de création
  final DateTime createdAt;
  
  /// Date de dernière modification
  final DateTime updatedAt;

  const Card({
    required this.id,
    required this.deckId,
    required this.front,
    required this.back,
    this.imagePath,
    this.audioPath,
    this.difficulty = 0,
    this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie de la carte avec les modifications spécifiées
  Card copyWith({
    String? id,
    String? deckId,
    String? front,
    String? back,
    String? imagePath,
    String? audioPath,
    int? difficulty,
    DateTime? nextReview,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  List<Object?> get props => [
    id, deckId, front, back, imagePath, audioPath,
    difficulty, nextReview, createdAt, updatedAt
  ];
}
```

##### Deck Entity
```dart
/// Représente un paquet de cartes
class Deck extends Equatable {
  /// Identifiant unique du deck
  final String id;
  
  /// Nom du deck
  final String name;
  
  /// Description du deck (optionnelle)
  final String? description;
  
  /// Couleur associée au deck
  final String? color;
  
  /// Nombre de cartes dans le deck
  final int cardCount;
  
  /// Date de création
  final DateTime createdAt;
  
  /// Date de dernière modification
  final DateTime updatedAt;

  const Deck({
    required this.id,
    required this.name,
    this.description,
    this.color,
    this.cardCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Crée une copie du deck avec les modifications spécifiées
  Deck copyWith({
    String? id,
    String? name,
    String? description,
    String? color,
    int? cardCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  List<Object?> get props => [
    id, name, description, color, cardCount, createdAt, updatedAt
  ];
}
```

##### StudySession Entity
```dart
/// Représente une session d'étude
class StudySession extends Equatable {
  /// Identifiant unique de la session
  final String id;
  
  /// Identifiant du deck étudié
  final String deckId;
  
  /// Type de session d'étude
  final StudyMode mode;
  
  /// Date de début de la session
  final DateTime startTime;
  
  /// Date de fin de la session (optionnelle)
  final DateTime? endTime;
  
  /// Nombre de cartes étudiées
  final int cardsStudied;
  
  /// Nombre de réponses correctes
  final int correctAnswers;
  
  /// Score de la session (0-100)
  final double score;

  const StudySession({
    required this.id,
    required this.deckId,
    required this.mode,
    required this.startTime,
    this.endTime,
    this.cardsStudied = 0,
    this.correctAnswers = 0,
    this.score = 0.0,
  });

  /// Durée de la session en millisecondes
  int? get duration => endTime?.difference(startTime).inMilliseconds;
  
  /// Pourcentage de réussite
  double get accuracy => cardsStudied > 0 ? (correctAnswers / cardsStudied) * 100 : 0.0;

  @override
  List<Object?> get props => [
    id, deckId, mode, startTime, endTime, cardsStudied, correctAnswers, score
  ];
}
```

##### PerformanceStats Entity
```dart
/// Statistiques de performance de l'utilisateur
class PerformanceStats extends Equatable {
  /// Identifiant du deck (optionnel pour stats globales)
  final String? deckId;
  
  /// Nombre total de cartes étudiées
  final int totalCardsStudied;
  
  /// Nombre total de sessions
  final int totalSessions;
  
  /// Temps total d'étude (en millisecondes)
  final int totalStudyTime;
  
  /// Taux de réussite global (0-100)
  final double averageAccuracy;
  
  /// Score moyen
  final double averageScore;
  
  /// Cartes par niveau de difficulté
  final Map<int, int> cardsByDifficulty;
  
  /// Date de dernière mise à jour
  final DateTime lastUpdated;

  const PerformanceStats({
    this.deckId,
    this.totalCardsStudied = 0,
    this.totalSessions = 0,
    this.totalStudyTime = 0,
    this.averageAccuracy = 0.0,
    this.averageScore = 0.0,
    this.cardsByDifficulty = const {},
    required this.lastUpdated,
  });

  /// Temps moyen par carte (en millisecondes)
  double get averageTimePerCard => 
      totalCardsStudied > 0 ? totalStudyTime / totalCardsStudied : 0.0;

  @override
  List<Object?> get props => [
    deckId, totalCardsStudied, totalSessions, totalStudyTime,
    averageAccuracy, averageScore, cardsByDifficulty, lastUpdated
  ];
}
```

#### Enums

```dart
/// Modes d'étude disponibles
enum StudyMode {
  quiz,
  speedRound,
  matchingGame,
  writingPractice,
}

/// Niveaux de difficulté pour les réponses
enum AnswerDifficulty {
  again,     // Incorrect - revoir immédiatement
  hard,      // Difficile - intervalle réduit
  good,      // Correct - intervalle normal
  easy,      // Facile - intervalle augmenté
}

/// Types de contenu dans une carte
enum ContentType {
  text,
  image,
  audio,
  mixed,
}
```

#### Interfaces Repository

##### DeckRepository
```dart
/// Interface pour la gestion des decks
abstract class DeckRepository {
  /// Récupère tous les decks
  /// 
  /// Returns: Liste de tous les decks
  /// Throws: [DatabaseException] en cas d'erreur
  Future<List<Deck>> getAllDecks();

  /// Récupère un deck par son ID
  /// 
  /// [id] - Identifiant du deck
  /// Returns: Le deck correspondant
  /// Throws: [NotFoundException] si le deck n'existe pas
  Future<Deck> getDeckById(String id);

  /// Sauvegarde un deck (création ou mise à jour)
  /// 
  /// [deck] - Deck à sauvegarder
  /// Returns: Le deck sauvegardé avec ID généré si nouveau
  /// Throws: [DatabaseException] en cas d'erreur
  Future<Deck> saveDeck(Deck deck);

  /// Supprime un deck
  /// 
  /// [id] - Identifiant du deck à supprimer
  /// Throws: [NotFoundException] si le deck n'existe pas
  Future<void> deleteDeck(String id);

  /// Recherche des decks par nom
  /// 
  /// [query] - Terme de recherche
  /// Returns: Liste des decks correspondants
  Future<List<Deck>> searchDecks(String query);

  /// Met à jour le nombre de cartes d'un deck
  /// 
  /// [deckId] - Identifiant du deck
  /// [count] - Nouveau nombre de cartes
  Future<void> updateCardCount(String deckId, int count);
}
```

##### CardRepository
```dart
/// Interface pour la gestion des cartes
abstract class CardRepository {
  /// Récupère toutes les cartes d'un deck
  /// 
  /// [deckId] - Identifiant du deck
  /// Returns: Liste des cartes du deck
  Future<List<Card>> getCardsByDeckId(String deckId);

  /// Récupère une carte par son ID
  /// 
  /// [id] - Identifiant de la carte
  /// Returns: La carte correspondante
  /// Throws: [NotFoundException] si la carte n'existe pas
  Future<Card> getCardById(String id);

  /// Sauvegarde une carte
  /// 
  /// [card] - Carte à sauvegarder
  /// Returns: La carte sauvegardée
  Future<Card> saveCard(Card card);

  /// Supprime une carte
  /// 
  /// [id] - Identifiant de la carte à supprimer
  Future<void> deleteCard(String id);

  /// Récupère les cartes à réviser
  /// 
  /// [deckId] - Identifiant du deck (optionnel)
  /// [limit] - Nombre maximum de cartes (optionnel)
  /// Returns: Liste des cartes à réviser
  Future<List<Card>> getCardsForReview({String? deckId, int? limit});

  /// Met à jour la difficulté d'une carte
  /// 
  /// [cardId] - Identifiant de la carte
  /// [difficulty] - Nouvelle difficulté (0-10)
  /// [nextReview] - Prochaine date de révision
  Future<void> updateCardDifficulty(
    String cardId, 
    int difficulty, 
    DateTime? nextReview
  );

  /// Recherche des cartes par contenu
  /// 
  /// [query] - Terme de recherche
  /// [deckId] - Deck à rechercher (optionnel)
  /// Returns: Liste des cartes correspondantes
  Future<List<Card>> searchCards(String query, {String? deckId});
}
```

##### PerformanceRepository
```dart
/// Interface pour la gestion des performances
abstract class PerformanceRepository {
  /// Sauvegarde une session d'étude
  /// 
  /// [session] - Session à sauvegarder
  /// Returns: La session sauvegardée
  Future<StudySession> saveStudySession(StudySession session);

  /// Récupère les sessions d'un deck
  /// 
  /// [deckId] - Identifiant du deck
  /// [limit] - Nombre maximum de sessions (optionnel)
  /// Returns: Liste des sessions
  Future<List<StudySession>> getSessionsByDeckId(String deckId, {int? limit});

  /// Récupère les statistiques globales
  /// 
  /// Returns: Statistiques de performance globales
  Future<PerformanceStats> getGlobalStats();

  /// Récupère les statistiques d'un deck
  /// 
  /// [deckId] - Identifiant du deck
  /// Returns: Statistiques du deck
  Future<PerformanceStats> getDeckStats(String deckId);

  /// Récupère les sessions récentes
  /// 
  /// [days] - Nombre de jours à considérer
  /// Returns: Liste des sessions récentes
  Future<List<StudySession>> getRecentSessions(int days);

  /// Calcule la courbe de progression
  /// 
  /// [deckId] - Identifiant du deck (optionnel)
  /// [days] - Période en jours
  /// Returns: Points de progression (timestamp, score)
  Future<List<Map<String, dynamic>>> getProgressionCurve(
    int days, {
    String? deckId,
  });
}
```

#### Use Cases

##### GetDecks
```dart
/// Use case pour récupérer tous les decks
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

##### CreateDeck
```dart
/// Paramètres pour la création d'un deck
class CreateDeckParams extends Equatable {
  final String name;
  final String? description;
  final String? color;

  const CreateDeckParams({
    required this.name,
    this.description,
    this.color,
  });

  @override
  List<Object?> get props => [name, description, color];
}

/// Use case pour créer un nouveau deck
class CreateDeck implements UseCase<Deck, CreateDeckParams> {
  final DeckRepository repository;

  CreateDeck(this.repository);

  @override
  Future<Either<Failure, Deck>> call(CreateDeckParams params) async {
    try {
      final deck = Deck(
        id: generateUniqueId(),
        name: params.name,
        description: params.description,
        color: params.color,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final savedDeck = await repository.saveDeck(deck);
      return Right(savedDeck);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

##### StartStudySession
```dart
/// Paramètres pour démarrer une session d'étude
class StartStudySessionParams extends Equatable {
  final String deckId;
  final StudyMode mode;
  final int? cardLimit;

  const StartStudySessionParams({
    required this.deckId,
    required this.mode,
    this.cardLimit,
  });

  @override
  List<Object?> get props => [deckId, mode, cardLimit];
}

/// Use case pour démarrer une session d'étude
class StartStudySession implements UseCase<StudySession, StartStudySessionParams> {
  final PerformanceRepository performanceRepository;
  final CardRepository cardRepository;

  StartStudySession(this.performanceRepository, this.cardRepository);

  @override
  Future<Either<Failure, StudySession>> call(StartStudySessionParams params) async {
    try {
      // Vérifier qu'il y a des cartes à étudier
      final cards = await cardRepository.getCardsForReview(
        deckId: params.deckId,
        limit: params.cardLimit,
      );
      
      if (cards.isEmpty) {
        return Left(NoCardsAvailableFailure());
      }

      final session = StudySession(
        id: generateUniqueId(),
        deckId: params.deckId,
        mode: params.mode,
        startTime: DateTime.now(),
      );

      final savedSession = await performanceRepository.saveStudySession(session);
      return Right(savedSession);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
```

### Couche Presentation (ViewModels)

#### DeckViewModel
```dart
/// ViewModel pour la gestion des decks
class DeckViewModel extends ChangeNotifier {
  final GetDecks _getDecks;
  final CreateDeck _createDeck;
  final DeleteDeck _deleteDeck;
  final SearchDecks _searchDecks;

  List<Deck> _decks = [];
  List<Deck> _filteredDecks = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters
  List<Deck> get decks => _searchQuery.isEmpty ? _decks : _filteredDecks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  DeckViewModel(this._getDecks, this._createDeck, this._deleteDeck, this._searchDecks);

  /// Charge tous les decks
  Future<void> loadDecks() async {
    _setLoading(true);
    _clearError();

    final result = await _getDecks(NoParams());
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (decks) => _setDecks(decks),
    );

    _setLoading(false);
  }

  /// Crée un nouveau deck
  Future<bool> createDeck({
    required String name,
    String? description,
    String? color,
  }) async {
    _setLoading(true);
    _clearError();

    final params = CreateDeckParams(
      name: name,
      description: description,
      color: color,
    );

    final result = await _createDeck(params);
    var success = false;

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (deck) {
        _addDeck(deck);
        success = true;
      },
    );

    _setLoading(false);
    return success;
  }

  /// Recherche des decks
  Future<void> searchDecks(String query) async {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredDecks = [];
      notifyListeners();
      return;
    }

    final result = await _searchDecks(SearchDecksParams(query: query));
    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (decks) => _setFilteredDecks(decks),
    );
  }

  /// Supprime un deck
  Future<bool> deleteDeck(String deckId) async {
    _setLoading(true);
    _clearError();

    final result = await _deleteDeck(DeleteDeckParams(id: deckId));
    var success = false;

    result.fold(
      (failure) => _setError(_mapFailureToMessage(failure)),
      (_) {
        _removeDeck(deckId);
        success = true;
      },
    );

    _setLoading(false);
    return success;
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setDecks(List<Deck> decks) {
    _decks = decks;
    notifyListeners();
  }

  void _addDeck(Deck deck) {
    _decks.insert(0, deck);
    notifyListeners();
  }

  void _removeDeck(String deckId) {
    _decks.removeWhere((deck) => deck.id == deckId);
    _filteredDecks.removeWhere((deck) => deck.id == deckId);
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure:
        return 'Erreur de base de données';
      case NetworkFailure:
        return 'Erreur de connexion';
      default:
        return 'Erreur inconnue';
    }
  }
}
```

#### StudyViewModel
```dart
/// ViewModel pour les sessions d'étude
class StudyViewModel extends ChangeNotifier {
  final StartStudySession _startStudySession;
  final GetCardsForReview _getCardsForReview;
  final RecordAnswer _recordAnswer;
  final CalculateNextReview _calculateNextReview;

  StudySession? _currentSession;
  List<Card> _studyCards = [];
  int _currentCardIndex = 0;
  int _correctAnswers = 0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  StudySession? get currentSession => _currentSession;
  List<Card> get studyCards => _studyCards;
  Card? get currentCard => _currentCardIndex < _studyCards.length 
      ? _studyCards[_currentCardIndex] 
      : null;
  int get currentCardIndex => _currentCardIndex;
  int get correctAnswers => _correctAnswers;
  int get totalCards => _studyCards.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSessionComplete => _currentCardIndex >= _studyCards.length;

  StudyViewModel(
    this._startStudySession,
    this._getCardsForReview,
    this._recordAnswer,
    this._calculateNextReview,
  );

  /// Démarre une nouvelle session d'étude
  Future<bool> startSession({
    required String deckId,
    required StudyMode mode,
    int? cardLimit,
  }) async {
    _setLoading(true);
    _clearError();

    final params = StartStudySessionParams(
      deckId: deckId,
      mode: mode,
      cardLimit: cardLimit,
    );

    final sessionResult = await _startStudySession(params);
    if (sessionResult.isLeft()) {
      _setError('Impossible de démarrer la session');
      _setLoading(false);
      return false;
    }

    _currentSession = sessionResult.fold((l) => null, (r) => r);

    // Charger les cartes à étudier
    final cardsResult = await _getCardsForReview(
      GetCardsForReviewParams(deckId: deckId, limit: cardLimit),
    );

    cardsResult.fold(
      (failure) => _setError('Impossible de charger les cartes'),
      (cards) => _setStudyCards(cards),
    );

    _setLoading(false);
    return cardsResult.isRight();
  }

  /// Enregistre une réponse
  Future<void> recordAnswer(AnswerDifficulty difficulty) async {
    if (currentCard == null || _currentSession == null) return;

    final card = currentCard!;
    final isCorrect = difficulty == AnswerDifficulty.good || 
                     difficulty == AnswerDifficulty.easy;

    if (isCorrect) {
      _correctAnswers++;
    }

    // Calculer la prochaine révision
    final nextReview = await _calculateNextReview(
      CalculateNextReviewParams(
        cardId: card.id,
        difficulty: difficulty,
      ),
    );

    // Enregistrer la réponse
    await _recordAnswer(RecordAnswerParams(
      sessionId: _currentSession!.id,
      cardId: card.id,
      difficulty: difficulty,
      responseTime: DateTime.now().difference(_currentSession!.startTime),
    ));

    _moveToNextCard();
  }

  /// Passe à la carte suivante
  void _moveToNextCard() {
    if (_currentCardIndex < _studyCards.length - 1) {
      _currentCardIndex++;
      notifyListeners();
    } else {
      _completeSession();
    }
  }

  /// Termine la session
  void _completeSession() {
    if (_currentSession != null) {
      final updatedSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        cardsStudied: _studyCards.length,
        correctAnswers: _correctAnswers,
        score: (_correctAnswers / _studyCards.length) * 100,
      );
      _currentSession = updatedSession;
    }
    notifyListeners();
  }

  /// Remet à zéro la session
  void resetSession() {
    _currentSession = null;
    _studyCards = [];
    _currentCardIndex = 0;
    _correctAnswers = 0;
    _clearError();
    notifyListeners();
  }

  // Méthodes privées
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setStudyCards(List<Card> cards) {
    _studyCards = cards;
    _currentCardIndex = 0;
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

### Services

#### ThemeService
```dart
/// Service de gestion des thèmes
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'theme_color';
  
  final SharedPreferences _prefs;
  
  ThemeMode _themeMode = ThemeMode.system;
  Color _primaryColor = Colors.blue;

  ThemeMode get themeMode => _themeMode;
  Color get primaryColor => _primaryColor;

  ThemeService(this._prefs) {
    _loadPreferences();
  }

  /// Charge les préférences sauvegardées
  void _loadPreferences() {
    final themeIndex = _prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    
    final colorValue = _prefs.getInt(_colorKey) ?? Colors.blue.value;
    _primaryColor = Color(colorValue);
    
    notifyListeners();
  }

  /// Définit le mode de thème
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  /// Définit la couleur primaire
  Future<void> setPrimaryColor(Color color) async {
    _primaryColor = color;
    await _prefs.setInt(_colorKey, color.value);
    notifyListeners();
  }

  /// Génère le thème clair
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
    ),
  );

  /// Génère le thème sombre
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.dark,
    ),
  );
}
```

### Exceptions et Erreurs

#### Failures
```dart
/// Classe de base pour les échecs
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Échec de base de données
class DatabaseFailure extends Failure {
  const DatabaseFailure(String message) : super(message);
}

/// Échec de réseau
class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

/// Ressource non trouvée
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message) : super(message);
}

/// Validation échouée
class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

/// Aucune carte disponible
class NoCardsAvailableFailure extends Failure {
  const NoCardsAvailableFailure() : super('Aucune carte disponible pour l\'étude');
}
```

#### Exceptions
```dart
/// Exception de base pour l'application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message ${code != null ? '($code)' : ''}';
}

/// Exception de base de données
class DatabaseException extends AppException {
  const DatabaseException(String message, {String? code}) 
      : super(message, code: code);
}

/// Exception de validation
class ValidationException extends AppException {
  const ValidationException(String message, {String? code}) 
      : super(message, code: code);
}
```

### Utilitaires

#### Validators
```dart
/// Utilitaires de validation
class Validators {
  /// Valide le nom d'un deck
  static ValidationResult validateDeckName(String name) {
    if (name.isEmpty) {
      return ValidationResult.invalid('Le nom du deck ne peut pas être vide');
    }
    if (name.length > 100) {
      return ValidationResult.invalid('Le nom du deck ne peut pas dépasser 100 caractères');
    }
    return ValidationResult.valid();
  }

  /// Valide le contenu d'une carte
  static ValidationResult validateCardContent(String front, String back) {
    if (front.isEmpty) {
      return ValidationResult.invalid('Le recto de la carte ne peut pas être vide');
    }
    if (back.isEmpty) {
      return ValidationResult.invalid('Le verso de la carte ne peut pas être vide');
    }
    return ValidationResult.valid();
  }
}

/// Résultat de validation
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.valid() => const ValidationResult._(true, null);
  
  factory ValidationResult.invalid(String message) => 
      ValidationResult._(false, message);
}
```

#### Constants
```dart
/// Constantes de l'application
class AppConstants {
  // Base de données
  static const String databaseName = 'ariba_database.db';
  static const int databaseVersion = 1;
  
  // Sessions d'étude
  static const int defaultCardsPerSession = 20;
  static const int maxCardsPerSession = 100;
  static const Duration defaultSessionTimeout = Duration(hours: 2);
  
  // Répétition espacée
  static const double easyFactor = 2.5;
  static const double goodFactor = 1.8;
  static const double hardFactor = 0.5;
  static const Duration minimumInterval = Duration(days: 1);
  static const Duration maximumInterval = Duration(days: 365);
  
  // Interface utilisateur
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const double defaultBorderRadius = 12.0;
  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
}
```

Cette documentation API fournit une référence complète pour développer et maintenir l'application Ariba, en respectant les principes de la Clean Architecture et les meilleures pratiques Flutter.
