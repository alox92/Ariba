import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';

class QuizQuestion {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex;
  final domain.Card card;

  QuizQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
    required this.card,
  });
}

class QuizViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;
  final ReviewCardUseCase _reviewCardUseCase;
  final int deckId;

  QuizViewModel({
    required GetCardsByDeckUseCase getCardsByDeckUseCase,
    required ReviewCardUseCase reviewCardUseCase,
    required this.deckId,
  })  : _getCardsByDeckUseCase = getCardsByDeckUseCase,
        _reviewCardUseCase = reviewCardUseCase {
    loadQuiz();
  }

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  List<QuizQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  int _score = 0;
  bool _isQuizCompleted = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  List<QuizQuestion> get questions => _questions;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuizQuestion? get currentQuestion => 
      _questions.isEmpty ? null : _questions[_currentQuestionIndex];
  int? get selectedAnswerIndex => _selectedAnswerIndex;
  bool get hasAnswered => _hasAnswered;
  int get score => _score;
  int get totalQuestions => _questions.length;
  bool get isQuizCompleted => _isQuizCompleted;
  bool get isLastQuestion => _currentQuestionIndex >= _questions.length - 1;
  double get progress => _questions.isEmpty ? 0.0 : _currentQuestionIndex / _questions.length;
  Future<void> loadQuiz() async {
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
            
            _generateQuizQuestions(cards);
            _resetQuizState();
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

  void _generateQuizQuestions(List<domain.Card> cards) {
    final random = Random();
    final shuffledCards = List<domain.Card>.from(cards)..shuffle(random);
    
    _questions = shuffledCards.take(20).map((card) {
      // Create multiple choice question
      final correctAnswer = card.backText;
      final wrongAnswers = _generateWrongAnswers(card, cards);
      
      final allOptions = [correctAnswer, ...wrongAnswers]..shuffle(random);
      final correctIndex = allOptions.indexOf(correctAnswer);
      
      return QuizQuestion(
        questionText: card.frontText,
        options: allOptions,
        correctAnswerIndex: correctIndex,
        card: card,
      );
    }).toList();
  }

  List<String> _generateWrongAnswers(domain.Card correctCard, List<domain.Card> allCards) {
    final random = Random();
    final wrongAnswers = <String>[];
    final usedAnswers = <String>{correctCard.backText};
    
    // Try to get 3 wrong answers from other cards
    final otherCards = allCards.where((card) => card.id != correctCard.id).toList();
    otherCards.shuffle(random);    for (final card in otherCards) {
      if (wrongAnswers.length >= 3) {
        break;
      }
      if (!usedAnswers.contains(card.backText)) {
        wrongAnswers.add(card.backText);
        usedAnswers.add(card.backText);
      }
    }
    
    // If we don't have enough wrong answers, generate some generic ones
    while (wrongAnswers.length < 3) {
      final fakeAnswer = 'Option ${wrongAnswers.length + 1}';
      if (!usedAnswers.contains(fakeAnswer)) {
        wrongAnswers.add(fakeAnswer);
        usedAnswers.add(fakeAnswer);
      }
    }
    
    return wrongAnswers;
  }

  void _resetQuizState() {
    _currentQuestionIndex = 0;
    _selectedAnswerIndex = null;
    _hasAnswered = false;
    _score = 0;
    _isQuizCompleted = false;
    notifyListeners();
  }  void selectAnswer(int answerIndex) {
    if (_hasAnswered) {
      return;
    }
    
    _selectedAnswerIndex = answerIndex;
    notifyListeners();
  }  void submitAnswer() {
    if (_selectedAnswerIndex == null || _hasAnswered) {
      return;
    }
    
    _hasAnswered = true;
    
    final currentQuestion = this.currentQuestion;
    if (currentQuestion != null) {
      final isCorrect = _selectedAnswerIndex == currentQuestion.correctAnswerIndex;
      if (isCorrect) {
        _score++;
      }
      
      // Record the review result
      _recordReview(currentQuestion.card, isCorrect);
    }
    
    notifyListeners();
  }  void nextQuestion() {
    if (!_hasAnswered) {
      return;
    }
    
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
    } else {
      _isQuizCompleted = true;
    }
    
    notifyListeners();
  }

  void retryQuiz() {
    _resetQuizState();
  }
  void _recordReview(domain.Card card, bool isCorrect) {
    // Convert boolean to performance rating using ReviewQuality enum
    final quality = isCorrect ? ReviewQuality.perfect : ReviewQuality.incorrectButFamiliar;
    
    _reviewCardUseCase.call(
      ReviewCardParams(
        cardId: card.id,
        quality: quality,
      )
    ).then((result) {
      result.fold(
        (failure) {
          // Log error but don't show to user during quiz
          debugPrint('Failed to record review: ${failure.toString()}');
        },
        (_) {
          // Success - review recorded
        },
      );
    });
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
}
