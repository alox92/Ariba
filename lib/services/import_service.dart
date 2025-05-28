import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' show Value;
import 'package:csv/csv.dart';
import 'package:flashcards_app/data/database.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

enum ImportFormat {
  anki,
  quizlet,
  csv,
  markdown,
  text,
  pdf,
}

class ImportResult {
  final bool success;
  final String message;
  final int cardsImported;
  final int? deckId;

  ImportResult({
    required this.success,
    required this.message,
    required this.cardsImported,
    this.deckId,
  });
}

class ImportService {
  final Database _database;

  ImportService(this._database);

  Future<ImportResult> importFromFile(String filePath,
      {String? deckName, ImportFormat? format}) async {
    // Détecter automatiquement le format si non spécifié
    final detectedFormat = format ?? _detectFormatFromExtension(filePath);

    switch (detectedFormat) {
      case ImportFormat.anki:
        return _importAnkiPackage(filePath, deckName);
      case ImportFormat.csv:
        return _importCsv(filePath, deckName);
      case ImportFormat.markdown:
        return _importMarkdown(filePath, deckName);
      case ImportFormat.text:
        return _importText(filePath, deckName);
      case ImportFormat.pdf:
        return _importPdf(filePath, deckName);
      case ImportFormat.quizlet:
        return _importQuizlet(filePath, deckName);
    }
  }

  ImportFormat _detectFormatFromExtension(String filePath) {
    final extension = path.extension(filePath).toLowerCase();

    switch (extension) {
      case '.apkg':
        return ImportFormat.anki;
      case '.csv':
        return ImportFormat.csv;
      case '.md':
        return ImportFormat.markdown;
      case '.txt':
        return ImportFormat.text;
      case '.pdf':
        return ImportFormat.pdf;
      case '.json':
        // Vérifier si c'est un export Quizlet (basé sur le contenu)
        return ImportFormat.quizlet;
      default:
        // Par défaut, essayer de traiter comme du texte
        return ImportFormat.text;
    }
  }

  Future<ImportResult> _importAnkiPackage(
      String filePath, String? deckName) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Trouver le fichier collection.anki2 ou collection.anki21 (base SQLite d'Anki)
      ArchiveFile? collectionFile = archive.findFile('collection.anki2');
      collectionFile ??= archive.findFile('collection.anki21');

      if (collectionFile == null) {
        return ImportResult(
          success: false,
          message:
              'Format Anki invalide : fichier collection.anki2 ou collection.anki21 non trouvé.',
          cardsImported: 0,
        );
      }

      // Extraire et créer un fichier temporaire
      final tempDir = await getTemporaryDirectory();
      final tempDbPath =
          '${tempDir.path}/temp_anki_collection.db'; // Use .db extension
      final tempFile = File(tempDbPath);
      await tempFile.writeAsBytes(collectionFile.content as List<int>);

      // Ouvrir la base de données SQLite Anki
      late sqflite.Database ankiDb;
      try {
        ankiDb = await sqflite.openDatabase(tempDbPath);
      } catch (e) {
        await tempFile
            .delete(); // Nettoyer le fichier temporaire en cas d'erreur
        return ImportResult(
          success: false,
          message: 'Erreur lors de l\'ouverture de la base de données Anki: $e',
          cardsImported: 0,
        );
      }

      // Déterminer le nom du paquet et le créer
      final String actualDeckName =
          deckName ?? path.basenameWithoutExtension(filePath);
      final newDeckId = await _database.decksDao.addDeck(
        DeckEntityCompanion.insert(
          name: actualDeckName,
          description: const Value('Importé depuis un fichier Anki'),
          cardCount:
              const Value(0), // Sera mis à jour après l'importation des cartes
          createdAt: Value(DateTime.now()),
          lastAccessed: Value(DateTime.now()),
        ),
      );

      // Récupérer les notes et les cartes depuis la base de données Anki
      List<Map<String, Object?>> ankiNotes = [];
      List<Map<String, Object?>> ankiCardsData = []; // Renommé pour clarté

      try {
        // Les notes contiennent les champs de contenu (front, back, etc.)
        // flds est une chaîne avec les champs séparés par \u001f (unit separator)
        ankiNotes =
            await ankiDb.rawQuery('SELECT id, mid, flds, tags FROM notes');
        // Les cartes lient les notes à des modèles de cartes spécifiques (ord) et à des paquets Anki (did)
        ankiCardsData =
            await ankiDb.rawQuery('SELECT id, nid, did, ord FROM cards');
      } catch (e) {
        await ankiDb.close();
        await tempFile.delete();
        return ImportResult(
          success: false,
          message:
              'Erreur lors de la lecture des données depuis la base Anki: $e',
          cardsImported: 0,
        );
      }

      final List<CardEntityCompanion> newCardsToInsert = [];
      int importedCardsCount = 0;

      // Créer un mapping des notes par leur ID pour un accès facile
      final Map<int, Map<String, Object?>> notesMap = {
        for (final note in ankiNotes) (note['id'] as int): note,
      };

      // Préparer le répertoire médias persistant (par deck)
      final appDocDir = await getApplicationDocumentsDirectory();
      final mediaDir = Directory('${appDocDir.path}/media/$newDeckId');
      if (!mediaDir.existsSync()) {
        await mediaDir.create(recursive: true);
      }
      // Mapping des fichiers médias depuis l'archive
      final mediaFiles = <String, ArchiveFile>{};
      for (final file in archive) {
        final name = path.basename(file.name);
        mediaFiles[name] = file;
      }

      newCardsToInsert.addAll(
        ankiCardsData
            .map((ankiCard) {
              final noteId = ankiCard['nid'] as int?;
              if (noteId == null) {
                return null;
              }
              final noteData = notesMap[noteId];
              if (noteData == null) {
                return null;
              }

              final fieldsString = noteData['flds'] as String?;
              if (fieldsString == null) {
                return null;
              }
              final fields = fieldsString.split('\u001f');
              if (fields.length < 2) {
                return null; // recto/verso attendus
              }

              String processedFront = fields[0];
              String processedBack = fields[1];

              // Gérer les médias (images, audio)
              final RegExp mediaRegex = RegExp(r'<img src="(.*?)" />|<audio src="(.*?)">.*?</audio>');
              final frontMatches = mediaRegex.allMatches(processedFront);
              for (final match in frontMatches) {
                final imageName = match.group(1) ?? match.group(2);
                if (imageName != null && mediaFiles.containsKey(imageName)) {
                  final mediaFile = mediaFiles[imageName]!;
                  final newMediaPath = path.join(mediaDir.path, imageName);
                  File(newMediaPath).writeAsBytesSync(mediaFile.content as List<int>);
                  // Remplacer par un chemin local ou une référence
                  processedFront = processedFront.replaceFirst(match.group(0)!,
                      '[media:$newDeckId/$imageName]'); // Placeholder pour le rendu
                }
              }
              final backMatches = mediaRegex.allMatches(processedBack);
              for (final match in backMatches) {
                final imageName = match.group(1) ?? match.group(2);
                if (imageName != null && mediaFiles.containsKey(imageName)) {
                  final mediaFile = mediaFiles[imageName]!;
                  final newMediaPath = path.join(mediaDir.path, imageName);
                  File(newMediaPath).writeAsBytesSync(mediaFile.content as List<int>);
                  processedBack = processedBack.replaceFirst(match.group(0)!,
                      '[media:$newDeckId/$imageName]'); // Placeholder pour le rendu
                }
              }

              importedCardsCount++;
              return CardEntityCompanion.insert(
                deckId: newDeckId,
                frontText: processedFront,
                backText: processedBack,
                createdAt: Value(DateTime.now()),
                // nextReview and updatedAt are handled by default values or triggers in the table definition
              );
            })
            .whereType<CardEntityCompanion>()
            .toList(),
      );

      if (newCardsToInsert.isNotEmpty) {
        // Assuming addCards was a typo and it should be multiple individual calls or a batch insert method
        for (final cardCompanion in newCardsToInsert) {
          await _database.cardsDao.addCard(cardCompanion);
        }
      }

      // Mettre à jour le nombre de cartes dans le paquet
      await _database.decksDao.updateDeck(
        DeckEntityCompanion(
          id: Value(newDeckId),
          cardCount: Value(importedCardsCount),
        ),
      );

      await ankiDb.close();
      await tempFile.delete();

      return ImportResult(
        success: true,
        message:
            '$importedCardsCount cartes importées avec succès dans le paquet "$actualDeckName".',
        cardsImported: importedCardsCount,
        deckId: newDeckId,
      );
    } catch (e) {
      // In a real application, use a logging framework e.g.
      // logger.e('Erreur lors de l\'importation du fichier Anki', error: e, stackTrace: stacktrace);
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'importation du fichier Anki: $e',
        cardsImported: 0,
      );
    }
  }

  Future<ImportResult> _importCsv(String filePath, String? deckName) async {
    try {
      final input = await File(filePath).readAsString();
      final rows = const CsvToListConverter().convert(input);

      if (rows.isEmpty) {
        return ImportResult(
          success: false,
          message: 'Le fichier CSV est vide.',
          cardsImported: 0,
        );
      }

      // Extraire le nom du paquet du nom de fichier
      final String deckName = path.basenameWithoutExtension(path.basename(filePath));
      // Pourrait être amélioré pour gérer les noms déjà existants ou demander confirmation

      final deckCompanion = DeckEntityCompanion.insert(
        name: deckName, // String directe
        description: const Value(''),
        cardCount: const Value(0),
        createdAt: Value(DateTime.now()),
        lastAccessed: Value(DateTime.now()),
      );

      final deckId = await _database.decksDao.addDeck(deckCompanion);
      int cardsImported = 0;

      // Importer les cartes
      // Nous supposons que les deux premières colonnes sont recto et verso
      for (int i = 0; i < rows.length; i++) {
        // Ignorer l'en-tête si présent
        if (i == 0 &&
            rows[0].length >= 2 &&
            (rows[0][0] is String && rows[0][1] is String) &&
            ['front', 'question', 'recto']
                .contains((rows[0][0] as String).toLowerCase()) &&
            ['back', 'answer', 'verso']
                .contains((rows[0][1] as String).toLowerCase())) {
          continue;
        }

        if (rows[i].length < 2) {
          continue;
        }

        final front = rows[i][0].toString();
        final back = rows[i][1].toString();

        if (front.isEmpty && back.isEmpty) {
          continue;
        }

        // Créer la carte dans le format JSON pour QuillEditor
        final frontJson = jsonEncode([
          {'insert': '$front\n'}
        ]);

        final backJson = jsonEncode([
          {'insert': '$back\n'}
        ]);

        // Préparation des valeurs pour les champs optionnels/avec conversion
        String tagsValue = '';
        if (rows[i].length > 2 && rows[i][2] != null) {
          tagsValue = rows[i][2].toString();
        }

        String? frontImageValue;
        if (rows[i].length > 3 &&
            rows[i][3] != null &&
            rows[i][3].toString().isNotEmpty) {
          frontImageValue = rows[i][3].toString();
        }

        String? backImageValue;
        if (rows[i].length > 4 &&
            rows[i][4] != null &&
            rows[i][4].toString().isNotEmpty) {
          backImageValue = rows[i][4].toString();
        }

        String? frontAudioValue;
        if (rows[i].length > 5 &&
            rows[i][5] != null &&
            rows[i][5].toString().isNotEmpty) {
          frontAudioValue = rows[i][5].toString();
        }

        String? backAudioValue;
        if (rows[i].length > 6 &&
            rows[i][6] != null &&
            rows[i][6].toString().isNotEmpty) {
          backAudioValue = rows[i][6].toString();
        }

        DateTime createdAtValue = DateTime.now();
        if (rows[i].length > 7 && rows[i][7] != null) {
          createdAtValue =
              DateTime.tryParse(rows[i][7].toString()) ?? DateTime.now();
        }

        DateTime? lastReviewedValue;
        if (rows[i].length > 8 && rows[i][8] != null) {
          lastReviewedValue = DateTime.tryParse(rows[i][8].toString());
        }

        int intervalValue = 0;
        if (rows[i].length > 9 && rows[i][9] != null) {
          intervalValue = int.tryParse(rows[i][9].toString()) ?? 0;
        }

        double easeFactorValue = 2.5;
        if (rows[i].length > 10 && rows[i][10] != null) {
          easeFactorValue = double.tryParse(rows[i][10].toString()) ?? 2.5;
        }

        final cardCompanion = CardEntityCompanion.insert(
          deckId: deckId, // int direct
          frontText: frontJson, // String directe
          backText: backJson, // String directe
          tags: Value(tagsValue),
          frontImage: Value(frontImageValue),
          backImage: Value(backImageValue),
          frontAudio: Value(frontAudioValue),
          backAudio: Value(backAudioValue),
          createdAt: Value(createdAtValue), // createdAt est non-nullable
          lastReviewed: Value(lastReviewedValue), // lastReviewed est nullable
          interval: Value(intervalValue), // interval est non-nullable
          easeFactor: Value(easeFactorValue), // easeFactor est non-nullable
        );

        await _database.cardsDao.addCard(cardCompanion);

        cardsImported++;
      }

      await _database.decksDao.updateCardCount(deckId);

      return ImportResult(
        success: true,
        message:
            'Importation CSV réussie. $cardsImported cartes importées dans le paquet \'$deckName\'',
        cardsImported: cardsImported,
        deckId: deckId,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'importation du fichier CSV: $e',
        cardsImported: 0,
      );
    }
  }

  Future<ImportResult> _importMarkdown(
      String filePath, String? deckName) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');

      // Créer le deck
      final deckId = await _database.decksDao.addDeck(
        DeckEntityCompanion.insert(
          name:
              deckName ?? 'Import Markdown ${DateTime.now().toIso8601String()}',
          description: const Value('Importé depuis un fichier Markdown'),
          cardCount: const Value(0),
          createdAt: Value(DateTime.now()),
          lastAccessed: Value(DateTime.now()),
        ),
      );

      // Analyser le markdown
      // Format attendu:
      // # Question
      // Réponse
      //
      // # Autre question
      // Autre réponse

      int importedCards = 0;
      String currentQuestion = '';
      List<String> currentAnswerLines = [];

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i].trim();

        if (line.startsWith('# ') || line.startsWith('## ')) {
          // Sauvegarder la carte précédente si elle existe
          if (currentQuestion.isNotEmpty && currentAnswerLines.isNotEmpty) {
            await _createCardFromMarkdown(
                deckId, currentQuestion, currentAnswerLines.join('\n'));
            importedCards++;
          }

          // Nouvelle question
          currentQuestion = line.substring(line.indexOf(' ') + 1).trim();
          currentAnswerLines = [];
        } else if (currentQuestion.isNotEmpty && line.isNotEmpty) {
          currentAnswerLines.add(line);
        }
      }

      // Sauvegarder la dernière carte
      if (currentQuestion.isNotEmpty && currentAnswerLines.isNotEmpty) {
        await _createCardFromMarkdown(
            deckId, currentQuestion, currentAnswerLines.join('\n'));
        importedCards++;
      }

      await _database.decksDao.updateCardCount(deckId);

      return ImportResult(
        success: true,
        message:
            'Importation Markdown réussie. $importedCards cartes importées.',
        cardsImported: importedCards,
        deckId: deckId,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'importation du fichier Markdown: $e',
        cardsImported: 0,
      );
    }
  }

  Future<void> _createCardFromMarkdown(
      int deckId, String question, String answer) async {
    // Créer la carte dans le format JSON pour QuillEditor
    final frontJson = jsonEncode([
      {'insert': '$question\n'}
    ]);

    final backJson = jsonEncode([
      {'insert': '$answer\n'}
    ]);

    await _database.cardsDao.addCard(
      CardEntityCompanion.insert(
        deckId: deckId, // Valeur directe
        frontText: frontJson, // Valeur directe
        backText: backJson, // Valeur directe
        tags: const Value(''), // Pour String?
        createdAt: Value(DateTime.now()),
        lastReviewed: const Value(null), // Pour DateTime?
        interval: const Value(0),
        easeFactor: const Value(2.5),
        frontImage: const Value(null), // Pour String?
        backImage: const Value(null), // Pour String?
        frontAudio: const Value(null), // Pour String?
        backAudio: const Value(null), // Pour String?
      ),
    );
  }

  Future<ImportResult> _importText(String filePath, String? deckName) async {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');

      // Créer le deck
      final String actualDeckNameText =
          deckName ?? 'Import Texte ${DateTime.now().toIso8601String()}';
      final deckId = await _database.decksDao.addDeck(
        DeckEntityCompanion.insert(
          name: actualDeckNameText, // Valeur directe
          description: const Value('Importé depuis un fichier texte'),
          cardCount: const Value(0),
          createdAt: Value(DateTime.now()),
          lastAccessed: Value(DateTime.now()),
        ),
      );

      // Détecter le format
      // On suppose différents formats possibles:
      // 1. Question\tRéponse
      // 2. Question\nRéponse\n\n

      int importedCards = 0;

      // Vérifier si le séparateur est un tab
      if (content.contains('\t')) {
        for (final line in lines) {
          if (line.trim().isEmpty) {
            continue;
          }

          final parts = line.split('\t');
          if (parts.length < 2) {
            continue;
          }

          final front = parts[0].trim();
          final back = parts[1].trim();

          if (front.isEmpty && back.isEmpty) {
            continue;
          }

          await _createCardFromText(deckId, front, back);
          importedCards++;
        }
      } else {
        // Format avec questions et réponses séparées par des lignes vides
        String currentQuestion = '';
        List<String> currentAnswerLines = [];
        bool isQuestion = true;

        for (final line in lines) {
          if (line.trim().isEmpty) {
            // Ligne vide = séparateur
            if (currentQuestion.isNotEmpty && currentAnswerLines.isNotEmpty) {
              await _createCardFromText(
                  deckId, currentQuestion, currentAnswerLines.join('\n'));
              importedCards++;

              currentQuestion = '';
              currentAnswerLines = [];
              isQuestion = true;
            } else if (currentQuestion.isNotEmpty) {
              // On vient de finir la question, on passe à la réponse
              isQuestion = false;
            }
          } else {
            if (isQuestion) {
              if (currentQuestion.isEmpty) {
                currentQuestion = line.trim();
              } else {
                currentQuestion += '\n${line.trim()}';
              }
            } else {
              currentAnswerLines.add(line.trim());
            }
          }
        }

        // Sauvegarder la dernière carte
        if (currentQuestion.isNotEmpty && currentAnswerLines.isNotEmpty) {
          await _createCardFromText(
              deckId, currentQuestion, currentAnswerLines.join('\n'));
          importedCards++;
        }
      }

      await _database.decksDao.updateCardCount(deckId);

      return ImportResult(
        success: true,
        message: 'Importation Texte réussie. $importedCards cartes importées.',
        cardsImported: importedCards,
        deckId: deckId,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'importation du fichier Texte: $e',
        cardsImported: 0,
      );
    }
  }

  Future<void> _createCardFromText(
      int deckId, String question, String answer) async {
    // Créer la carte dans le format JSON pour QuillEditor
    final frontJson = jsonEncode([
      {'insert': '$question\n'}
    ]);

    final backJson = jsonEncode([
      {'insert': '$answer\n'}
    ]);

    await _database.cardsDao.addCard(
      CardEntityCompanion.insert(
        deckId: deckId, // Valeur directe
        frontText: frontJson, // Valeur directe
        backText: backJson, // Valeur directe
        tags: const Value(''), // Pour String?
        createdAt: Value(DateTime.now()),
        lastReviewed: const Value(null), // Pour DateTime?
        interval: const Value(0),
        easeFactor: const Value(2.5),
        frontImage: const Value(null), // Pour String?
        backImage: const Value(null), // Pour String?
        frontAudio: const Value(null), // Pour String?
        backAudio: const Value(null), // Pour String?
      ),
    );
  }

  Future<ImportResult> _importPdf(String filePath, String? deckName) async {
    // L'extraction de texte depuis un PDF nécessite des packages tiers
    // comme pdf ou syncfusion_flutter_pdf
    // Cette fonctionnalité sera implémentée ultérieurement

    return ImportResult(
      success: false,
      message: 'L\'importation depuis PDF n\'est pas encore implémentée.',
      cardsImported: 0,
    );
  }

  Future<ImportResult> _importQuizlet(String filePath, String? deckName) async {
    try {
      final content = await File(filePath).readAsString();
      final json = jsonDecode(content);

      // Analyser le format JSON Quizlet
      // Le format exact dépend de l'API Quizlet ou du format d'export

      // Vérifier si c'est un format valide
      if (!json.containsKey('terms') || json['terms'] is! List) {
        return ImportResult(
          success: false,
          message: 'Format Quizlet invalide.',
          cardsImported: 0,
        );
      }

      // Créer le deck
      final title = json['title'] as String? ??
          'Import Quizlet ${DateTime.now().toIso8601String()}';
      final String actualDeckNameQuizlet = deckName ?? title;
      final deckId = await _database.decksDao.addDeck(
        DeckEntityCompanion.insert(
          name: actualDeckNameQuizlet, // Valeur directe
          description:
              Value(json['description'] as String? ?? 'Importé depuis Quizlet'),
          cardCount: const Value(0),
          createdAt: Value(DateTime.now()),
          lastAccessed: Value(DateTime.now()),
        ),
      );

      // Importer les termes
      final terms = json['terms'] as List;
      int importedCards = 0;

      for (final termItem in terms) {
        if (termItem is Map) {
          final term = termItem as Map<String, dynamic>;
          final front = term['term'] as String? ?? '';
          final back = term['definition'] as String? ?? '';

          if (front.isEmpty && back.isEmpty) {
            continue;
          }

          await _createCardFromText(deckId, front, back);
          importedCards++;
        }
      }

      await _database.decksDao.updateCardCount(deckId);

      return ImportResult(
        success: true,
        message:
            'Importation Quizlet réussie. $importedCards cartes importées.',
        cardsImported: importedCards,
        deckId: deckId,
      );
    } catch (e) {
      return ImportResult(
        success: false,
        message: 'Erreur lors de l\'importation du fichier Quizlet: $e',
        cardsImported: 0,
      );
    }
  }
}
