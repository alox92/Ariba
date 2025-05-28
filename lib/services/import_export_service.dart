import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:permission_handler/permission_handler.dart';

class ImportExportService {
  final Database _database;

  ImportExportService(this._database);

  // Exporter un paquet de cartes vers un fichier CSV
  Future<String?> exportDeck(int deckId) async {
    try {
      // Vérifier et demander les permissions si nécessaire (surtout sur Android)
      if (Platform.isAndroid || Platform.isIOS) {
        var status = await Permission.storage.status;
        if (!status.isGranted) {
          status = await Permission.storage.request();
        }
        if (!status.isGranted) {
          // Consider returning null or a specific error type instead of throwing
          debugPrint('Permission de stockage refusée.');
          return null; // Return null if permission is denied
        }
      }

      final deck = await _database.decksDao.getDeckById(deckId);

      final cards = await _database.cardsDao.getCardsForDeck(deckId);

      final List<List<dynamic>> rows = [];

      // Entêtes CSV
      rows.add([
        'frontText',
        'backText',
        'tags',
        'frontImage',
        'backImage',
        'frontAudio',
        'backAudio',
        'createdAt',
        'lastReviewed',
        'interval',
        'easeFactor'
      ]);

      for (final card in cards) {
        rows.add([
          card.frontText,
          card.backText,
          card.tags,
          card.frontImage ?? '',
          card.backImage ?? '',
          card.frontAudio ?? '',
          card.backAudio ?? '',
          card.createdAt.toIso8601String(),
          card.lastReviewed?.toIso8601String() ?? '',
          card.interval,
          card.easeFactor
        ]);
      }

      final String csvData = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      // Remplacer les caractères invalides dans le nom du fichier
      final safeDeckName =
          deck.name.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
      final filePath = p.join(directory.path, '$safeDeckName.csv');
      final file = File(filePath);
      await file.writeAsString(csvData);

      return filePath;
    } catch (e) {
      debugPrint('Error exporting deck: $e');
      return null; // Return null if any error occurs, including deck not found
    }
  }

  // Importer un paquet depuis un fichier CSV
  Future<int?> importDeck(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        debugPrint('Import failed: File does not exist at $filePath');
        return null;
      }

      final csvData = await file.readAsString();
      final rowsAsListOfValues = const CsvToListConverter(
              shouldParseNumbers: false, allowInvalid: true)
          .convert(csvData);

      if (rowsAsListOfValues.isEmpty) {
        debugPrint('Import failed: CSV is empty.');
        return null;
      }

      // Validate CSV headers
      final List<String> expectedHeaders = [
        'frontText',
        'backText',
        'tags',
        'frontImage',
        'backImage',
        'frontAudio',
        'backAudio',
        'createdAt',
        'lastReviewed',
        'interval',
        'easeFactor'
      ];
      final List<dynamic> headerRow = rowsAsListOfValues[0];

      // Check if headerRow has enough elements and if the critical headers match
      if (headerRow.length < 2 ||
          headerRow[0].toString().trim() != expectedHeaders[0] ||
          headerRow[1].toString().trim() != expectedHeaders[1]) {
        debugPrint(
            'Import failed: CSV header mismatch or insufficient columns. Expected first two: ${expectedHeaders.take(2)}, Got: ${headerRow.length >= 2 ? headerRow.take(2) : headerRow}');
        return null;
      }

      // Extraire le nom du paquet du nom de fichier (ou le demander)
      final String deckName = p.basenameWithoutExtension(filePath);

      // Créer un nouveau paquet
      final deckId = await _database.decksDao.addDeck(
        DeckEntityCompanion.insert(
          name: deckName,
          description: const Value(''),
          cardCount: const Value(0),
          createdAt: Value(DateTime.now()),
          lastAccessed: Value(DateTime.now()),
        ),
      );

      // Importer les cartes
      for (var i = 1; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];
        if (row.length >= 2) {
          // Au moins frontText et backText
          try {
            final String frontTextValue = row[0].toString();
            final String backTextValue = row[1].toString();
            final String tagsValue =
                row.length > 2 && row[2] != null ? row[2].toString() : '';
            final String? frontImageValue =
                row.length > 3 && row[3] != null && row[3].toString().isNotEmpty
                    ? row[3].toString()
                    : null;
            final String? backImageValue =
                row.length > 4 && row[4] != null && row[4].toString().isNotEmpty
                    ? row[4].toString()
                    : null;
            final String? frontAudioValue =
                row.length > 5 && row[5] != null && row[5].toString().isNotEmpty
                    ? row[5].toString()
                    : null;
            final String? backAudioValue =
                row.length > 6 && row[6] != null && row[6].toString().isNotEmpty
                    ? row[6].toString()
                    : null;

            DateTime createdAtValue = DateTime.now();
            if (row.length > 7 && row[7] != null) {
              createdAtValue =
                  DateTime.tryParse(row[7].toString()) ?? DateTime.now();
            }

            DateTime? lastReviewedValue;
            if (row.length > 8 && row[8] != null) {
              lastReviewedValue = DateTime.tryParse(row[8].toString());
            }

            int intervalValue = 0;
            if (row.length > 9 && row[9] != null) {
              intervalValue = int.tryParse(row[9].toString()) ?? 0;
            }

            double easeFactorValue = 2.5;
            if (row.length > 10 && row[10] != null) {
              easeFactorValue = double.tryParse(row[10].toString()) ?? 2.5;
            }

            await _database.cardsDao.addCard(
              CardEntityCompanion.insert(
                deckId: deckId,
                frontText: frontTextValue,
                backText: backTextValue,
                tags: Value(tagsValue),
                frontImage: Value(frontImageValue),
                backImage: Value(backImageValue),
                frontAudio: Value(frontAudioValue),
                backAudio: Value(backAudioValue),
                createdAt: Value(createdAtValue),
                lastReviewed: Value(lastReviewedValue),
                interval: Value(intervalValue),
                easeFactor: Value(easeFactorValue),
              ),
            );
          } catch (e) {
            debugPrint("Erreur lors de l'importation d'une carte: $e");
            // Continuer avec les autres cartes
          }
        }
      }

      // Mettre à jour le nombre de cartes
      await _database.decksDao.updateCardCount(deckId);

      return deckId;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation du paquet: $e');
      return null;
    }
  }

  // Importer un paquet depuis un fichier
  Future<int?> importDeckFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null ||
          result.files.isEmpty ||
          result.files.first.path == null) {
        return null;
      }

      final file = File(result.files.first.path!);
      final csvData = await file.readAsString();
      final data = await importDeck(csvData);

      return data;
    } catch (e) {
      debugPrint('Erreur lors de l\'importation depuis un fichier: $e');
      return null;
    }
  }

  // Partager un paquet exporté
  Future<void> shareDeck(String filePath) async {
    try {
      // The Share.shareXFiles method is deprecated.
      // The new API uses SharePlus.instance.share(ShareParams(...))
      // XFile is still the correct type for files.
      final xFile = XFile(filePath);
      await SharePlus.instance.share(ShareParams(
          files: [xFile],
          text: 'Voici un paquet exporté depuis Flashcards App!'));
    } catch (e) {
      debugPrint('Erreur lors du partage: $e');
    }
  }
}
