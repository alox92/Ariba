// FICHIER DÉPRÉCIÉ - Les définitions de tables sont maintenant dans lib/data/tables/
// Ce fichier sera supprimé car il crée des conflits avec les classes générées par Drift  
// Les vraies définitions sont dans:
// - lib/data/tables/cards.dart pour CardEntity
// - lib/data/database.g.dart pour CardEntityData (généré automatiquement)

// Classe pour représenter une carte mémoire (flashcard)
class FlashCard {
  final int id;
  final int deckId;
  final String frontText;
  final String backText;
  final String tags;
  final DateTime createdAt;
  final DateTime? lastReviewed;
  final int interval;
  final double easeFactor;
  final String? frontImage;
  final String? backImage;
  final String? frontAudio;
  final String? backAudio;

  FlashCard({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    required this.tags,
    required this.createdAt,
    this.lastReviewed,
    required this.interval,
    required this.easeFactor,
    this.frontImage,
    this.backImage,
    this.frontAudio,
    this.backAudio,
  });

  // Créer à partir d'une entité CardEntity
  // Dans ce contexte, 'entity' doit être un objet de données Drift, pas un objet Table
  factory FlashCard.fromEntity(dynamic entity) {
    return FlashCard(
      id: entity.id,
      deckId: entity.deckId,
      frontText: entity.frontText,
      backText: entity.backText,
      tags: entity.tags,
      createdAt: entity.createdAt,
      lastReviewed: entity.lastReviewed,
      interval: entity.interval,
      easeFactor: entity.easeFactor,
      frontImage: entity.frontImage,
      backImage: entity.backImage,
      frontAudio: entity.frontAudio,
      backAudio: entity.backAudio,
    );
  }
}
