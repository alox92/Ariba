import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flashcards_app/data/models/card.dart';
import 'package:flashcards_app/domain/entities/deck_with_stats.dart';

class PerformanceService {
  // Singleton
  static PerformanceService? _instance;
  static bool _disposed = false;

  factory PerformanceService() {
    if (_instance == null || _disposed) {
      _instance = PerformanceService._internal();
      _disposed = false;
    }
    return _instance!;
  }

  PerformanceService._internal();

  // ValueNotifier for ThemeMode
  late final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.system);

  // Method to update theme mode
  void updateThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  // Limites et seuils
  static const int kLargeCollectionThreshold = 500;
  static const int kVeryLargeCollectionThreshold = 2000;
  static const int kMaxImagesToCache = 100;
  static const int kBatchLoadSize = 50;

  // Cache pour les médias
  final Map<String, ImageProvider> _imageCache = {};
  Timer? _cachePurgeTimer;

  // Métriques de performance
  double _avgCardLoadTime = 0.0;
  int _cardLoadsCount = 0;

  // Statut de l'optimisation
  bool _optimizationEnabled = true;
  bool get optimizationEnabled => _optimizationEnabled;

  // Activer/désactiver les optimisations
  void setOptimizationEnabled(bool enabled) {
    _optimizationEnabled = enabled;
  }

  // Initialiser le service
  Future<void> initialize() async {
    // Démarrer le timer de nettoyage du cache
    _cachePurgeTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      _purgeCache();
    });
  }
  // Nettoyer les ressources
  void dispose() {
    _cachePurgeTimer?.cancel();
    _imageCache.clear();
    if (!_disposed) {
      themeModeNotifier.dispose(); // Dispose the notifier
      _disposed = true;
    }
  }

  // Nettoyer le cache si nécessaire
  void _purgeCache() {
    if (_imageCache.length > kMaxImagesToCache) {
      // Enlever 20% des entrées les plus anciennes
      final toRemove = (_imageCache.length * 0.2).ceil();
      final keys = _imageCache.keys.toList().sublist(0, toRemove);
      for (final key in keys) {
        _imageCache.remove(key);
      }
    }
  }

  // Vérifier si une collection est grande
  bool isLargeCollection(int itemCount) {
    return itemCount > kLargeCollectionThreshold;
  }

  // Vérifier si une collection est très grande
  bool isVeryLargeCollection(int itemCount) {
    return itemCount > kVeryLargeCollectionThreshold;
  }

  // Charger les cartes par lots pour les grandes collections
  Future<List<FlashCard>> loadCardsBatched(List<FlashCard> allCards, int offset,
      {int batchSize = kBatchLoadSize}) async {
    if (!_optimizationEnabled || allCards.length <= kLargeCollectionThreshold) {
      return allCards;
    }

    final endIndex = (offset + batchSize < allCards.length)
        ? offset + batchSize
        : allCards.length;

    return allCards.sublist(offset, endIndex);
  }

  // Précharger les images pour la prochaine carte
  Future<void> preloadMediaForCards(
      List<FlashCard> cards, int currentIndex) async {
    if (!_optimizationEnabled) {
      return;
    }

    // Préchargement des 3 cartes suivantes
    const preloadCount = 3;
    for (int i = 1; i <= preloadCount; i++) {
      final nextIndex = currentIndex + i;
      if (nextIndex < cards.length) {
        // Extraire les URLs d'images du contenu de la carte
        // C'est une simplification - il faudrait analyser le delta de Quill
        await _preloadCardMedia(cards[nextIndex]);
      }
    }
  }

  // Précharger les médias d'une carte
  Future<void> _preloadCardMedia(FlashCard card) async {
    // Cette méthode devrait analyser le contenu de la carte
    // et précharger les images qui s'y trouvent
    // Simplification pour l'exemple
  }

  // Optimiser la mémoire pour des collections spécifiques
  void optimizeMemoryForCollection(DeckWithStats deck) {
    if (!_optimizationEnabled) {
      return;
    }

    if (deck.cardCount > kVeryLargeCollectionThreshold) {
      // Pour les très grandes collections, agressive
      imageCache.maximumSize = 50;
      imageCache.maximumSizeBytes = 50 * 1024 * 1024; // 50 MB
    } else if (deck.cardCount > kLargeCollectionThreshold) {
      // Pour les grandes collections, modérée
      imageCache.maximumSize = 100;
      imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100 MB
    } else {
      // Pour les collections normales
      imageCache.maximumSize = 1000;
      imageCache.maximumSizeBytes = 200 * 1024 * 1024; // 200 MB
    }
  }

  // Charger une image mise en cache ou depuis le disque
  Future<ImageProvider> getCachedImageProvider(String path) async {
    if (_imageCache.containsKey(path)) {
      return _imageCache[path]!;
    }

    final file = File(path);
    if (await file.exists()) {
      final imageProvider = FileImage(file);
      // Ajouter au cache
      _imageCache[path] = imageProvider;
      return imageProvider;
    }

    throw Exception('Image not found: $path');
  }

  // Enregistrer les métriques de performance pour le chargement des cartes
  void recordCardLoadTime(Duration loadTime) {
    final loadTimeMs = loadTime.inMilliseconds.toDouble();
    _avgCardLoadTime = (_avgCardLoadTime * _cardLoadsCount + loadTimeMs) /
        (_cardLoadsCount + 1);
    _cardLoadsCount++;
  }

  // Obtenir le temps moyen de chargement des cartes
  double getAverageCardLoadTimeMs() {
    return _avgCardLoadTime;
  }

  // Nettoyer le cache des médias temporaires
  Future<void> cleanupTempMedia() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final mediaDir = Directory('${tempDir.path}/media');

      if (await mediaDir.exists()) {
        // Supprimer les fichiers de plus de 7 jours
        final now = DateTime.now();
        final files = await mediaDir.list().toList();

        for (final fileEntity in files) {
          if (fileEntity is File) {
            final stat = await fileEntity.stat();
            final fileAge = now.difference(stat.modified);

            if (fileAge.inDays > 7) {
              await fileEntity.delete();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Erreur lors du nettoyage des médias temporaires: $e');
    }
  }

  // Obtenir des suggestions d'optimisation
  List<String> getOptimizationSuggestions(int cardCount, double avgLoadTime) {
    final suggestions = <String>[];

    if (cardCount > kVeryLargeCollectionThreshold) {
      suggestions.add(
          'Collection très grande (${cardCount.toString()} cartes). Envisagez de diviser en plusieurs paquets.');
    } else if (cardCount > kLargeCollectionThreshold) {
      suggestions.add(
          'Grande collection (${cardCount.toString()} cartes). Le chargement par lots est activé.');
    }

    if (avgLoadTime > 200) {
      suggestions.add(
          'Temps de chargement des cartes élevé (${avgLoadTime.toStringAsFixed(1)}ms). Réduire la taille des médias peut améliorer les performances.');
    }

    return suggestions;
  }
}
