import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:drift/drift.dart' as drift;

extension CardEntityDataToCardMapper on CardEntityData {
  Card toDomain() {
    return Card(
      id: id,
      deckId: deckId,
      frontText: frontText,
      backText: backText,
      frontImagePath: frontImage,
      backImagePath: backImage,
      frontAudioPath: frontAudio,
      backAudioPath: backAudio,
      tags: tags.isEmpty ? null : tags, // Convertir chaîne vide en null
      createdAt: createdAt,
      
      // MAPPING CHALLENGE: updatedAt (domain) ↔ lastReviewed (DB)
      // Ces deux concepts sont différents mais actuellement stockés dans le même champ DB
      // - updatedAt: dernière modification du CONTENU de la carte
      // - lastReviewed: dernière fois que l'utilisateur a RÉVISÉ la carte
      // TODO: Ajouter un champ updatedAt séparé en DB
      updatedAt: lastReviewed, // Approximation temporaire
      
      // Champs liés au système de répétition espacée (SRS)
      lastReviewed: lastReviewed,
      easinessFactor: easeFactor,
      intervalDays: interval,
      
      // Calcul intelligent de nextReviewDate
      nextReviewDate: _calculateNextReviewDate(lastReviewed, interval.toDouble()),
      
      // MAPPING CHALLENGE: Champs non stockés en DB
      // Ces champs sont importants pour les statistiques mais nécessitent des ajouts en DB
      difficulty: _calculateDifficultyFromEaseFactor(easeFactor), // Basé sur easinessFactor plutôt qu'interval
      reviewCount: 0, // TODO: Ajouter en DB pour statistiques précises
      repetitions: 0, // TODO: Ajouter en DB pour l'algorithme SRS SM-2
    );
  }
  
  /// Calcule la prochaine date de révision basée sur la dernière révision et l'intervalle
  /// 
  /// Si lastReviewed est null (jamais révisé), retourne la date actuelle
  /// Sinon, ajoute l'intervalle en jours à la dernière révision
  static DateTime _calculateNextReviewDate(DateTime? lastReviewed, double interval) {
    if (lastReviewed == null) {
      return DateTime.now();
    }
    return lastReviewed.add(Duration(days: interval.round()));
  }  /// Calcule la difficulté basée sur le facteur de facilité (easeFactor)
  /// 
  /// Algorithme SM-2 modifié sur échelle 1-5:
  /// - easeFactor >= 3.0: Très facile (1)
  /// - easeFactor >= 2.5: Facile (2)
  /// - easeFactor >= 2.0: Moyen (3) 
  /// - easeFactor >= 1.5: Difficile (4)
  /// - easeFactor < 1.5: Très difficile (5)
  static int _calculateDifficultyFromEaseFactor(double easeFactor) {
    if (easeFactor >= 3.0) {
      return 1; // Très facile
    } else if (easeFactor >= 2.5) {
      return 2; // Facile
    } else if (easeFactor >= 2.0) {
      return 3; // Moyen
    } else if (easeFactor >= 1.5) {
      return 4; // Difficile
    } else {
      return 5; // Très difficile
    }
  }
}

extension CardToCardEntityCompanionMapper on Card {
  CardEntityCompanion toCompanion() {
    return CardEntityCompanion.insert(
      deckId: deckId,
      frontText: frontText,
      backText: backText,
      tags: drift.Value(tags ?? ''), // Null devient chaîne vide
      frontImage: frontImagePath != null ? drift.Value(frontImagePath) : const drift.Value.absent(),
      backImage: backImagePath != null ? drift.Value(backImagePath) : const drift.Value.absent(),
      frontAudio: frontAudioPath != null ? drift.Value(frontAudioPath) : const drift.Value.absent(),
      backAudio: backAudioPath != null ? drift.Value(backAudioPath) : const drift.Value.absent(),
      createdAt: drift.Value(createdAt),
      lastReviewed: lastReviewed != null ? drift.Value(lastReviewed) : const drift.Value.absent(),
      interval: drift.Value(intervalDays),
      easeFactor: drift.Value(easinessFactor),
    );
  }
  
  CardEntityCompanion toUpdateCompanion() {
    return CardEntityCompanion(
      id: drift.Value(id),
      deckId: drift.Value(deckId),
      frontText: drift.Value(frontText),
      backText: drift.Value(backText),
      tags: drift.Value(tags ?? ''), // Null devient chaîne vide
      frontImage: drift.Value(frontImagePath),
      backImage: drift.Value(backImagePath),
      frontAudio: drift.Value(frontAudioPath),
      backAudio: drift.Value(backAudioPath),
      createdAt: drift.Value(createdAt),
      // updatedAt du domain devient lastReviewed en DB lors des mises à jour
      lastReviewed: drift.Value(lastReviewed),
      interval: drift.Value(intervalDays),
      easeFactor: drift.Value(easinessFactor),
    );
  }
}
