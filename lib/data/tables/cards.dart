part of '../database.dart'; // Ajout de la directive part of

@DataClassName('CardEntityData') // Nom de la classe de données générée
class CardEntity extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId =>
      integer().references(DeckEntity, #id, onDelete: KeyAction.cascade)();
  TextColumn get frontText => text()();
  TextColumn get backText => text()();
  TextColumn get tags => text().withDefault(const Constant(''))();
  TextColumn get frontImage => text().nullable()();
  TextColumn get backImage => text().nullable()();
  TextColumn get frontAudio => text().nullable()();
  TextColumn get backAudio => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastReviewed => dateTime().nullable()();
  IntColumn get interval =>
      integer().withDefault(const Constant(0))(); // En jours
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
}
