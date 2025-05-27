import 'package:flutter/foundation.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';

class MatchingGameViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;
  final ReviewCardUseCase _reviewCardUseCase;
  final int deckId;

  MatchingGameViewModel({
    required GetCardsByDeckUseCase getCardsByDeckUseCase,
    required ReviewCardUseCase reviewCardUseCase,
    required this.deckId,
  }) : _getCardsByDeckUseCase = getCardsByDeckUseCase,
       _reviewCardUseCase = reviewCardUseCase {
    loadCards();
  }

  // State
  List<Card> _cards = [];
  List<Card> _terms = [];
  List<Card> _definitions = [];  final List<Card> _matchedTerms = [];
  final List<Card> _matchedDefinitions = [];
  Card? _selectedTerm;
  Card? _selectedDefinition;
  int _score = 0;
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _isGameStarted = false;
  bool _isGameCompleted = false;
  
  // Getters
  List<Card> get cards => _cards;
  List<Card> get terms => _terms;
  List<Card> get definitions => _definitions;
  List<Card> get matchedTerms => _matchedTerms;
  List<Card> get matchedDefinitions => _matchedDefinitions;
  Card? get selectedTerm => _selectedTerm;
  Card? get selectedDefinition => _selectedDefinition;
  int get score => _score;
  int get matchedPairs => _matchedTerms.length;
  int get totalPairs => _terms.length;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  bool get isGameStarted => _isGameStarted;
  bool get isGameCompleted => _isGameCompleted;
  double get progress => _terms.isEmpty ? 0.0 : _matchedTerms.length / _terms.length;
  Future<void> loadCards() async {
    _setLoading(true);
    _clearError();

    try {
      // GetCardsByDeckUseCase returns a Stream, so we listen to the first result
      _getCardsByDeckUseCase.call(deckId).first.then((result) {
        result.fold(
          (failure) {
            _setError('Failed to load cards: ${failure.message}');
          },
          (cards) {
            if (cards.length < 3) {
              _setError('Need at least 3 cards to play matching game');
              return;
            }
            
            _cards = cards;
            _prepareGameData();
          },
        );
        _setLoading(false);
      }).catchError((e) {
        _setError('An unexpected error occurred: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError('An unexpected error occurred: $e');
      _setLoading(false);
    }
  }

  void _prepareGameData() {
    // Take up to 8 cards for the matching game to keep it manageable
    final gameCards = _cards.take(8).toList();
    
    // Create terms and definitions lists
    _terms = List.from(gameCards)..shuffle();
    _definitions = List.from(gameCards)..shuffle();
    
    // Reset game state
    _matchedTerms.clear();
    _matchedDefinitions.clear();
    _selectedTerm = null;
    _selectedDefinition = null;
    _score = 0;
    _isGameCompleted = false;
  }  void startGame() {
    if (_cards.isEmpty) {
      return;
    }
    
    _isGameStarted = true;
    _prepareGameData();
    notifyListeners();
  }  void selectTerm(Card term) {
    if (_matchedTerms.contains(term)) {
      return;
    }
    
    _selectedTerm = term;
    _checkForAutoMatch();
    notifyListeners();
  }  void selectDefinition(Card definition) {
    if (_matchedDefinitions.contains(definition)) {
      return;
    }
    
    _selectedDefinition = definition;
    _checkForAutoMatch();
    notifyListeners();
  }

  void _checkForAutoMatch() {
    if (_selectedTerm != null && _selectedDefinition != null) {
      // Auto-check match when both are selected
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_selectedTerm != null && _selectedDefinition != null) {
          checkMatch();
        }
      });
    }
  }  void checkMatch() {
    if (_selectedTerm == null || _selectedDefinition == null) {
      return;
    }

    final isMatch = _selectedTerm!.id == _selectedDefinition!.id;
    
    if (isMatch) {
      // Correct match
      _matchedTerms.add(_selectedTerm!);
      _matchedDefinitions.add(_selectedDefinition!);
      _score += 100; // Base points for a match
      
      // Bonus points for consecutive matches
      if (_matchedTerms.length > 1) {
        _score += 25; // Bonus for building streak
      }
      
      // Review the card as correct
      _reviewCard(_selectedTerm!, true);
      
      // Check if game is completed
      if (_matchedTerms.length == _terms.length) {
        _isGameCompleted = true;
        _calculateFinalScore();
      }
    } else {
      // Incorrect match - small penalty
      _score = (_score - 10).clamp(0, double.infinity).toInt();
      
      // Review both cards as incorrect (they were confused)
      _reviewCard(_selectedTerm!, false);
      _reviewCard(_selectedDefinition!, false);
    }
    
    clearSelection();
  }

  void clearSelection() {
    _selectedTerm = null;
    _selectedDefinition = null;
    notifyListeners();
  }

  void _calculateFinalScore() {
    // Bonus for completing the game
    _score += 200;
    
    // Bonus based on accuracy
    final accuracy = _terms.isEmpty ? 0.0 : _matchedTerms.length / _terms.length;
    if (accuracy == 1.0) {
      _score += 300; // Perfect game bonus
    } else if (accuracy >= 0.8) {
      _score += 150; // Great game bonus
    } else if (accuracy >= 0.6) {
      _score += 75; // Good game bonus
    }
  }
  Future<void> _reviewCard(Card card, bool isCorrect) async {
    try {
      final quality = isCorrect ? ReviewQuality.correctWithHesitation : ReviewQuality.incorrectButFamiliar;
      await _reviewCardUseCase.call(
        ReviewCardParams(
          cardId: card.id,
          quality: quality,
        )
      );
    } catch (e) {
      // Silently handle review errors to not interrupt the game flow
      debugPrint('Failed to review card: $e');
    }
  }

  void restartGame() {
    _isGameStarted = false;
    _isGameCompleted = false;
    _prepareGameData();
    startGame();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = null;
  }
}
