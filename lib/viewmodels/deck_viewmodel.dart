import 'package:flutter/material.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flashcards_app/services/import_export_service.dart';
import 'package:flashcards_app/services/import_service.dart';
import 'package:flashcards_app/domain/entities/deck.dart' as domain;
import 'package:flashcards_app/domain/usecases/deck_usecases.dart';

class DeckViewModel extends ChangeNotifier {
  final GetDecksUseCase _getDecksUseCase;
  final GetDeckByIdUseCase _getDeckByIdUseCase;
  final AddDeckUseCase _addDeckUseCase;
  final UpdateDeckUseCase _updateDeckUseCase;
  final DeleteDeckUseCase _deleteDeckUseCase;
  final ImportExportService _importExportService;
  final ImportService _importService;

  DeckViewModel(
    this._getDecksUseCase,
    this._getDeckByIdUseCase,
    this._addDeckUseCase,
    this._updateDeckUseCase,
    this._deleteDeckUseCase,
    Database database
  ) : _importExportService = ImportExportService(database),
      _importService = ImportService(database) {
    _watchDecks();
  }

  List<domain.Deck> _decks = [];
  List<domain.Deck> get decks => _decks;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isExporting = false;
  bool get isExporting => _isExporting;

  bool _isImporting = false;
  bool get isImporting => _isImporting;

  // Ajout des getters pour suivre l'état d'ajout/mise à jour
  bool get isAdding =>
      _isLoading; // Simplifié: utilise isLoading pour l'instant
  bool get isUpdating =>
      _isLoading; // Simplifié: utilise isLoading pour l'instant

  // Charger les decks via le repository - made public
  Future<void> loadDecks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _getDecksUseCase().first;
      result.fold(
        (failure) => _error = 'Erreur chargement paquets: ${failure.message}',
        (decksList) => _decks = decksList,
      );
    } catch (e) {
      _error = 'Erreur chargement paquets: ${e.toString()}';
      debugPrint('Error loading decks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Écouter les changements dans la base de données via le repository
  void _watchDecks() {
    _getDecksUseCase().listen(
      (result) {
        result.fold(
          (failure) {
            _error = 'Erreur observation paquets: ${failure.message}';
            debugPrint('Error watching decks: ${failure.message}');
          },
          (updatedDecks) {
            _decks = updatedDecks;
            _error = null;
          },
        );
        notifyListeners();
      },
      onError: (e) {
        _error = 'Erreur observation paquets: ${e.toString()}';
        debugPrint('Error watching decks: $e');
        notifyListeners();
      },
    );
  }

  // Ajouter un deck via le repository
  Future<void> addDeck(String name, String description) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final params = AddDeckParams(
        name: name,
        description: description,
      );
      final result = await _addDeckUseCase(params);
      result.fold(
        (failure) => _error = 'Erreur ajout paquet: ${failure.message}',
        (deck) => debugPrint('Deck added successfully: ${deck.name}'),
      );
    } catch (e) {
      _error = 'Erreur ajout paquet: ${e.toString()}';
      debugPrint('Error adding deck: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour un deck via le repository
  Future<void> updateDeck(int id, String newName, String newDescription) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Récupérer le deck existant
      final getDeckResult = await _getDeckByIdUseCase(id);
      await getDeckResult.fold(
        (failure) async {
          _error = 'Erreur récupération paquet: ${failure.message}';
        },
        (existingDeck) async {
          // Créer le deck mis à jour
          final updatedDeck = existingDeck.copyWith(
            name: newName,
            description: newDescription,
          );
          
          final result = await _updateDeckUseCase(updatedDeck);
          result.fold(
            (failure) => _error = 'Erreur màj paquet: ${failure.message}',
            (deck) => debugPrint('Deck updated successfully: ${deck.name}'),
          );
        },
      );
    } catch (e) {
      _error = 'Erreur màj paquet: ${e.toString()}';
      debugPrint('Error updating deck: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Supprimer un deck via le repository
  Future<void> deleteDeck(int deckId) async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _deleteDeckUseCase(deckId);
      result.fold(
        (failure) => _error = 'Erreur suppression paquet: ${failure.message}',
        (unit) => debugPrint('Deck deleted successfully'),
      );
    } catch (e) {
      _error = 'Erreur suppression paquet: ${e.toString()}';
      debugPrint('Error deleting deck: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Les méthodes d'import/export utilisent toujours _importExportService
  // qui dépend de _database pour l'instant.
  Future<String?> exportDeck(int deckId) async {
    if (_isExporting) {
      return null;
    }
    _isExporting = true;
    _error = null;
    notifyListeners();

    try {
      final filePath = await _importExportService.exportDeck(deckId);

      if (filePath != null) {
        _error = null;
        // Optionnel: partager le fichier après exportation
        // await _importExportService.shareDeck(filePath);
        return filePath;
      } else {
        // L'erreur devrait être gérée et potentiellement loguée dans le service
        _error =
            "Échec de l'exportation."; // Message générique ou récupérer du service si possible
        return null;
      }
    } catch (e) {
      _error = 'Erreur exportation: ${e.toString()}';
      debugPrint('Error exporting deck: $e');
      return null;
    } finally {
      _isExporting = false;
      notifyListeners();
    }
  }

  Future<int?> importDeckFromPicker() async {
    if (_isImporting) {
      return null;
    }
    _isImporting = true;
    _error = null;
    notifyListeners();

    try {
      // Utiliser FilePicker pour obtenir le chemin du fichier
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        // Appeler la méthode d'ImportService avec le chemin du fichier
        final importResult = await _importService.importFromFile(filePath);

        if (importResult.success) {
          _error = null;
          // Le stream _watchDecks() devrait mettre à jour la liste, mais un rappel manuel peut être utile
          loadDecks(); // Pour forcer le rechargement et la mise à jour de l'UI
          return importResult.deckId;
        } else {
          _error = importResult.message;
          debugPrint('Import error: \${importResult.message}');
          return null;
        }
      } else {
        // L'utilisateur a annulé la sélection ou aucun fichier n'a été sélectionné
        _error = 'Importation annulée ou aucun fichier sélectionné.';
        return null;
      }
    } catch (e) {
      _error = 'Erreur importation: \${e.toString()}';
      debugPrint('Error importing deck: \$e');
      return null;
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  // Ne pas oublier de disposer des ressources si nécessaire (par exemple, fermer le stream listener)
  @override
  void dispose() {
    // Si watchDecks().listen est stocké dans une variable, annulez-le ici
    super.dispose();
  }
}
