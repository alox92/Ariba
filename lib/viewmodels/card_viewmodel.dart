import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flashcards_app/domain/entities/card.dart' as domain;
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/usecases/card_usecases.dart';
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';
import 'package:flashcards_app/services/media_service.dart';

class CardViewModel extends ChangeNotifier {
  final GetCardsByDeckUseCase _getCardsByDeckUseCase;
  final AddCardUseCase _addCardUseCase;
  final UpdateCardUseCase _updateCardUseCase;
  final DeleteCardUseCase _deleteCardUseCase;
  final GetCardUseCase _getCardUseCase;
  final UpdateDeckCardCountUseCase _updateDeckCardCountUseCase;
  final MediaService _mediaService;

  bool _isLoading = false;
  String? _error;
  List<domain.Card> _cards = [];
  domain.Card? _currentCard;
  int _currentIndex = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<domain.Card> get cards => _cards;
  domain.Card? get currentCard => _currentCard;
  int get currentIndex => _currentIndex;
  bool get hasNextCard => _currentIndex < _cards.length - 1;
  bool get hasPreviousCard => _currentIndex > 0;

  CardViewModel(
    this._getCardsByDeckUseCase,
    this._addCardUseCase,
    this._updateCardUseCase,
    this._deleteCardUseCase,
    this._getCardUseCase,
    this._updateDeckCardCountUseCase,
    this._mediaService,
  );

  Future<void> loadCardsForDeck(int deckId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getCardsByDeckUseCase(deckId).first;
      result.fold(
        (failure) => _error = _getFailureMessage(failure),
        (cards) => _cards = cards,
      );
    } catch (e) {
      _error = 'Erreur chargement cartes: ${e.toString()}';
      debugPrint('Error loading cards for deck: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<domain.Card?> addCard(int deckId, String frontText, String backText,
      {String? frontImagePath,
      String? backImagePath,
      String? frontAudioPath,
      String? backAudioPath,
      String? tags}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    domain.Card? addedCard;
    try {
      final params = AddCardParams(
        deckId: deckId,
        frontText: frontText,
        backText: backText,
        tags: tags,
        frontImagePath: frontImagePath,
        backImagePath: backImagePath,
        frontAudioPath: frontAudioPath,
        backAudioPath: backAudioPath,
      );

      final result = await _addCardUseCase(params);
      await result.fold(
        (failure) async => _error = _getFailureMessage(failure),
        (newCard) async {
          addedCard = newCard;
          await _updateDeckCardCountUseCase(deckId);
          await loadCardsForDeck(deckId);
        },
      );
    } catch (e) {
      _error = 'Erreur ajout carte: ${e.toString()}';
      debugPrint('Error adding card: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return addedCard;
  }

  Future<domain.Card?> addCardWithMedia(
    String frontText,
    String backText,
    int deckId, {
    String? frontImagePath,
    String? backImagePath,
    String? frontAudioPath,
    String? backAudioPath,
    String? tags,
  }) async {
    try {
      String? processedFrontImagePath = frontImagePath;
      String? processedBackImagePath = backImagePath;

      if (frontImagePath != null) {
        processedFrontImagePath = await _mediaService.processImage(frontImagePath);
      }

      if (backImagePath != null) {
        processedBackImagePath = await _mediaService.processImage(backImagePath);
      }

      return await addCard(
        deckId,
        frontText,
        backText,
        frontImagePath: processedFrontImagePath,
        backImagePath: processedBackImagePath,
        frontAudioPath: frontAudioPath,
        backAudioPath: backAudioPath,
        tags: tags,
      );
    } catch (e) {
      _error =
          "Erreur lors de l'ajout de la carte avec média: ${e.toString()}";
      debugPrint('Error adding card with media: $e');
      rethrow;
    }
  }

  Future<void> updateCard(
      int cardId, String frontText, String backText, int deckId,
      {String? frontImagePath,
      String? backImagePath,
      String? frontAudioPath,
      String? backAudioPath,
      String? tags}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get the existing card first
      final getResult = await _getCardUseCase(cardId);
      await getResult.fold(
        (failure) async => _error = _getFailureMessage(failure),
        (existingCard) async {
          final params = UpdateCardParams(
            card: existingCard,
            frontText: frontText,
            backText: backText,
            tags: tags,
            frontImagePath: frontImagePath,
            backImagePath: backImagePath,
            frontAudioPath: frontAudioPath,
            backAudioPath: backAudioPath,
          );

          final updateResult = await _updateCardUseCase(params);
          updateResult.fold(
            (failure) => _error = _getFailureMessage(failure),
            (_) => null,
          );

          await loadCardsForDeck(deckId);
        },
      );
    } catch (e) {
      _error = 'Erreur màj carte: ${e.toString()}';
      debugPrint('Error updating card: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCardWithMedia(
    int cardId,
    String frontText,
    String backText,
    String? frontImagePath,
    String? backImagePath,
    String? frontAudioPath,
    String? backAudioPath,
    int deckId,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final getResult = await _getCardUseCase(cardId);
      await getResult.fold(
        (failure) async => _error = _getFailureMessage(failure),
        (currentCard) async {
          String? finalFrontImagePath = currentCard.frontImagePath;
          if (frontImagePath != null && frontImagePath != currentCard.frontImagePath) {
            finalFrontImagePath = await _mediaService.processImage(frontImagePath);
            if (currentCard.frontImagePath != null) {
              await _mediaService.deleteMedia(currentCard.frontImagePath!);
            }
          } else if (frontImagePath == null && currentCard.frontImagePath != null) {
            await _mediaService.deleteMedia(currentCard.frontImagePath!);
            finalFrontImagePath = null;
          }

          String? finalBackImagePath = currentCard.backImagePath;
          if (backImagePath != null && backImagePath != currentCard.backImagePath) {
            finalBackImagePath = await _mediaService.processImage(backImagePath);
            if (currentCard.backImagePath != null) {
              await _mediaService.deleteMedia(currentCard.backImagePath!);
            }
          } else if (backImagePath == null && currentCard.backImagePath != null) {
            await _mediaService.deleteMedia(currentCard.backImagePath!);
            finalBackImagePath = null;
          }

          String? finalFrontAudioPath = currentCard.frontAudioPath;
          if (frontAudioPath != null && frontAudioPath != currentCard.frontAudioPath) {
            finalFrontAudioPath = await _mediaService.processAudio(frontAudioPath);
            if (currentCard.frontAudioPath != null) {
              await _mediaService.deleteMedia(currentCard.frontAudioPath!);
            }
          } else if (frontAudioPath == null && currentCard.frontAudioPath != null) {
            await _mediaService.deleteMedia(currentCard.frontAudioPath!);
            finalFrontAudioPath = null;
          }

          String? finalBackAudioPath = currentCard.backAudioPath;
          if (backAudioPath != null && backAudioPath != currentCard.backAudioPath) {
            finalBackAudioPath = await _mediaService.processAudio(backAudioPath);
            if (currentCard.backAudioPath != null) {
              await _mediaService.deleteMedia(currentCard.backAudioPath!);
            }
          } else if (backAudioPath == null && currentCard.backAudioPath != null) {
            await _mediaService.deleteMedia(currentCard.backAudioPath!);
            finalBackAudioPath = null;
          }

          await updateCard(
            cardId,
            frontText,
            backText,
            deckId,
            tags: currentCard.tags,
            frontImagePath: finalFrontImagePath,
            backImagePath: finalBackImagePath,
            frontAudioPath: finalFrontAudioPath,
            backAudioPath: finalBackAudioPath,
          );
        },
      );
    } catch (e) {
      _error = 'Erreur màj carte avec média: ${e.toString()}';
      debugPrint('Error updating card with media: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCard(int cardId, int deckId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get the card first to clean up media files
      final getResult = await _getCardUseCase(cardId);
      await getResult.fold(
        (failure) async => _error = _getFailureMessage(failure),
        (cardToDelete) async {
          final deleteResult = await _deleteCardUseCase(cardId);
          await deleteResult.fold(
            (failure) async => _error = _getFailureMessage(failure),
            (_) async {
              await _updateDeckCardCountUseCase(deckId);

              // Clean up media files
              if (cardToDelete.frontImagePath != null) {
                await _mediaService.deleteMedia(cardToDelete.frontImagePath!);
              }
              if (cardToDelete.backImagePath != null) {
                await _mediaService.deleteMedia(cardToDelete.backImagePath!);
              }
              if (cardToDelete.frontAudioPath != null) {
                await _mediaService.deleteMedia(cardToDelete.frontAudioPath!);
              }
              if (cardToDelete.backAudioPath != null) {
                await _mediaService.deleteMedia(cardToDelete.backAudioPath!);
              }

              await loadCardsForDeck(deckId);
            },
          );
        },
      );
    } catch (e) {
      _error = 'Erreur suppression carte: ${e.toString()}';
      debugPrint('Error deleting card: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void nextCard() {
    if (hasNextCard) {
      _currentIndex++;
      _currentCard = _cards[_currentIndex];
      notifyListeners();
    }
  }

  void previousCard() {
    if (hasPreviousCard) {
      _currentIndex--;
      _currentCard = _cards[_currentIndex];
      notifyListeners();
    }
  }

  void setCurrentCard(domain.Card card) {
    _currentCard = card;
    // Update index if the card exists in the cards list
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index != -1) {
      _currentIndex = index;
    }
    notifyListeners();
  }

  domain.Card? getCurrentCardAtIndex(int index) {
    if (index < 0 || index >= _cards.length) {
      return null;
    }
    return _cards[index];
  }

  Future<void> markCardAsReviewed(
    int cardId,
    int performanceRating,
    int intervalDays,
    double easinessFactor,
  ) async {
    try {
      final getResult = await _getCardUseCase(cardId);
      await getResult.fold(
        (failure) async => _error = _getFailureMessage(failure),
        (existingCard) async {
          final updatedCard = existingCard.copyWith(
            lastReviewed: DateTime.now(),
            intervalDays: intervalDays,
            easinessFactor: easinessFactor,
            reviewCount: existingCard.reviewCount + 1,
            updatedAt: DateTime.now(),
          );

          final params = UpdateCardParams(
            card: existingCard,
            frontText: updatedCard.frontText,
            backText: updatedCard.backText,
            frontImagePath: updatedCard.frontImagePath,
            backImagePath: updatedCard.backImagePath,
            frontAudioPath: updatedCard.frontAudioPath,
            backAudioPath: updatedCard.backAudioPath,
            tags: updatedCard.tags,
          );

          final updateResult = await _updateCardUseCase(params);
          updateResult.fold(
            (failure) => _error = _getFailureMessage(failure),
            (_) => null,
          );
        },
      );
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de la carte: ${e.toString()}';
      debugPrint('Error updating card: $e');
    }
  }

  String _getFailureMessage(Failure failure) {
    switch (failure) {
      case DatabaseFailure _:
        return 'Erreur de base de données: ${failure.message}';
      case ValidationFailure _:
        return 'Erreur de validation: ${failure.message}';
      default:
        return 'Erreur inconnue: ${failure.message}';
    }
  }
}
