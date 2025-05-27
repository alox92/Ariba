import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';

class WritingPracticeViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;
  final ReviewCardUseCase _reviewCardUseCase;
  final int deckId;

  WritingPracticeViewModel({
    required GetCardsByDeckUseCase getCardsByDeckUseCase,
    required ReviewCardUseCase reviewCardUseCase,
    required this.deckId,
  })  : _getCardsByDeckUseCase = getCardsByDeckUseCase,
        _reviewCardUseCase = reviewCardUseCase {
    loadCards();
  }

  // State variables
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<domain.Card> _cards = [];
  int _currentCardIndex = 0;
  String _userAnswer = '';
  bool _isAnswerSubmitted = false;
  bool _isCorrect = false;
  int _score = 0;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  bool _isSessionComplete = false;
  List<String> _hints = [];
  int _hintsUsed = 0;  Timer? _typingTimer;
  int _timeSpentSeconds = 0;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<domain.Card> get cards => _cards;
  domain.Card? get currentCard => _cards.isEmpty ? null : _cards[_currentCardIndex];
  int get currentCardIndex => _currentCardIndex;
  String get userAnswer => _userAnswer;
  bool get isAnswerSubmitted => _isAnswerSubmitted;
  bool get isCorrect => _isCorrect;
  int get score => _score;
  int get correctAnswers => _correctAnswers;
  int get totalAnswers => _totalAnswers;
  bool get isSessionComplete => _isSessionComplete;
  List<String> get hints => _hints;
  int get hintsUsed => _hintsUsed;
  int get timeSpentSeconds => _timeSpentSeconds;
  int get remainingCards => _cards.length - _currentCardIndex - 1;
  double get progress => _cards.isEmpty ? 0.0 : (_currentCardIndex + 1) / _cards.length;
  double get accuracy => _totalAnswers == 0 ? 0.0 : _correctAnswers / _totalAnswers;
  Future<void> loadCards() async {
    _setLoading(true);
    _setError(false);

    try {
      // GetCardsByDeckUseCase returns a Stream, so we listen to the first result
      _getCardsByDeckUseCase.call(deckId).first.then((result) {
        result.fold(
          (failure) {
            _setError(true, 'Failed to load cards: ${failure.toString()}');
          },
          (cards) {
            if (cards.isEmpty) {
              _setError(true, 'No cards found in this deck');
              return;
            }
            
            _cards = List.from(cards)..shuffle(Random());
            _resetSession();
            _startSession();
          },
        );
        _setLoading(false);
      }).catchError((e) {
        _setError(true, 'An unexpected error occurred: $e');
        _setLoading(false);
      });
    } catch (e) {
      _setError(true, 'An unexpected error occurred: $e');
      _setLoading(false);
    }
  }

  void _resetSession() {
    _currentCardIndex = 0;
    _userAnswer = '';
    _isAnswerSubmitted = false;
    _isCorrect = false;
    _score = 0;
    _correctAnswers = 0;
    _totalAnswers = 0;
    _isSessionComplete = false;
    _hints = [];
    _hintsUsed = 0;    _timeSpentSeconds = 0;
  }
  void _startSession() {
    _startTimer();
    _generateHints();
  }

  void _startTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeSpentSeconds++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _typingTimer?.cancel();
  }

  void updateUserAnswer(String answer) {
    if (!_isAnswerSubmitted) {
      _userAnswer = answer;
      notifyListeners();
    }
  }  void submitAnswer() {
    if (_isAnswerSubmitted || _userAnswer.trim().isEmpty) {
      return;
    }

    _isAnswerSubmitted = true;
    _totalAnswers++;

    final correctAnswer = currentCard?.backText.toLowerCase().trim() ?? '';
    final userAnswerLower = _userAnswer.toLowerCase().trim();

    // Check for exact match or close enough (allowing for minor typos)
    _isCorrect = _checkAnswerCorrectness(userAnswerLower, correctAnswer);

    if (_isCorrect) {
      _correctAnswers++;
      _score += _calculateScore();
    }

    // Review the card based on correctness
    _reviewCurrentCard();

    notifyListeners();
  }  bool _checkAnswerCorrectness(String userAnswer, String correctAnswer) {
    // Exact match
    if (userAnswer == correctAnswer) {
      return true;
    }
    
    // Allow for minor differences (case, punctuation, extra spaces)
    final cleanUser = _cleanAnswer(userAnswer);
    final cleanCorrect = _cleanAnswer(correctAnswer);
    if (cleanUser == cleanCorrect) {
      return true;
    }

    // Check for partial match (at least 80% similarity for typos)
    final similarity = _calculateSimilarity(cleanUser, cleanCorrect);
    return similarity >= 0.8;
  }

  String _cleanAnswer(String answer) {
    return answer
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }  double _calculateSimilarity(String a, String b) {
    if (a.isEmpty && b.isEmpty) {
      return 1.0;
    }
    if (a.isEmpty || b.isEmpty) {
      return 0.0;
    }

    final longer = a.length > b.length ? a : b;
    final shorter = a.length > b.length ? b : a;

    if (longer.isEmpty) {
      return 1.0;
    }

    final editDistance = _levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  int _levenshteinDistance(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;
    final matrix = List.generate(len1 + 1, (i) => List.filled(len2 + 1, 0));

    for (int i = 0; i <= len1; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= len2; j++) {
      matrix[0][j] = j;
    }

    for (int i = 1; i <= len1; i++) {
      for (int j = 1; j <= len2; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[len1][len2];
  }

  int _calculateScore() {
    int baseScore = 10;

    // Bonus for speed (if answered within 30 seconds)
    if (_timeSpentSeconds <= 30) {
      baseScore += 5;
    }

    // Penalty for using hints
    baseScore -= _hintsUsed * 2;

    // Ensure minimum score of 1
    return baseScore.clamp(1, 15);
  }

  void nextCard() {
    if (_currentCardIndex < _cards.length - 1) {
      _currentCardIndex++;
      _userAnswer = '';
      _isAnswerSubmitted = false;
      _isCorrect = false;
      _hintsUsed = 0;
      _generateHints();
      notifyListeners();
    } else {
      _completeSession();
    }
  }

  void _completeSession() {
    _isSessionComplete = true;
    _stopTimer();
    notifyListeners();
  }

  void restartSession() {
    _cards.shuffle(Random());
    _resetSession();
    _startSession();
    notifyListeners();
  }
  void _generateHints() {
    _hints.clear();
    if (currentCard == null) {
      return;
    }

    final answer = currentCard!.backText;
    
    // Hint 1: First letter
    if (answer.isNotEmpty) {
      _hints.add('Starts with: ${answer[0].toUpperCase()}');
    }

    // Hint 2: Length
    _hints.add('Length: ${answer.length} characters');

    // Hint 3: First few letters
    if (answer.length > 3) {
      final preview = answer.substring(0, (answer.length * 0.3).round());
      _hints.add('Begins with: $preview...');
    }
  }
  String? getNextHint() {
    if (_hintsUsed < _hints.length) {
      final hint = _hints[_hintsUsed];
      _hintsUsed++;
      notifyListeners();
      return hint;
    }
    return null;
  }

  void getHint() {
    getNextHint();
  }  Future<void> _reviewCurrentCard() async {
    if (currentCard == null) {
      return;
    }

    try {
      // SM-2 quality rating: 5 for perfect, 3 for correct with hints, 1 for incorrect
      ReviewQuality quality;
      if (_isCorrect) {
        quality = _hintsUsed == 0 ? ReviewQuality.perfect : ReviewQuality.correctWithDifficulty;
      } else {
        quality = ReviewQuality.incorrectButFamiliar;
      }

      await _reviewCardUseCase.call(
        ReviewCardParams(
          cardId: currentCard!.id,
          quality: quality,
        )
      );
    } catch (e) {
      debugPrint('Error reviewing card: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(bool hasError, [String? message]) {
    _hasError = hasError;
    _errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
