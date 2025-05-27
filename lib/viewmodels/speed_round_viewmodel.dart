import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';
import 'package:flashcards_app/domain/failures/failures.dart';

class SpeedRoundViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase getCardsByDeckUseCase;
  final ReviewCardUseCase reviewCardUseCase;
  final int deckId;

  // Game state
  List<Card> _cards = [];
  Card? _currentCard;
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _correctAnswers = 0;
  int _totalAnswers = 0;
  Timer? _gameTimer;
  int _timeRemaining = 60; // 60 seconds game
  bool _isGameActive = false;
  bool _isGameComplete = false;
  bool _isLoading = false;
  String? _error;

  // Bonus system
  static const int basePoints = 10;
  static const int streakBonus = 5;
  static const int streakBonusThreshold = 3;

  SpeedRoundViewModel({
    required this.getCardsByDeckUseCase,
    required this.reviewCardUseCase,
    required this.deckId,
  }) {
    _loadCards();
  }

  // Getters
  List<Card> get cards => _cards;
  Card? get currentCard => _currentCard;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get streak => _streak;
  int get bestStreak => _bestStreak;
  int get correctAnswers => _correctAnswers;
  int get totalAnswers => _totalAnswers;
  int get timeRemaining => _timeRemaining;
  bool get isGameActive => _isGameActive;
  bool get isGameComplete => _isGameComplete;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get accuracy {
    if (_totalAnswers == 0) {
      return 0.0;
    }
    return _correctAnswers / _totalAnswers;
  }String get timeDisplay {
    final minutes = _timeRemaining ~/ 60;
    final seconds = _timeRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  bool get hasCards => _cards.isNotEmpty;
  bool get hasStreakBonus => _streak >= streakBonusThreshold;

  Future<void> _loadCards() async {
    _setLoading(true);
    _clearError();

    try {
      final stream = getCardsByDeckUseCase.call(deckId);
      
      await for (final result in stream) {
        result.fold(
          (failure) => _setError('Erreur de chargement des cartes: ${_getErrorMessage(failure)}'),
          (cards) {
            _cards = List<Card>.from(cards)..shuffle(Random());
            if (_cards.isNotEmpty) {
              _currentCard = _cards[0];
              _currentIndex = 0;
            }
          },
        );
        break; // Only take the first result
      }
    } catch (e) {
      _setError('Erreur inattendue: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _shuffleCards() {
    final random = Random();
    for (int i = _cards.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      final temp = _cards[i];
      _cards[i] = _cards[j];
      _cards[j] = temp;
    }
  }  void startGame() {
    if (_cards.isEmpty) {
      return;
    }

    _isGameActive = true;
    _isGameComplete = false;
    _timeRemaining = 60;
    _score = 0;
    _streak = 0;
    _bestStreak = 0;
    _correctAnswers = 0;
    _totalAnswers = 0;
    _currentIndex = 0;
    _currentCard = _cards[0];

    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _endGame();
      }
    });
  }

  void _endGame() {
    _gameTimer?.cancel();
    _isGameActive = false;
    _isGameComplete = true;
    notifyListeners();
  }  Future<void> answerCard(bool isCorrect) async {
    if (!_isGameActive || _currentCard == null) {
      return;
    }

    _totalAnswers++;

    if (isCorrect) {
      _correctAnswers++;
      _streak++;
      if (_streak > _bestStreak) {
        _bestStreak = _streak;
      }

      // Calculate points with streak bonus
      int points = basePoints;
      if (hasStreakBonus) {
        points += streakBonus * (_streak ~/ streakBonusThreshold);
      }
      _score += points;

      // Record review with good performance
      await _recordCardReview(_currentCard!, 4);
    } else {
      _streak = 0;
      // Record review with poor performance
      await _recordCardReview(_currentCard!, 2);
    }

    _moveToNextCard();
    notifyListeners();
  }  void _moveToNextCard() {
    if (_cards.isEmpty) {
      return;
    }

    _currentIndex = (_currentIndex + 1) % _cards.length;
    _currentCard = _cards[_currentIndex];
  }
  Future<void> _recordCardReview(Card card, int performanceRating) async {
    try {
      // Convert int rating to ReviewQuality enum
      ReviewQuality quality;
      switch (performanceRating) {
        case 1:
          quality = ReviewQuality.incorrectButFamiliar;
          break;
        case 2:
          quality = ReviewQuality.incorrectEasyToRemember;
          break;
        case 3:
          quality = ReviewQuality.correctWithDifficulty;
          break;
        case 4:
          quality = ReviewQuality.correctWithHesitation;
          break;
        case 5:
          quality = ReviewQuality.perfect;
          break;
        default:
          quality = ReviewQuality.completeBlackout;
      }

      final result = await reviewCardUseCase.call(
        ReviewCardParams(
          cardId: card.id,
          quality: quality,
        )
      );
      
      result.fold(
        (failure) {
          debugPrint('Failed to record card review: ${_getErrorMessage(failure)}');
        },
        (_) {
          debugPrint('Card review recorded successfully');
        },
      );
    } catch (e) {
      debugPrint('Error recording card review: $e');
    }
  }

  void pauseGame() {
    if (_isGameActive) {
      _gameTimer?.cancel();
      _isGameActive = false;
      notifyListeners();
    }
  }

  void resumeGame() {
    if (!_isGameActive && !_isGameComplete && _timeRemaining > 0) {
      _isGameActive = true;
      _startTimer();
      notifyListeners();
    }
  }

  void restartGame() {
    _gameTimer?.cancel();
    _shuffleCards();
    startGame();
  }  void skipCard() {
    if (!_isGameActive) {
      return;
    }
    
    _totalAnswers++;
    _streak = 0;
    _moveToNextCard();
    notifyListeners();
  }  String getPerformanceMessage() {
    if (_totalAnswers == 0) {
      return 'Aucune réponse';
    }
    
    final accuracyPercent = (accuracy * 100).round();
    
    if (accuracyPercent >= 90) {
      return 'Excellent! 🌟';
    } else if (accuracyPercent >= 80) {
      return 'Très bien! 👏';
    } else if (accuracyPercent >= 70) {
      return 'Bien joué! 👍';
    } else if (accuracyPercent >= 60) {
      return 'Pas mal! 🙂';
    } else {
      return 'Continue à pratiquer! 💪';
    }
  }
  int getStarsEarned() {
    final accuracyPercent = (accuracy * 100).round();
    if (accuracyPercent >= 90 && _score >= 500) {
      return 3;
    }
    if (accuracyPercent >= 80 && _score >= 300) {
      return 2;
    }
    if (accuracyPercent >= 60 && _score >= 150) {
      return 1;
    }
    return 0;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
  String _getErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case DatabaseFailure _:
        return 'Erreur de base de données';
      case ValidationFailure _:
        return 'Erreur de validation';
      default:
        return 'Erreur inconnue';
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }
}
