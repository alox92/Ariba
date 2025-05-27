part of '../database.dart'; // Ajout de la directive part of

@DataClassName('ReviewStatsDataClass') // Éviter conflit avec modèle manuel
class ReviewStats extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get cardId =>
      integer().references(CardEntity, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get reviewDate => dateTime()();
  IntColumn get performanceRating =>
      integer()(); // ex: 1 (mauvais) à 5 (très bien)
  IntColumn get timeSpentMs =>
      integer()(); // Temps passé sur la carte en millisecondes
}
