// Mocks generated by Mockito 5.4.6 from annotations
// in flashcards_app/test/viewmodels/deck_viewmodel_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i7;

import 'package:dartz/dartz.dart' as _i3;
import 'package:drift/drift.dart' as _i4;
import 'package:drift/src/runtime/executor/stream_queries.dart' as _i6;
import 'package:flashcards_app/data/database.dart' as _i5;
import 'package:flashcards_app/domain/entities/deck.dart' as _i11;
import 'package:flashcards_app/domain/failures/failures.dart' as _i10;
import 'package:flashcards_app/domain/repositories/deck_repository.dart' as _i2;
import 'package:flashcards_app/domain/usecases/deck_usecases.dart' as _i9;
import 'package:flashcards_app/services/import_export_service.dart' as _i13;
import 'package:flashcards_app/services/import_service.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i12;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDeckRepository_0 extends _i1.SmartFake
    implements _i2.DeckRepository {
  _FakeDeckRepository_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeEither_1<L, R> extends _i1.SmartFake implements _i3.Either<L, R> {
  _FakeEither_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMigrationStrategy_2 extends _i1.SmartFake
    implements _i4.MigrationStrategy {
  _FakeMigrationStrategy_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _Fake$DeckEntityTable_3 extends _i1.SmartFake
    implements _i5.$DeckEntityTable {
  _Fake$DeckEntityTable_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _Fake$CardEntityTable_4 extends _i1.SmartFake
    implements _i5.$CardEntityTable {
  _Fake$CardEntityTable_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _Fake$ReviewStatsTable_5 extends _i1.SmartFake
    implements _i5.$ReviewStatsTable {
  _Fake$ReviewStatsTable_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDecksDao_6 extends _i1.SmartFake implements _i5.DecksDao {
  _FakeDecksDao_6(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeCardsDao_7 extends _i1.SmartFake implements _i5.CardsDao {
  _FakeCardsDao_7(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStatsDao_8 extends _i1.SmartFake implements _i5.StatsDao {
  _FakeStatsDao_8(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _Fake$DatabaseManager_9 extends _i1.SmartFake
    implements _i5.$DatabaseManager {
  _Fake$DatabaseManager_9(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamQueryUpdateRules_10 extends _i1.SmartFake
    implements _i4.StreamQueryUpdateRules {
  _FakeStreamQueryUpdateRules_10(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGeneratedDatabase_11 extends _i1.SmartFake
    implements _i4.GeneratedDatabase {
  _FakeGeneratedDatabase_11(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDriftDatabaseOptions_12 extends _i1.SmartFake
    implements _i4.DriftDatabaseOptions {
  _FakeDriftDatabaseOptions_12(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDatabaseConnection_13 extends _i1.SmartFake
    implements _i4.DatabaseConnection {
  _FakeDatabaseConnection_13(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeQueryExecutor_14 extends _i1.SmartFake implements _i4.QueryExecutor {
  _FakeQueryExecutor_14(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeStreamQueryStore_15 extends _i1.SmartFake
    implements _i6.StreamQueryStore {
  _FakeStreamQueryStore_15(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDatabaseConnectionUser_16 extends _i1.SmartFake
    implements _i4.DatabaseConnectionUser {
  _FakeDatabaseConnectionUser_16(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeMigrator_17 extends _i1.SmartFake implements _i4.Migrator {
  _FakeMigrator_17(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFuture_18<T1> extends _i1.SmartFake implements _i7.Future<T1> {
  _FakeFuture_18(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeInsertStatement_19<T1 extends _i4.Table, D1> extends _i1.SmartFake
    implements _i4.InsertStatement<T1, D1> {
  _FakeInsertStatement_19(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUpdateStatement_20<T extends _i4.Table, D> extends _i1.SmartFake
    implements _i4.UpdateStatement<T, D> {
  _FakeUpdateStatement_20(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSimpleSelectStatement_21<T1 extends _i4.HasResultSet, D>
    extends _i1.SmartFake implements _i4.SimpleSelectStatement<T1, D> {
  _FakeSimpleSelectStatement_21(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeJoinedSelectStatement_22<FirstT extends _i4.HasResultSet, FirstD>
    extends _i1.SmartFake implements _i4.JoinedSelectStatement<FirstT, FirstD> {
  _FakeJoinedSelectStatement_22(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeBaseSelectStatement_23<Row> extends _i1.SmartFake
    implements _i4.BaseSelectStatement<Row> {
  _FakeBaseSelectStatement_23(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDeleteStatement_24<T1 extends _i4.Table, D1> extends _i1.SmartFake
    implements _i4.DeleteStatement<T1, D1> {
  _FakeDeleteStatement_24(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeSelectable_25<T> extends _i1.SmartFake implements _i4.Selectable<T> {
  _FakeSelectable_25(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeGenerationContext_26 extends _i1.SmartFake
    implements _i4.GenerationContext {
  _FakeGenerationContext_26(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeImportResult_27 extends _i1.SmartFake implements _i8.ImportResult {
  _FakeImportResult_27(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [GetDecksUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockGetDecksUseCase extends _i1.Mock implements _i9.GetDecksUseCase {
  MockGetDecksUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeckRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDeckRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.DeckRepository);

  @override
  _i7.Stream<_i3.Either<_i10.Failure, List<_i11.Deck>>> call() =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [],
        ),
        returnValue:
            _i7.Stream<_i3.Either<_i10.Failure, List<_i11.Deck>>>.empty(),
      ) as _i7.Stream<_i3.Either<_i10.Failure, List<_i11.Deck>>>);
}

/// A class which mocks [GetDeckByIdUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockGetDeckByIdUseCase extends _i1.Mock
    implements _i9.GetDeckByIdUseCase {
  MockGetDeckByIdUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeckRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDeckRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.DeckRepository);

  @override
  _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>> call(int? id) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [id],
        ),
        returnValue: _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>.value(
            _FakeEither_1<_i10.Failure, _i11.Deck>(
          this,
          Invocation.method(
            #call,
            [id],
          ),
        )),
      ) as _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>);
}

/// A class which mocks [AddDeckUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockAddDeckUseCase extends _i1.Mock implements _i9.AddDeckUseCase {
  MockAddDeckUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeckRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDeckRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.DeckRepository);

  @override
  _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>> call(
          _i9.AddDeckParams? params) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [params],
        ),
        returnValue: _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>.value(
            _FakeEither_1<_i10.Failure, _i11.Deck>(
          this,
          Invocation.method(
            #call,
            [params],
          ),
        )),
      ) as _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>);
}

/// A class which mocks [UpdateDeckUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockUpdateDeckUseCase extends _i1.Mock implements _i9.UpdateDeckUseCase {
  MockUpdateDeckUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeckRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDeckRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.DeckRepository);

  @override
  _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>> call(_i11.Deck? deck) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [deck],
        ),
        returnValue: _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>.value(
            _FakeEither_1<_i10.Failure, _i11.Deck>(
          this,
          Invocation.method(
            #call,
            [deck],
          ),
        )),
      ) as _i7.Future<_i3.Either<_i10.Failure, _i11.Deck>>);
}

/// A class which mocks [DeleteDeckUseCase].
///
/// See the documentation for Mockito's code generation for more information.
class MockDeleteDeckUseCase extends _i1.Mock implements _i9.DeleteDeckUseCase {
  MockDeleteDeckUseCase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.DeckRepository get repository => (super.noSuchMethod(
        Invocation.getter(#repository),
        returnValue: _FakeDeckRepository_0(
          this,
          Invocation.getter(#repository),
        ),
      ) as _i2.DeckRepository);

  @override
  _i7.Future<_i3.Either<_i10.Failure, _i3.Unit>> call(int? deckId) =>
      (super.noSuchMethod(
        Invocation.method(
          #call,
          [deckId],
        ),
        returnValue: _i7.Future<_i3.Either<_i10.Failure, _i3.Unit>>.value(
            _FakeEither_1<_i10.Failure, _i3.Unit>(
          this,
          Invocation.method(
            #call,
            [deckId],
          ),
        )),
      ) as _i7.Future<_i3.Either<_i10.Failure, _i3.Unit>>);
}

/// A class which mocks [Database].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabase extends _i1.Mock implements _i5.Database {
  MockDatabase() {
    _i1.throwOnMissingStub(this);
  }

  @override
  int get schemaVersion => (super.noSuchMethod(
        Invocation.getter(#schemaVersion),
        returnValue: 0,
      ) as int);

  @override
  _i4.MigrationStrategy get migration => (super.noSuchMethod(
        Invocation.getter(#migration),
        returnValue: _FakeMigrationStrategy_2(
          this,
          Invocation.getter(#migration),
        ),
      ) as _i4.MigrationStrategy);

  @override
  _i5.$DeckEntityTable get deckEntity => (super.noSuchMethod(
        Invocation.getter(#deckEntity),
        returnValue: _Fake$DeckEntityTable_3(
          this,
          Invocation.getter(#deckEntity),
        ),
      ) as _i5.$DeckEntityTable);

  @override
  _i5.$CardEntityTable get cardEntity => (super.noSuchMethod(
        Invocation.getter(#cardEntity),
        returnValue: _Fake$CardEntityTable_4(
          this,
          Invocation.getter(#cardEntity),
        ),
      ) as _i5.$CardEntityTable);

  @override
  _i5.$ReviewStatsTable get reviewStats => (super.noSuchMethod(
        Invocation.getter(#reviewStats),
        returnValue: _Fake$ReviewStatsTable_5(
          this,
          Invocation.getter(#reviewStats),
        ),
      ) as _i5.$ReviewStatsTable);

  @override
  _i5.DecksDao get decksDao => (super.noSuchMethod(
        Invocation.getter(#decksDao),
        returnValue: _FakeDecksDao_6(
          this,
          Invocation.getter(#decksDao),
        ),
      ) as _i5.DecksDao);

  @override
  _i5.CardsDao get cardsDao => (super.noSuchMethod(
        Invocation.getter(#cardsDao),
        returnValue: _FakeCardsDao_7(
          this,
          Invocation.getter(#cardsDao),
        ),
      ) as _i5.CardsDao);

  @override
  _i5.StatsDao get statsDao => (super.noSuchMethod(
        Invocation.getter(#statsDao),
        returnValue: _FakeStatsDao_8(
          this,
          Invocation.getter(#statsDao),
        ),
      ) as _i5.StatsDao);

  @override
  _i5.$DatabaseManager get managers => (super.noSuchMethod(
        Invocation.getter(#managers),
        returnValue: _Fake$DatabaseManager_9(
          this,
          Invocation.getter(#managers),
        ),
      ) as _i5.$DatabaseManager);

  @override
  Iterable<_i4.TableInfo<_i4.Table, Object?>> get allTables =>
      (super.noSuchMethod(
        Invocation.getter(#allTables),
        returnValue: <_i4.TableInfo<_i4.Table, Object?>>[],
      ) as Iterable<_i4.TableInfo<_i4.Table, Object?>>);

  @override
  List<_i4.DatabaseSchemaEntity> get allSchemaEntities => (super.noSuchMethod(
        Invocation.getter(#allSchemaEntities),
        returnValue: <_i4.DatabaseSchemaEntity>[],
      ) as List<_i4.DatabaseSchemaEntity>);

  @override
  _i4.StreamQueryUpdateRules get streamUpdateRules => (super.noSuchMethod(
        Invocation.getter(#streamUpdateRules),
        returnValue: _FakeStreamQueryUpdateRules_10(
          this,
          Invocation.getter(#streamUpdateRules),
        ),
      ) as _i4.StreamQueryUpdateRules);

  @override
  _i4.GeneratedDatabase get attachedDatabase => (super.noSuchMethod(
        Invocation.getter(#attachedDatabase),
        returnValue: _FakeGeneratedDatabase_11(
          this,
          Invocation.getter(#attachedDatabase),
        ),
      ) as _i4.GeneratedDatabase);

  @override
  _i4.DriftDatabaseOptions get options => (super.noSuchMethod(
        Invocation.getter(#options),
        returnValue: _FakeDriftDatabaseOptions_12(
          this,
          Invocation.getter(#options),
        ),
      ) as _i4.DriftDatabaseOptions);

  @override
  _i4.DatabaseConnection get connection => (super.noSuchMethod(
        Invocation.getter(#connection),
        returnValue: _FakeDatabaseConnection_13(
          this,
          Invocation.getter(#connection),
        ),
      ) as _i4.DatabaseConnection);

  @override
  _i4.SqlTypes get typeMapping => (super.noSuchMethod(
        Invocation.getter(#typeMapping),
        returnValue: _i12.dummyValue<_i4.SqlTypes>(
          this,
          Invocation.getter(#typeMapping),
        ),
      ) as _i4.SqlTypes);

  @override
  _i4.QueryExecutor get executor => (super.noSuchMethod(
        Invocation.getter(#executor),
        returnValue: _FakeQueryExecutor_14(
          this,
          Invocation.getter(#executor),
        ),
      ) as _i4.QueryExecutor);

  @override
  _i6.StreamQueryStore get streamQueries => (super.noSuchMethod(
        Invocation.getter(#streamQueries),
        returnValue: _FakeStreamQueryStore_15(
          this,
          Invocation.getter(#streamQueries),
        ),
      ) as _i6.StreamQueryStore);

  @override
  _i4.DatabaseConnectionUser get resolvedEngine => (super.noSuchMethod(
        Invocation.getter(#resolvedEngine),
        returnValue: _FakeDatabaseConnectionUser_16(
          this,
          Invocation.getter(#resolvedEngine),
        ),
      ) as _i4.DatabaseConnectionUser);

  @override
  _i7.Future<void> deleteAllData() => (super.noSuchMethod(
        Invocation.method(
          #deleteAllData,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i4.Migrator createMigrator() => (super.noSuchMethod(
        Invocation.method(
          #createMigrator,
          [],
        ),
        returnValue: _FakeMigrator_17(
          this,
          Invocation.method(
            #createMigrator,
            [],
          ),
        ),
      ) as _i4.Migrator);

  @override
  _i7.Future<void> beforeOpen(
    _i4.QueryExecutor? executor,
    _i4.OpeningDetails? details,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #beforeOpen,
          [
            executor,
            details,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Stream<T> createStream<T extends Object>(
          _i6.QueryStreamFetcher<T>? stmt) =>
      (super.noSuchMethod(
        Invocation.method(
          #createStream,
          [stmt],
        ),
        returnValue: _i7.Stream<T>.empty(),
      ) as _i7.Stream<T>);

  @override
  T alias<T, D>(
    _i4.ResultSetImplementation<T, D>? table,
    String? alias,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #alias,
          [
            table,
            alias,
          ],
        ),
        returnValue: _i12.dummyValue<T>(
          this,
          Invocation.method(
            #alias,
            [
              table,
              alias,
            ],
          ),
        ),
      ) as T);

  @override
  void markTablesUpdated(Iterable<_i4.TableInfo<_i4.Table, dynamic>>? tables) =>
      super.noSuchMethod(
        Invocation.method(
          #markTablesUpdated,
          [tables],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void notifyUpdates(Set<_i4.TableUpdate>? updates) => super.noSuchMethod(
        Invocation.method(
          #notifyUpdates,
          [updates],
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i7.Stream<Set<_i4.TableUpdate>> tableUpdates(
          [_i4.TableUpdateQuery? query = const _i4.TableUpdateQuery.any()]) =>
      (super.noSuchMethod(
        Invocation.method(
          #tableUpdates,
          [query],
        ),
        returnValue: _i7.Stream<Set<_i4.TableUpdate>>.empty(),
      ) as _i7.Stream<Set<_i4.TableUpdate>>);

  @override
  _i7.Future<T> doWhenOpened<T>(
          _i7.FutureOr<T> Function(_i4.QueryExecutor)? fn) =>
      (super.noSuchMethod(
        Invocation.method(
          #doWhenOpened,
          [fn],
        ),
        returnValue: _i12.ifNotNull(
              _i12.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #doWhenOpened,
                  [fn],
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_18<T>(
              this,
              Invocation.method(
                #doWhenOpened,
                [fn],
              ),
            ),
      ) as _i7.Future<T>);

  @override
  _i4.InsertStatement<T, D> into<T extends _i4.Table, D>(
          _i4.TableInfo<T, D>? table) =>
      (super.noSuchMethod(
        Invocation.method(
          #into,
          [table],
        ),
        returnValue: _FakeInsertStatement_19<T, D>(
          this,
          Invocation.method(
            #into,
            [table],
          ),
        ),
      ) as _i4.InsertStatement<T, D>);

  @override
  _i4.UpdateStatement<Tbl, R> update<Tbl extends _i4.Table, R>(
          _i4.TableInfo<Tbl, R>? table) =>
      (super.noSuchMethod(
        Invocation.method(
          #update,
          [table],
        ),
        returnValue: _FakeUpdateStatement_20<Tbl, R>(
          this,
          Invocation.method(
            #update,
            [table],
          ),
        ),
      ) as _i4.UpdateStatement<Tbl, R>);

  @override
  _i4.SimpleSelectStatement<T, R> select<T extends _i4.HasResultSet, R>(
    _i4.ResultSetImplementation<T, R>? table, {
    bool? distinct = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #select,
          [table],
          {#distinct: distinct},
        ),
        returnValue: _FakeSimpleSelectStatement_21<T, R>(
          this,
          Invocation.method(
            #select,
            [table],
            {#distinct: distinct},
          ),
        ),
      ) as _i4.SimpleSelectStatement<T, R>);

  @override
  _i4.JoinedSelectStatement<T, R> selectOnly<T extends _i4.HasResultSet, R>(
    _i4.ResultSetImplementation<T, R>? table, {
    bool? distinct = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #selectOnly,
          [table],
          {#distinct: distinct},
        ),
        returnValue: _FakeJoinedSelectStatement_22<T, R>(
          this,
          Invocation.method(
            #selectOnly,
            [table],
            {#distinct: distinct},
          ),
        ),
      ) as _i4.JoinedSelectStatement<T, R>);

  @override
  _i4.BaseSelectStatement<_i4.TypedResult> selectExpressions(
          Iterable<_i4.Expression<Object>>? columns) =>
      (super.noSuchMethod(
        Invocation.method(
          #selectExpressions,
          [columns],
        ),
        returnValue: _FakeBaseSelectStatement_23<_i4.TypedResult>(
          this,
          Invocation.method(
            #selectExpressions,
            [columns],
          ),
        ),
      ) as _i4.BaseSelectStatement<_i4.TypedResult>);

  @override
  _i4.DeleteStatement<T, D> delete<T extends _i4.Table, D>(
          _i4.TableInfo<T, D>? table) =>
      (super.noSuchMethod(
        Invocation.method(
          #delete,
          [table],
        ),
        returnValue: _FakeDeleteStatement_24<T, D>(
          this,
          Invocation.method(
            #delete,
            [table],
          ),
        ),
      ) as _i4.DeleteStatement<T, D>);

  @override
  _i7.Future<int> customUpdate(
    String? query, {
    List<_i4.Variable<Object>>? variables = const [],
    Set<_i4.ResultSetImplementation<dynamic, dynamic>>? updates,
    _i4.UpdateKind? updateKind,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #customUpdate,
          [query],
          {
            #variables: variables,
            #updates: updates,
            #updateKind: updateKind,
          },
        ),
        returnValue: _i7.Future<int>.value(0),
      ) as _i7.Future<int>);

  @override
  _i7.Future<int> customInsert(
    String? query, {
    List<_i4.Variable<Object>>? variables = const [],
    Set<_i4.ResultSetImplementation<dynamic, dynamic>>? updates,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #customInsert,
          [query],
          {
            #variables: variables,
            #updates: updates,
          },
        ),
        returnValue: _i7.Future<int>.value(0),
      ) as _i7.Future<int>);

  @override
  _i7.Future<List<_i4.QueryRow>> customWriteReturning(
    String? query, {
    List<_i4.Variable<Object>>? variables = const [],
    Set<_i4.ResultSetImplementation<dynamic, dynamic>>? updates,
    _i4.UpdateKind? updateKind,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #customWriteReturning,
          [query],
          {
            #variables: variables,
            #updates: updates,
            #updateKind: updateKind,
          },
        ),
        returnValue: _i7.Future<List<_i4.QueryRow>>.value(<_i4.QueryRow>[]),
      ) as _i7.Future<List<_i4.QueryRow>>);

  @override
  _i4.Selectable<_i4.QueryRow> customSelect(
    String? query, {
    List<_i4.Variable<Object>>? variables = const [],
    Set<_i4.ResultSetImplementation<dynamic, dynamic>>? readsFrom = const {},
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #customSelect,
          [query],
          {
            #variables: variables,
            #readsFrom: readsFrom,
          },
        ),
        returnValue: _FakeSelectable_25<_i4.QueryRow>(
          this,
          Invocation.method(
            #customSelect,
            [query],
            {
              #variables: variables,
              #readsFrom: readsFrom,
            },
          ),
        ),
      ) as _i4.Selectable<_i4.QueryRow>);

  @override
  _i4.Selectable<_i4.QueryRow> customSelectQuery(
    String? query, {
    List<_i4.Variable<Object>>? variables = const [],
    Set<_i4.ResultSetImplementation<dynamic, dynamic>>? readsFrom = const {},
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #customSelectQuery,
          [query],
          {
            #variables: variables,
            #readsFrom: readsFrom,
          },
        ),
        returnValue: _FakeSelectable_25<_i4.QueryRow>(
          this,
          Invocation.method(
            #customSelectQuery,
            [query],
            {
              #variables: variables,
              #readsFrom: readsFrom,
            },
          ),
        ),
      ) as _i4.Selectable<_i4.QueryRow>);

  @override
  _i7.Future<void> customStatement(
    String? statement, [
    List<dynamic>? args,
  ]) =>
      (super.noSuchMethod(
        Invocation.method(
          #customStatement,
          [
            statement,
            args,
          ],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<T> transaction<T>(
    _i7.Future<T> Function()? action, {
    bool? requireNew = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #transaction,
          [action],
          {#requireNew: requireNew},
        ),
        returnValue: _i12.ifNotNull(
              _i12.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #transaction,
                  [action],
                  {#requireNew: requireNew},
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_18<T>(
              this,
              Invocation.method(
                #transaction,
                [action],
                {#requireNew: requireNew},
              ),
            ),
      ) as _i7.Future<T>);

  @override
  _i7.Future<T> exclusively<T>(_i7.Future<T> Function()? action) =>
      (super.noSuchMethod(
        Invocation.method(
          #exclusively,
          [action],
        ),
        returnValue: _i12.ifNotNull(
              _i12.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #exclusively,
                  [action],
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_18<T>(
              this,
              Invocation.method(
                #exclusively,
                [action],
              ),
            ),
      ) as _i7.Future<T>);

  @override
  _i7.Future<void> batch(_i7.FutureOr<void> Function(_i4.Batch)? runInBatch) =>
      (super.noSuchMethod(
        Invocation.method(
          #batch,
          [runInBatch],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);

  @override
  _i7.Future<T> runWithInterceptor<T>(
    _i7.Future<T> Function()? action, {
    required _i4.QueryInterceptor? interceptor,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #runWithInterceptor,
          [action],
          {#interceptor: interceptor},
        ),
        returnValue: _i12.ifNotNull(
              _i12.dummyValueOrNull<T>(
                this,
                Invocation.method(
                  #runWithInterceptor,
                  [action],
                  {#interceptor: interceptor},
                ),
              ),
              (T v) => _i7.Future<T>.value(v),
            ) ??
            _FakeFuture_18<T>(
              this,
              Invocation.method(
                #runWithInterceptor,
                [action],
                {#interceptor: interceptor},
              ),
            ),
      ) as _i7.Future<T>);

  @override
  _i4.GenerationContext $write(
    _i4.Component? component, {
    bool? hasMultipleTables,
    int? startIndex,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #$write,
          [component],
          {
            #hasMultipleTables: hasMultipleTables,
            #startIndex: startIndex,
          },
        ),
        returnValue: _FakeGenerationContext_26(
          this,
          Invocation.method(
            #$write,
            [component],
            {
              #hasMultipleTables: hasMultipleTables,
              #startIndex: startIndex,
            },
          ),
        ),
      ) as _i4.GenerationContext);

  @override
  _i4.GenerationContext $writeInsertable(
    _i4.TableInfo<_i4.Table, dynamic>? table,
    _i4.Insertable<dynamic>? insertable, {
    int? startIndex,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #$writeInsertable,
          [
            table,
            insertable,
          ],
          {#startIndex: startIndex},
        ),
        returnValue: _FakeGenerationContext_26(
          this,
          Invocation.method(
            #$writeInsertable,
            [
              table,
              insertable,
            ],
            {#startIndex: startIndex},
          ),
        ),
      ) as _i4.GenerationContext);

  @override
  String $expandVar(
    int? start,
    int? amount,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #$expandVar,
          [
            start,
            amount,
          ],
        ),
        returnValue: _i12.dummyValue<String>(
          this,
          Invocation.method(
            #$expandVar,
            [
              start,
              amount,
            ],
          ),
        ),
      ) as String);
}

/// A class which mocks [ImportExportService].
///
/// See the documentation for Mockito's code generation for more information.
class MockImportExportService extends _i1.Mock
    implements _i13.ImportExportService {
  MockImportExportService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<String?> exportDeck(int? deckId) => (super.noSuchMethod(
        Invocation.method(
          #exportDeck,
          [deckId],
        ),
        returnValue: _i7.Future<String?>.value(),
      ) as _i7.Future<String?>);

  @override
  _i7.Future<int?> importDeck(String? filePath) => (super.noSuchMethod(
        Invocation.method(
          #importDeck,
          [filePath],
        ),
        returnValue: _i7.Future<int?>.value(),
      ) as _i7.Future<int?>);

  @override
  _i7.Future<int?> importDeckFromFile() => (super.noSuchMethod(
        Invocation.method(
          #importDeckFromFile,
          [],
        ),
        returnValue: _i7.Future<int?>.value(),
      ) as _i7.Future<int?>);

  @override
  _i7.Future<void> shareDeck(String? filePath) => (super.noSuchMethod(
        Invocation.method(
          #shareDeck,
          [filePath],
        ),
        returnValue: _i7.Future<void>.value(),
        returnValueForMissingStub: _i7.Future<void>.value(),
      ) as _i7.Future<void>);
}

/// A class which mocks [ImportService].
///
/// See the documentation for Mockito's code generation for more information.
class MockImportService extends _i1.Mock implements _i8.ImportService {
  MockImportService() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i7.Future<_i8.ImportResult> importFromFile(
    String? filePath, {
    String? deckName,
    _i8.ImportFormat? format,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #importFromFile,
          [filePath],
          {
            #deckName: deckName,
            #format: format,
          },
        ),
        returnValue: _i7.Future<_i8.ImportResult>.value(_FakeImportResult_27(
          this,
          Invocation.method(
            #importFromFile,
            [filePath],
            {
              #deckName: deckName,
              #format: format,
            },
          ),
        )),
      ) as _i7.Future<_i8.ImportResult>);
}
