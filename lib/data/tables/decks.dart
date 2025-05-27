part of '../database.dart';

@DataClassName('DeckEntityData') // Nom de la classe de données générée
class DeckEntity extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get cardCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastAccessed =>
      dateTime().withDefault(currentDateAndTime)();
}
