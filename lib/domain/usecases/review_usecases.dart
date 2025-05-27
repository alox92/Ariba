import 'dart:math' as math;
import 'package:dartz/dartz.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/entities/deck_stats.dart';
import 'package:flashcards_app/domain/failures/failures.dart';
import 'package:flashcards_app/domain/repositories/card_repository.dart';
import 'package:flashcards_app/domain/usecases/usecase.dart';

/// Énumération pour les qualités de réponse dans l'algorithme SM-2
enum ReviewQuality {
  /// Réponse complètement incorrecte (0)
  completeBlackout(0),
  
  /// Réponse incorrecte mais familière (1)
  incorrectButFamiliar(1),
  
  /// Réponse incorrecte mais facile à retenir (2)
  incorrectEasyToRemember(2),
  
  /// Réponse correcte avec difficulté (3)
  correctWithDifficulty(3),
  
  /// Réponse correcte avec hésitation (4)
  correctWithHesitation(4),
  
  /// Réponse parfaite (5)
  perfect(5);

  const ReviewQuality(this.value);
  final int value;
}

/// Use Case pour réviser une carte avec l'algorithme de répétition espacée SM-2
class ReviewCardUseCase extends UseCase<Card, ReviewCardParams> {
  final CardRepository repository;

  ReviewCardUseCase(this.repository);

  @override
  Future<Either<Failure, Card>> call(ReviewCardParams params) async {
    // Validation
    if (params.cardId <= 0) {
      return Left(ValidationFailure('L\'ID de la carte doit être valide'));
    }

    // Récupérer la carte actuelle
    final cardResult = await repository.getCard(params.cardId);
    return cardResult.fold(
      (failure) => Left(failure),
      (card) async {
        // Appliquer l'algorithme SM-2
        final updatedCard = _applySM2Algorithm(card, params.quality);
        
        // Sauvegarder la carte mise à jour
        return await repository.updateCard(updatedCard);
      },
    );
  }

  /// Implémentation de l'algorithme SM-2 (SuperMemo 2)
  Card _applySM2Algorithm(Card card, ReviewQuality quality) {
    final now = DateTime.now();
    final q = quality.value;
    
    double newEasinessFactor = card.easinessFactor;
    int newRepetitions = card.repetitions;
    int newInterval = card.intervalDays;

    if (q >= 3) {
      // Réponse correcte
      if (newRepetitions == 0) {
        newInterval = 1;
      } else if (newRepetitions == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.intervalDays * newEasinessFactor).round();
      }
      newRepetitions += 1;
    } else {
      // Réponse incorrecte, recommencer
      newRepetitions = 0;
      newInterval = 1;
    }

    // Ajuster le facteur de facilité
    newEasinessFactor = newEasinessFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02));
    
    // S'assurer que le facteur de facilité ne descend pas en dessous de 1.3
    if (newEasinessFactor < 1.3) {
      newEasinessFactor = 1.3;
    }

    // Calculer la prochaine date de révision
    final nextReview = now.add(Duration(days: newInterval));

    return card.copyWith(
      easinessFactor: newEasinessFactor,
      repetitions: newRepetitions,
      intervalDays: newInterval,
      lastReviewed: now,
      nextReviewDate: nextReview,
      reviewCount: card.reviewCount + 1,
      updatedAt: now,
    );
  }
}

class ReviewCardParams {
  final int cardId;
  final ReviewQuality quality;

  ReviewCardParams({
    required this.cardId,
    required this.quality,
  });
}

/// Use Case pour obtenir les statistiques de révision d'un deck
class GetDeckStatsUseCase extends UseCase<DeckStats, int> {
  final CardRepository repository;

  GetDeckStatsUseCase(this.repository);

  @override
  Future<Either<Failure, DeckStats>> call(int deckId) async {
    if (deckId <= 0) {
      return Left(ValidationFailure('L\'ID du deck doit être valide'));
    }

    // Récupérer toutes les cartes du deck
    final cardsStream = repository.watchCardsByDeck(deckId);
    
    return cardsStream.first.then((cardsResult) {
      return cardsResult.fold(
        (failure) => Left(failure),
        (cards) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          
          int totalCards = cards.length;
          int newCards = cards.where((card) => card.repetitions == 0).length;
          int dueCards = cards.where((card) => 
            card.nextReviewDate != null && 
            (card.nextReviewDate!.isBefore(now) || card.nextReviewDate!.isAtSameMomentAs(now))
          ).length;
          int reviewedToday = cards.where((card) => 
            card.lastReviewed != null && 
            card.lastReviewed!.isAfter(today)
          ).length;

          final stats = DeckStats(
            deckId: deckId,
            totalCards: totalCards,
            newCards: newCards,
            dueCards: dueCards,
            reviewedToday: reviewedToday,
            averageEasinessFactor: totalCards > 0 
              ? cards.map((c) => c.easinessFactor).reduce((a, b) => a + b) / totalCards
              : 2.5,
            longestStreak: _calculateLongestStreak(cards),
            lastReviewDate: cards
              .where((c) => c.lastReviewed != null)
              .map((c) => c.lastReviewed!)
              .fold<DateTime?>(null, (prev, date) => 
                prev == null || date.isAfter(prev) ? date : prev),
          );

          return Right(stats);        },
      );
    });
  }

  int _calculateLongestStreak(List<Card> cards) {
    // Implémentation améliorée du calcul de la plus longue série
    if (cards.isEmpty) {
      return 0;
    }
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Trier les cartes par date de dernière révision
    final cardsWithReviews = cards
        .where((c) => c.lastReviewed != null)
        .toList()
      ..sort((a, b) => a.lastReviewed!.compareTo(b.lastReviewed!));
    
    if (cardsWithReviews.isEmpty) {
      return 0;
    }
    
    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? lastReviewDate;
    
    // Calculer la série basée sur les jours consécutifs de révision
    for (final card in cardsWithReviews) {
      final reviewDate = DateTime(
        card.lastReviewed!.year,
        card.lastReviewed!.month,
        card.lastReviewed!.day,
      );
      
      if (lastReviewDate == null) {
        currentStreak = 1;
        lastReviewDate = reviewDate;
      } else {
        final daysDifference = reviewDate.difference(lastReviewDate).inDays;
        
        if (daysDifference == 1) {
          // Jour consécutif
          currentStreak++;
        } else if (daysDifference == 0) {
          // Même jour, on continue la série
          // currentStreak reste inchangé
        } else {
          // Interruption dans la série
          longestStreak = math.max(longestStreak, currentStreak);
          currentStreak = 1;
        }
        
        lastReviewDate = reviewDate;
      }
    }
    
    // Vérifier la série finale
    longestStreak = math.max(longestStreak, currentStreak);
    
    // Vérifier si la série se poursuit jusqu'à aujourd'hui
    if (lastReviewDate != null) {
      final daysSinceLastReview = today.difference(lastReviewDate).inDays;
      if (daysSinceLastReview > 1) {
        // La série est interrompue, retourner la plus longue série passée
        return longestStreak;
      }
    }
    
    return longestStreak;
  }
}

/// Use Case pour réinitialiser les progrès d'une carte
class ResetCardProgressUseCase extends UseCase<Card, int> {
  final CardRepository repository;

  ResetCardProgressUseCase(this.repository);

  @override
  Future<Either<Failure, Card>> call(int cardId) async {
    if (cardId <= 0) {
      return Left(ValidationFailure('L\'ID de la carte doit être valide'));
    }

    final cardResult = await repository.getCard(cardId);
    return cardResult.fold(
      (failure) => Left(failure),
      (card) async {
        final resetCard = card.copyWith(
          easinessFactor: 2.5,
          intervalDays: 1,
          repetitions: 0,
          reviewCount: 0,
          lastReviewed: null,
          nextReviewDate: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        return await repository.updateCard(resetCard);
      },
    );
  }
}
