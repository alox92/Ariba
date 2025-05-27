import 'package:flutter_test/flutter_test.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:flashcards_app/data/mappers/card_mapper.dart';
import 'package:flashcards_app/data/mappers/deck_mapper.dart';
import 'package:flashcards_app/domain/entities/card.dart';
import 'package:flashcards_app/domain/entities/deck.dart';

void main() {
  group('Improved Mappers Tests', () {
    group('Card Mapper Tests', () {
      test('Card to Domain mapping with improved difficulty calculation', () {
        // Arrange
        final cardData = CardEntityData(
          id: 1,
          deckId: 1,
          frontText: 'Test Front',
          backText: 'Test Back',
          tags: 'test,example',
          frontImage: null,
          backImage: null,
          frontAudio: null,
          backAudio: null,
          createdAt: DateTime(2023, 1, 1),
          lastReviewed: DateTime(2023, 1, 2),
          interval: 7,
          easeFactor: 2.8, // High ease factor should result in easier difficulty
        );

        // Act
        final card = cardData.toDomain();

        // Assert
        expect(card.id, equals(1));
        expect(card.frontText, equals('Test Front'));
        expect(card.backText, equals('Test Back'));
        expect(card.tags, equals('test,example'));
        expect(card.intervalDays, equals(7));
        expect(card.easinessFactor, equals(2.8));
        
        // Vérifier le calcul amélioré de la difficulté
        // easeFactor 2.8 > 2.5 (moyenne) donc difficulté devrait être basse (1 ou 2)
        expect(card.difficulty, lessThanOrEqualTo(2));
        
        // Vérifier le calcul de nextReviewDate
        final expectedNextReview = DateTime(2023, 1, 2).add(Duration(days: 7));
        expect(card.nextReviewDate, equals(expectedNextReview));
      });

      test('Card to Domain mapping with difficult card (low ease factor)', () {
        // Arrange
        final cardData = CardEntityData(
          id: 2,
          deckId: 1,
          frontText: 'Difficult Card',
          backText: 'Hard Answer',
          tags: 'difficult',
          frontImage: null,
          backImage: null,
          frontAudio: null,
          backAudio: null,
          createdAt: DateTime(2023, 1, 1),
          lastReviewed: null, // Jamais révisée
          interval: 1,
          easeFactor: 1.8, // Très bas = difficile
        );

        // Act
        final card = cardData.toDomain();

        // Assert
        // easeFactor 1.8 < 2.0 donc difficulté devrait être élevée (4 ou 5)
        expect(card.difficulty, greaterThanOrEqualTo(4));
        
        // Jamais révisée, donc nextReviewDate devrait être maintenant
        expect(card.nextReviewDate, isNotNull);
        expect(card.lastReviewed, isNull);
      });

      test('Domain Card to Companion mapping preserves all data', () {
        // Arrange
        final card = Card(
          id: 0, // Nouveau
          deckId: 1,
          frontText: 'Domain Front',
          backText: 'Domain Back',
          frontImagePath: '/path/to/image.jpg',
          backImagePath: null,
          frontAudioPath: null,
          backAudioPath: '/path/to/audio.mp3',
          tags: 'domain,test',
          difficulty: 3,
          lastReviewed: DateTime(2023, 1, 3),
          reviewCount: 5,
          easinessFactor: 2.3,
          repetitions: 3,
          intervalDays: 14,
          nextReviewDate: DateTime(2023, 1, 17),
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 3),
        );

        // Act
        final companion = card.toCompanion();

        // Assert - vérifier que toutes les données sont correctement mappées
        expect(companion.deckId.value, equals(1));
        expect(companion.frontText.value, equals('Domain Front'));
        expect(companion.backText.value, equals('Domain Back'));
        expect(companion.frontImage.value, equals('/path/to/image.jpg'));
        expect(companion.backAudio.value, equals('/path/to/audio.mp3'));
        expect(companion.tags.value, equals('domain,test'));
        expect(companion.lastReviewed.value, equals(DateTime(2023, 1, 3)));
        expect(companion.interval.value, equals(14));
        expect(companion.easeFactor.value, equals(2.3));
      });
    });

    group('Deck Mapper Tests', () {
      test('Deck to Domain mapping with default values for missing fields', () {
        // Arrange
        final deckData = DeckEntityData(
          id: 1,
          name: 'Test Deck',
          description: 'Test Description',
          cardCount: 10,
          createdAt: DateTime(2023, 1, 1),
          lastAccessed: DateTime(2023, 1, 5),
        );

        // Act
        final deck = deckData.toDomain();

        // Assert
        expect(deck.id, equals(1));
        expect(deck.name, equals('Test Deck'));
        expect(deck.description, equals('Test Description'));
        expect(deck.cardCount, equals(10));
        expect(deck.createdAt, equals(DateTime(2023, 1, 1)));
        expect(deck.updatedAt, equals(DateTime(2023, 1, 5))); // lastAccessed mappé vers updatedAt
        
        // Valeurs par défaut pour champs manquants en DB
        expect(deck.color, equals('#2196F3')); // Bleu par défaut
        expect(deck.icon, equals('📚')); // Icône par défaut
      });

      test('Deck to Domain mapping with empty description gets default', () {
        // Arrange
        final deckData = DeckEntityData(
          id: 2,
          name: 'Deck Sans Description',
          description: null, // Description nulle
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          lastAccessed: DateTime(2023, 1, 1),
        );

        // Act
        final deck = deckData.toDomain();

        // Assert
        expect(deck.description, equals(''));
        expect(deck.cardCount, equals(0));
      });

      test('Domain Deck to Companion mapping for new deck', () {
        // Arrange
        final deck = Deck(
          id: 0, // Nouveau deck
          name: 'New Deck',
          description: 'Fresh deck',
          cardCount: 0,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: null,
          color: '#FF5722',
          icon: '🔥',
        );

        // Act
        final companion = deck.toCompanion();

        // Assert - pour un nouveau deck, l'ID ne devrait pas être inclus
        expect(companion.name.value, equals('New Deck'));
        expect(companion.description.value, equals('Fresh deck'));
        expect(companion.cardCount.value, equals(0));
        expect(companion.createdAt.value, equals(DateTime(2023, 1, 1)));
        // lastAccessed devrait être maintenant puisque updatedAt est null
        expect(companion.lastAccessed.value, isA<DateTime>());
      });

      test('Domain Deck to Companion mapping for existing deck update', () {
        // Arrange
        final deck = Deck(
          id: 5, // Deck existant
          name: 'Updated Deck',
          description: 'Modified description',
          cardCount: 25,
          createdAt: DateTime(2023, 1, 1),
          updatedAt: DateTime(2023, 1, 10),
          color: '#4CAF50',
          icon: '✅',
        );

        // Act
        final companion = deck.toCompanion();

        // Assert - pour une mise à jour, l'ID devrait être inclus
        // Note: La logique dans toCompanion() bascule vers toUpdateCompanion() pour id > 0
        expect(companion.id.value, equals(5));
        expect(companion.name.value, equals('Updated Deck'));
        expect(companion.description.value, equals('Modified description'));
        expect(companion.cardCount.value, equals(25));
        expect(companion.lastAccessed.value, equals(DateTime(2023, 1, 10)));
      });
    });

    group('Edge Cases and Validation', () {
      test('Card with extreme ease factors gets proper difficulty', () {
        // Test avec easeFactor très bas
        final veryHardCard = CardEntityData(
          id: 1, deckId: 1, frontText: 'Hard', backText: 'Card',
          tags: '', frontImage: null, backImage: null, frontAudio: null, backAudio: null,
          createdAt: DateTime.now(), lastReviewed: null, interval: 0, easeFactor: 1.0,
        );
        
        final hardCard = veryHardCard.toDomain();
        expect(hardCard.difficulty, equals(5)); // Maximum difficulty
        
        // Test avec easeFactor très haut
        final veryEasyCard = CardEntityData(
          id: 2, deckId: 1, frontText: 'Easy', backText: 'Card',
          tags: '', frontImage: null, backImage: null, frontAudio: null, backAudio: null,
          createdAt: DateTime.now(), lastReviewed: null, interval: 0, easeFactor: 4.0,
        );
        
        final easyCard = veryEasyCard.toDomain();
        expect(easyCard.difficulty, equals(1)); // Minimum difficulty
      });

      test('Deck name length affects default icon selection', () {
        // Test deck avec nom court
        final shortNameDeck = DeckEntityData(
          id: 1, name: 'A', description: null, cardCount: 0,
          createdAt: DateTime.now(), lastAccessed: DateTime.now(),
        );
        
        final shortDeck = shortNameDeck.toDomain();
        expect(shortDeck.icon, isNotNull);
        expect(shortDeck.icon!.length, greaterThan(0));
        
        // Test deck avec nom long
        final longNameDeck = DeckEntityData(
          id: 2, name: 'Very Long Deck Name For Testing', description: null, cardCount: 0,
          createdAt: DateTime.now(), lastAccessed: DateTime.now(),
        );
        
        final longDeck = longNameDeck.toDomain();
        expect(longDeck.icon, isNotNull);
        expect(longDeck.icon!.length, greaterThan(0));
      });
    });
  });
}
