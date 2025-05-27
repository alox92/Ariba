import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/domain/entities/deck.dart';
import 'package:drift/drift.dart' as drift;

/// Mapper pour convertir les données de la base (DeckEntityData) vers l'entité domain (Deck)
/// 
/// DÉFIS DE MAPPING IDENTIFIÉS:
/// 1. updatedAt (domain) ↔ lastAccessed (DB) - Concepts différents mais actuellement partagés
/// 2. color et icon (domain) - Champs absents de la DB
/// 3. Pas de champ updatedAt séparé en DB pour tracking des modifications du contenu
extension DeckEntityDataToDeckMapper on DeckEntityData {
  Deck toDomain() {
    return Deck(
      id: id,
      name: name,
      description: description ?? '',
      cardCount: cardCount,
      createdAt: createdAt,
      
      // MAPPING CHALLENGE: updatedAt (domain) ↔ lastAccessed (DB)
      // Ces deux concepts sont différents mais actuellement stockés dans le même champ DB:
      // - updatedAt: dernière modification du CONTENU du deck (nom, description, etc.)
      // - lastAccessed: dernière fois que l'utilisateur a OUVERT/CONSULTÉ le deck
      // TODO: Ajouter un champ updatedAt séparé en DB
      updatedAt: lastAccessed,
      
      // MAPPING CHALLENGE: Champs visuels non stockés en DB
      // Ces champs améliorent l'UX mais nécessitent des ajouts en DB
      color: _getDefaultColor(), // TODO: Ajouter en DB pour personnalisation
      icon: _getDefaultIcon(),   // TODO: Ajouter en DB pour personnalisation
    );
  }
  /// Retourne une couleur par défaut basée sur l'ID du deck
  /// Utilisé en attendant l'ajout du champ color en DB
  String? _getDefaultColor() {
    // Couleur bleu par défaut pour tous les decks
    return '#2196F3';
  }

  /// Retourne une icône par défaut basée sur la longueur du nom
  /// Utilisé en attendant l'ajout du champ icon en DB  
  String? _getDefaultIcon() {
    // Icône livre par défaut pour tous les decks
    return '📚';
  }
}

/// Mapper pour convertir l'entité domain (Deck) vers les données de la base (DeckEntityCompanion)
/// 
/// DÉFIS DE MAPPING IDENTIFIÉS:
/// 1. updatedAt (domain) → lastAccessed (DB) - Mapping sémantique temporaire
/// 2. color et icon (domain) - Ignorés car absents de la DB
/// 3. Gestion intelligente des nouveaux vs existants decks
extension DeckToDeckEntityCompanionMapper on Deck {
  DeckEntityCompanion toCompanion() {
    // Pour les nouveaux decks (id est 0), on laisse l'ID être auto-généré
    if (id == 0) {
      return DeckEntityCompanion.insert(
        name: name,
        description: description.isNotEmpty ? drift.Value(description) : const drift.Value.absent(),
        cardCount: drift.Value(cardCount),
        createdAt: drift.Value(createdAt),
        // MAPPING: updatedAt du domain devient lastAccessed en DB
        // C'est une approximation en attendant l'ajout d'un vrai champ updatedAt
        lastAccessed: drift.Value(updatedAt ?? DateTime.now()),
      );
    } else {
      // Pour les mises à jour, utilise la méthode dédiée
      return toUpdateCompanion();
    }
  }
  
  /// Crée un companion pour mise à jour d'un deck existant
  /// 
  /// NOTE: Les champs color et icon du domain sont ignorés car non présents en DB
  DeckEntityCompanion toUpdateCompanion() {
    return DeckEntityCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      description: drift.Value(description),
      cardCount: drift.Value(cardCount),
      createdAt: drift.Value(createdAt),
      // MAPPING: updatedAt du domain devient lastAccessed en DB lors des mises à jour
      // Cette approximation sera corrigée quand un champ updatedAt sera ajouté à la DB
      lastAccessed: drift.Value(updatedAt ?? DateTime.now()),
    );
  }
}
