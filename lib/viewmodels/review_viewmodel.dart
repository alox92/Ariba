import 'package:flutter/material.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/review_usecases.dart';

class ReviewViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;
  final ReviewCardUseCase _reviewCardUseCase;
  final int deckId;
  final bool isReverseMode;

  ReviewViewModel({
    required GetCardsByDeckUseCase getCardsByDeckUseCase,
    required ReviewCardUseCase reviewCardUseCase,
    required this.deckId,
    this.isReverseMode = false,
  }) : _getCardsByDeckUseCase = getCardsByDeckUseCase,
       _reviewCardUseCase = reviewCardUseCase {
    _loadCardsToReview();
  }

  List<domain.Card> _cardsToReview = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isSessionComplete = false;
  bool _isShowingAnswer = false;
  String? _error;

  // État pour les animations
  bool _currentCardChanged = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isSessionComplete => _isSessionComplete;
  bool get isShowingAnswer => _isShowingAnswer;
  bool get currentCardChanged => _currentCardChanged;
  domain.Card? get currentCard =>
      _cardsToReview.isNotEmpty && _currentIndex < _cardsToReview.length
          ? _cardsToReview[_currentIndex]
          : null;  // Get the front text based on mode (normal or reverse)
  String? get currentFrontText {
    final card = currentCard;
    if (card == null) {
      return null;
    }
    return isReverseMode ? card.backText : card.frontText;
  }

  // Get the back text based on mode (normal or reverse)
  String? get currentBackText {
    final card = currentCard;
    if (card == null) {
      return null;
    }
    return isReverseMode ? card.frontText : card.backText;
  }
  String? get error => _error;
  int get remainingCards => _cardsToReview.length - _currentIndex;
  Future<void> _loadCardsToReview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getCardsByDeckUseCase(deckId).first;
      result.fold(
        (failure) => _error = 'Erreur lors du chargement des cartes à réviser: ${failure.message}',
        (allCards) {
          // Include all cards for review (disable SRS date filtering during testing)
          _cardsToReview = List.from(allCards);
          _cardsToReview.shuffle();
          _currentIndex = 0;
          _isSessionComplete = _cardsToReview.isEmpty;
          _isShowingAnswer = false;
          _currentCardChanged = true;
        },
      );
    } catch (e) {
      _error = 'Erreur lors du chargement des cartes à réviser: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void showAnswer() {
    if (currentCard != null) {
      _isShowingAnswer = true;
      notifyListeners();
    }
  }
  Future<void> submitReview(int rating) async {
    if (currentCard == null || !_isShowingAnswer) {
      return;
    }

    final card = currentCard!;
    
    try {
      // Convert rating to ReviewQuality
      ReviewQuality quality;
      switch (rating) {
        case 0:
          quality = ReviewQuality.completeBlackout;
          break;
        case 1:
          quality = ReviewQuality.incorrectButFamiliar;
          break;
        case 2:
          quality = ReviewQuality.correctWithDifficulty;
          break;
        case 3:
          quality = ReviewQuality.perfect;
          break;
        default:
          quality = ReviewQuality.correctWithDifficulty;
      }

      final params = ReviewCardParams(
        cardId: card.id,
        quality: quality,
      );

      final result = await _reviewCardUseCase(params);
      result.fold(
        (failure) => _error = 'Erreur lors de la mise à jour de la carte: ${failure.message}',
        (updatedCard) {
          // Mettre à jour la carte dans la liste locale
          final index = _cardsToReview.indexWhere((c) => c.id == card.id);
          if (index != -1) {
            _cardsToReview[index] = updatedCard;
          }
          // Passer à la carte suivante
          _moveToNextCard();
        },
      );
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de la carte: $e';
      notifyListeners();
    }
  }

  void _moveToNextCard() {
    final currentCardIdBeforeMove = currentCard?.id; // Renamed for clarity

    if (_currentIndex < _cardsToReview.length - 1) {
      _currentIndex++;
      _isShowingAnswer = false; // Cacher la réponse pour la nouvelle carte

      // Vérifier si la carte a changé
      _currentCardChanged = currentCardIdBeforeMove != currentCard?.id;
      // _lastCardId = currentCard?.id; // Removed usage of _lastCardId
    } else {
      _isSessionComplete = true;
      _currentCardChanged = false;
    }

    notifyListeners();
  }

  // Réinitialiser le flag de changement après l'animation
  void resetCardChangedFlag() {
    _currentCardChanged = false;
  }

  // Réinitialiser et recharger la session de révision
  void restartSession() {
    _loadCardsToReview();
  }
}
