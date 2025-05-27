import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart'; // Importer pour debugPrint
// sqlite3_flutter_libs is implicitly used by drift/native on some platforms
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'models/review_stats.dart'; // Import the new model

// Removed direct sqlite3 import; drift/native provides necessary bindings

part 'database.g.dart';
part 'tables/decks.dart';
part 'tables/cards.dart';
part 'tables/review_stats.dart';

// Importer les DAOs
part 'drift/decks_dao.dart';
part 'drift/cards_dao.dart';
part 'drift/stats_dao.dart';

@DriftDatabase(
    tables: [DeckEntity, CardEntity, ReviewStats],
    daos: [DecksDao, CardsDao, StatsDao] // Décommenté
    )
class Database extends _$Database {
  // Modify constructor to accept an optional QueryExecutor
  Database({QueryExecutor? executor}) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // Stratégie de migration : Supprimer et recréer (pour développement)
  // ATTENTION : Ceci supprime toutes les données existantes à chaque changement de schéma.
  // À remplacer par une vraie stratégie de migration pour la production.
  @override
  MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        debugPrint(
            '--- Drift Migration: Dropping all tables for schema upgrade from v$from to v$to ---');
        // Pour une suppression/recréation complète :
        final tables = allTables.toList();
        for (final table in tables.reversed) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        // Ou alternativement, implémenter des ALTER TABLE spécifiques
        // if (from < 2) {
        //   await m.addColumn(cardEntity, cardEntity.newColumn);
        // }
      },
      beforeOpen: (details) async {
        debugPrint(
            '--- Drift Database Opening: Version ${details.versionNow}, Prior Version ${details.versionBefore} ---');
        // Activer les clés étrangères si nécessaire (souvent activé par défaut avec sqlite3)
        // await customStatement('PRAGMA foreign_keys = ON');
      });

  // --- Accesseurs DAO (Décommentés) ---
  // Drift génère les getters pour les DAOs si l'annotation @DriftDatabase(daos: [...]) est utilisée.
  // Pas besoin de les redéfinir manuellement ici si database.g.dart est correctement généré.
  // DecksDao get decksDao => DecksDao(this); // Sera généré par _$Database
  // CardsDao get cardsDao => CardsDao(this); // Sera généré par _$Database
  // StatsDao get statsDao => StatsDao(this); // Sera généré par _$Database

  // Méthode de suppression complète (garder pour le nettoyage)
  Future<void> deleteAllData() {
    return transaction(() async {
      for (final table in allTables) {
        await delete(table).go();
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'flashcards_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
