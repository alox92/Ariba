// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DeckEntityTable extends DeckEntity
    with TableInfo<$DeckEntityTable, DeckEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _cardCountMeta =
      const VerificationMeta('cardCount');
  @override
  late final GeneratedColumn<int> cardCount = GeneratedColumn<int>(
      'card_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastAccessedMeta =
      const VerificationMeta('lastAccessed');
  @override
  late final GeneratedColumn<DateTime> lastAccessed = GeneratedColumn<DateTime>(
      'last_accessed', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, cardCount, createdAt, lastAccessed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_entity';
  @override
  VerificationContext validateIntegrity(Insertable<DeckEntityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('card_count')) {
      context.handle(_cardCountMeta,
          cardCount.isAcceptableOrUnknown(data['card_count']!, _cardCountMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_accessed')) {
      context.handle(
          _lastAccessedMeta,
          lastAccessed.isAcceptableOrUnknown(
              data['last_accessed']!, _lastAccessedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckEntityData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      cardCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_count'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastAccessed: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_accessed'])!,
    );
  }

  @override
  $DeckEntityTable createAlias(String alias) {
    return $DeckEntityTable(attachedDatabase, alias);
  }
}

class DeckEntityData extends DataClass implements Insertable<DeckEntityData> {
  final int id;
  final String name;
  final String? description;
  final int cardCount;
  final DateTime createdAt;
  final DateTime lastAccessed;
  const DeckEntityData(
      {required this.id,
      required this.name,
      this.description,
      required this.cardCount,
      required this.createdAt,
      required this.lastAccessed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['card_count'] = Variable<int>(cardCount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_accessed'] = Variable<DateTime>(lastAccessed);
    return map;
  }

  DeckEntityCompanion toCompanion(bool nullToAbsent) {
    return DeckEntityCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      cardCount: Value(cardCount),
      createdAt: Value(createdAt),
      lastAccessed: Value(lastAccessed),
    );
  }

  factory DeckEntityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckEntityData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      cardCount: serializer.fromJson<int>(json['cardCount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAccessed: serializer.fromJson<DateTime>(json['lastAccessed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'cardCount': serializer.toJson<int>(cardCount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAccessed': serializer.toJson<DateTime>(lastAccessed),
    };
  }

  DeckEntityData copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          int? cardCount,
          DateTime? createdAt,
          DateTime? lastAccessed}) =>
      DeckEntityData(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        cardCount: cardCount ?? this.cardCount,
        createdAt: createdAt ?? this.createdAt,
        lastAccessed: lastAccessed ?? this.lastAccessed,
      );
  DeckEntityData copyWithCompanion(DeckEntityCompanion data) {
    return DeckEntityData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      cardCount: data.cardCount.present ? data.cardCount.value : this.cardCount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAccessed: data.lastAccessed.present
          ? data.lastAccessed.value
          : this.lastAccessed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckEntityData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('cardCount: $cardCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, cardCount, createdAt, lastAccessed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckEntityData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.cardCount == this.cardCount &&
          other.createdAt == this.createdAt &&
          other.lastAccessed == this.lastAccessed);
}

class DeckEntityCompanion extends UpdateCompanion<DeckEntityData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> cardCount;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastAccessed;
  const DeckEntityCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAccessed = const Value.absent(),
  });
  DeckEntityCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.cardCount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAccessed = const Value.absent(),
  }) : name = Value(name);
  static Insertable<DeckEntityData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? cardCount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAccessed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (cardCount != null) 'card_count': cardCount,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAccessed != null) 'last_accessed': lastAccessed,
    });
  }

  DeckEntityCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<int>? cardCount,
      Value<DateTime>? createdAt,
      Value<DateTime>? lastAccessed}) {
    return DeckEntityCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      cardCount: cardCount ?? this.cardCount,
      createdAt: createdAt ?? this.createdAt,
      lastAccessed: lastAccessed ?? this.lastAccessed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (cardCount.present) {
      map['card_count'] = Variable<int>(cardCount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAccessed.present) {
      map['last_accessed'] = Variable<DateTime>(lastAccessed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckEntityCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('cardCount: $cardCount, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAccessed: $lastAccessed')
          ..write(')'))
        .toString();
  }
}

class $CardEntityTable extends CardEntity
    with TableInfo<$CardEntityTable, CardEntityData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardEntityTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<int> deckId = GeneratedColumn<int>(
      'deck_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES deck_entity (id) ON DELETE CASCADE'));
  static const VerificationMeta _frontTextMeta =
      const VerificationMeta('frontText');
  @override
  late final GeneratedColumn<String> frontText = GeneratedColumn<String>(
      'front_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backTextMeta =
      const VerificationMeta('backText');
  @override
  late final GeneratedColumn<String> backText = GeneratedColumn<String>(
      'back_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _frontImageMeta =
      const VerificationMeta('frontImage');
  @override
  late final GeneratedColumn<String> frontImage = GeneratedColumn<String>(
      'front_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backImageMeta =
      const VerificationMeta('backImage');
  @override
  late final GeneratedColumn<String> backImage = GeneratedColumn<String>(
      'back_image', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frontAudioMeta =
      const VerificationMeta('frontAudio');
  @override
  late final GeneratedColumn<String> frontAudio = GeneratedColumn<String>(
      'front_audio', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _backAudioMeta =
      const VerificationMeta('backAudio');
  @override
  late final GeneratedColumn<String> backAudio = GeneratedColumn<String>(
      'back_audio', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _lastReviewedMeta =
      const VerificationMeta('lastReviewed');
  @override
  late final GeneratedColumn<DateTime> lastReviewed = GeneratedColumn<DateTime>(
      'last_reviewed', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _easeFactorMeta =
      const VerificationMeta('easeFactor');
  @override
  late final GeneratedColumn<double> easeFactor = GeneratedColumn<double>(
      'ease_factor', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        deckId,
        frontText,
        backText,
        tags,
        frontImage,
        backImage,
        frontAudio,
        backAudio,
        createdAt,
        lastReviewed,
        interval,
        easeFactor
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_entity';
  @override
  VerificationContext validateIntegrity(Insertable<CardEntityData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(_deckIdMeta,
          deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta));
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('front_text')) {
      context.handle(_frontTextMeta,
          frontText.isAcceptableOrUnknown(data['front_text']!, _frontTextMeta));
    } else if (isInserting) {
      context.missing(_frontTextMeta);
    }
    if (data.containsKey('back_text')) {
      context.handle(_backTextMeta,
          backText.isAcceptableOrUnknown(data['back_text']!, _backTextMeta));
    } else if (isInserting) {
      context.missing(_backTextMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    }
    if (data.containsKey('front_image')) {
      context.handle(
          _frontImageMeta,
          frontImage.isAcceptableOrUnknown(
              data['front_image']!, _frontImageMeta));
    }
    if (data.containsKey('back_image')) {
      context.handle(_backImageMeta,
          backImage.isAcceptableOrUnknown(data['back_image']!, _backImageMeta));
    }
    if (data.containsKey('front_audio')) {
      context.handle(
          _frontAudioMeta,
          frontAudio.isAcceptableOrUnknown(
              data['front_audio']!, _frontAudioMeta));
    }
    if (data.containsKey('back_audio')) {
      context.handle(_backAudioMeta,
          backAudio.isAcceptableOrUnknown(data['back_audio']!, _backAudioMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('last_reviewed')) {
      context.handle(
          _lastReviewedMeta,
          lastReviewed.isAcceptableOrUnknown(
              data['last_reviewed']!, _lastReviewedMeta));
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('ease_factor')) {
      context.handle(
          _easeFactorMeta,
          easeFactor.isAcceptableOrUnknown(
              data['ease_factor']!, _easeFactorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardEntityData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardEntityData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      deckId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}deck_id'])!,
      frontText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front_text'])!,
      backText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back_text'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
      frontImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front_image']),
      backImage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back_image']),
      frontAudio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front_audio']),
      backAudio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back_audio']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      lastReviewed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_reviewed']),
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      easeFactor: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease_factor'])!,
    );
  }

  @override
  $CardEntityTable createAlias(String alias) {
    return $CardEntityTable(attachedDatabase, alias);
  }
}

class CardEntityData extends DataClass implements Insertable<CardEntityData> {
  final int id;
  final int deckId;
  final String frontText;
  final String backText;
  final String tags;
  final String? frontImage;
  final String? backImage;
  final String? frontAudio;
  final String? backAudio;
  final DateTime createdAt;
  final DateTime? lastReviewed;
  final int interval;
  final double easeFactor;
  const CardEntityData(
      {required this.id,
      required this.deckId,
      required this.frontText,
      required this.backText,
      required this.tags,
      this.frontImage,
      this.backImage,
      this.frontAudio,
      this.backAudio,
      required this.createdAt,
      this.lastReviewed,
      required this.interval,
      required this.easeFactor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<int>(deckId);
    map['front_text'] = Variable<String>(frontText);
    map['back_text'] = Variable<String>(backText);
    map['tags'] = Variable<String>(tags);
    if (!nullToAbsent || frontImage != null) {
      map['front_image'] = Variable<String>(frontImage);
    }
    if (!nullToAbsent || backImage != null) {
      map['back_image'] = Variable<String>(backImage);
    }
    if (!nullToAbsent || frontAudio != null) {
      map['front_audio'] = Variable<String>(frontAudio);
    }
    if (!nullToAbsent || backAudio != null) {
      map['back_audio'] = Variable<String>(backAudio);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || lastReviewed != null) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed);
    }
    map['interval'] = Variable<int>(interval);
    map['ease_factor'] = Variable<double>(easeFactor);
    return map;
  }

  CardEntityCompanion toCompanion(bool nullToAbsent) {
    return CardEntityCompanion(
      id: Value(id),
      deckId: Value(deckId),
      frontText: Value(frontText),
      backText: Value(backText),
      tags: Value(tags),
      frontImage: frontImage == null && nullToAbsent
          ? const Value.absent()
          : Value(frontImage),
      backImage: backImage == null && nullToAbsent
          ? const Value.absent()
          : Value(backImage),
      frontAudio: frontAudio == null && nullToAbsent
          ? const Value.absent()
          : Value(frontAudio),
      backAudio: backAudio == null && nullToAbsent
          ? const Value.absent()
          : Value(backAudio),
      createdAt: Value(createdAt),
      lastReviewed: lastReviewed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewed),
      interval: Value(interval),
      easeFactor: Value(easeFactor),
    );
  }

  factory CardEntityData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardEntityData(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<int>(json['deckId']),
      frontText: serializer.fromJson<String>(json['frontText']),
      backText: serializer.fromJson<String>(json['backText']),
      tags: serializer.fromJson<String>(json['tags']),
      frontImage: serializer.fromJson<String?>(json['frontImage']),
      backImage: serializer.fromJson<String?>(json['backImage']),
      frontAudio: serializer.fromJson<String?>(json['frontAudio']),
      backAudio: serializer.fromJson<String?>(json['backAudio']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastReviewed: serializer.fromJson<DateTime?>(json['lastReviewed']),
      interval: serializer.fromJson<int>(json['interval']),
      easeFactor: serializer.fromJson<double>(json['easeFactor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<int>(deckId),
      'frontText': serializer.toJson<String>(frontText),
      'backText': serializer.toJson<String>(backText),
      'tags': serializer.toJson<String>(tags),
      'frontImage': serializer.toJson<String?>(frontImage),
      'backImage': serializer.toJson<String?>(backImage),
      'frontAudio': serializer.toJson<String?>(frontAudio),
      'backAudio': serializer.toJson<String?>(backAudio),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastReviewed': serializer.toJson<DateTime?>(lastReviewed),
      'interval': serializer.toJson<int>(interval),
      'easeFactor': serializer.toJson<double>(easeFactor),
    };
  }

  CardEntityData copyWith(
          {int? id,
          int? deckId,
          String? frontText,
          String? backText,
          String? tags,
          Value<String?> frontImage = const Value.absent(),
          Value<String?> backImage = const Value.absent(),
          Value<String?> frontAudio = const Value.absent(),
          Value<String?> backAudio = const Value.absent(),
          DateTime? createdAt,
          Value<DateTime?> lastReviewed = const Value.absent(),
          int? interval,
          double? easeFactor}) =>
      CardEntityData(
        id: id ?? this.id,
        deckId: deckId ?? this.deckId,
        frontText: frontText ?? this.frontText,
        backText: backText ?? this.backText,
        tags: tags ?? this.tags,
        frontImage: frontImage.present ? frontImage.value : this.frontImage,
        backImage: backImage.present ? backImage.value : this.backImage,
        frontAudio: frontAudio.present ? frontAudio.value : this.frontAudio,
        backAudio: backAudio.present ? backAudio.value : this.backAudio,
        createdAt: createdAt ?? this.createdAt,
        lastReviewed:
            lastReviewed.present ? lastReviewed.value : this.lastReviewed,
        interval: interval ?? this.interval,
        easeFactor: easeFactor ?? this.easeFactor,
      );
  CardEntityData copyWithCompanion(CardEntityCompanion data) {
    return CardEntityData(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      frontText: data.frontText.present ? data.frontText.value : this.frontText,
      backText: data.backText.present ? data.backText.value : this.backText,
      tags: data.tags.present ? data.tags.value : this.tags,
      frontImage:
          data.frontImage.present ? data.frontImage.value : this.frontImage,
      backImage: data.backImage.present ? data.backImage.value : this.backImage,
      frontAudio:
          data.frontAudio.present ? data.frontAudio.value : this.frontAudio,
      backAudio: data.backAudio.present ? data.backAudio.value : this.backAudio,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastReviewed: data.lastReviewed.present
          ? data.lastReviewed.value
          : this.lastReviewed,
      interval: data.interval.present ? data.interval.value : this.interval,
      easeFactor:
          data.easeFactor.present ? data.easeFactor.value : this.easeFactor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardEntityData(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('frontText: $frontText, ')
          ..write('backText: $backText, ')
          ..write('tags: $tags, ')
          ..write('frontImage: $frontImage, ')
          ..write('backImage: $backImage, ')
          ..write('frontAudio: $frontAudio, ')
          ..write('backAudio: $backAudio, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastReviewed: $lastReviewed, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      deckId,
      frontText,
      backText,
      tags,
      frontImage,
      backImage,
      frontAudio,
      backAudio,
      createdAt,
      lastReviewed,
      interval,
      easeFactor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardEntityData &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.frontText == this.frontText &&
          other.backText == this.backText &&
          other.tags == this.tags &&
          other.frontImage == this.frontImage &&
          other.backImage == this.backImage &&
          other.frontAudio == this.frontAudio &&
          other.backAudio == this.backAudio &&
          other.createdAt == this.createdAt &&
          other.lastReviewed == this.lastReviewed &&
          other.interval == this.interval &&
          other.easeFactor == this.easeFactor);
}

class CardEntityCompanion extends UpdateCompanion<CardEntityData> {
  final Value<int> id;
  final Value<int> deckId;
  final Value<String> frontText;
  final Value<String> backText;
  final Value<String> tags;
  final Value<String?> frontImage;
  final Value<String?> backImage;
  final Value<String?> frontAudio;
  final Value<String?> backAudio;
  final Value<DateTime> createdAt;
  final Value<DateTime?> lastReviewed;
  final Value<int> interval;
  final Value<double> easeFactor;
  const CardEntityCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.frontText = const Value.absent(),
    this.backText = const Value.absent(),
    this.tags = const Value.absent(),
    this.frontImage = const Value.absent(),
    this.backImage = const Value.absent(),
    this.frontAudio = const Value.absent(),
    this.backAudio = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.interval = const Value.absent(),
    this.easeFactor = const Value.absent(),
  });
  CardEntityCompanion.insert({
    this.id = const Value.absent(),
    required int deckId,
    required String frontText,
    required String backText,
    this.tags = const Value.absent(),
    this.frontImage = const Value.absent(),
    this.backImage = const Value.absent(),
    this.frontAudio = const Value.absent(),
    this.backAudio = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastReviewed = const Value.absent(),
    this.interval = const Value.absent(),
    this.easeFactor = const Value.absent(),
  })  : deckId = Value(deckId),
        frontText = Value(frontText),
        backText = Value(backText);
  static Insertable<CardEntityData> custom({
    Expression<int>? id,
    Expression<int>? deckId,
    Expression<String>? frontText,
    Expression<String>? backText,
    Expression<String>? tags,
    Expression<String>? frontImage,
    Expression<String>? backImage,
    Expression<String>? frontAudio,
    Expression<String>? backAudio,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastReviewed,
    Expression<int>? interval,
    Expression<double>? easeFactor,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (frontText != null) 'front_text': frontText,
      if (backText != null) 'back_text': backText,
      if (tags != null) 'tags': tags,
      if (frontImage != null) 'front_image': frontImage,
      if (backImage != null) 'back_image': backImage,
      if (frontAudio != null) 'front_audio': frontAudio,
      if (backAudio != null) 'back_audio': backAudio,
      if (createdAt != null) 'created_at': createdAt,
      if (lastReviewed != null) 'last_reviewed': lastReviewed,
      if (interval != null) 'interval': interval,
      if (easeFactor != null) 'ease_factor': easeFactor,
    });
  }

  CardEntityCompanion copyWith(
      {Value<int>? id,
      Value<int>? deckId,
      Value<String>? frontText,
      Value<String>? backText,
      Value<String>? tags,
      Value<String?>? frontImage,
      Value<String?>? backImage,
      Value<String?>? frontAudio,
      Value<String?>? backAudio,
      Value<DateTime>? createdAt,
      Value<DateTime?>? lastReviewed,
      Value<int>? interval,
      Value<double>? easeFactor}) {
    return CardEntityCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      frontText: frontText ?? this.frontText,
      backText: backText ?? this.backText,
      tags: tags ?? this.tags,
      frontImage: frontImage ?? this.frontImage,
      backImage: backImage ?? this.backImage,
      frontAudio: frontAudio ?? this.frontAudio,
      backAudio: backAudio ?? this.backAudio,
      createdAt: createdAt ?? this.createdAt,
      lastReviewed: lastReviewed ?? this.lastReviewed,
      interval: interval ?? this.interval,
      easeFactor: easeFactor ?? this.easeFactor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<int>(deckId.value);
    }
    if (frontText.present) {
      map['front_text'] = Variable<String>(frontText.value);
    }
    if (backText.present) {
      map['back_text'] = Variable<String>(backText.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (frontImage.present) {
      map['front_image'] = Variable<String>(frontImage.value);
    }
    if (backImage.present) {
      map['back_image'] = Variable<String>(backImage.value);
    }
    if (frontAudio.present) {
      map['front_audio'] = Variable<String>(frontAudio.value);
    }
    if (backAudio.present) {
      map['back_audio'] = Variable<String>(backAudio.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastReviewed.present) {
      map['last_reviewed'] = Variable<DateTime>(lastReviewed.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (easeFactor.present) {
      map['ease_factor'] = Variable<double>(easeFactor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardEntityCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('frontText: $frontText, ')
          ..write('backText: $backText, ')
          ..write('tags: $tags, ')
          ..write('frontImage: $frontImage, ')
          ..write('backImage: $backImage, ')
          ..write('frontAudio: $frontAudio, ')
          ..write('backAudio: $backAudio, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastReviewed: $lastReviewed, ')
          ..write('interval: $interval, ')
          ..write('easeFactor: $easeFactor')
          ..write(')'))
        .toString();
  }
}

class $ReviewStatsTable extends ReviewStats
    with TableInfo<$ReviewStatsTable, ReviewStatsDataClass> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
      'card_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES card_entity (id) ON DELETE CASCADE'));
  static const VerificationMeta _reviewDateMeta =
      const VerificationMeta('reviewDate');
  @override
  late final GeneratedColumn<DateTime> reviewDate = GeneratedColumn<DateTime>(
      'review_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _performanceRatingMeta =
      const VerificationMeta('performanceRating');
  @override
  late final GeneratedColumn<int> performanceRating = GeneratedColumn<int>(
      'performance_rating', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _timeSpentMsMeta =
      const VerificationMeta('timeSpentMs');
  @override
  late final GeneratedColumn<int> timeSpentMs = GeneratedColumn<int>(
      'time_spent_ms', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, cardId, reviewDate, performanceRating, timeSpentMs];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_stats';
  @override
  VerificationContext validateIntegrity(
      Insertable<ReviewStatsDataClass> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('review_date')) {
      context.handle(
          _reviewDateMeta,
          reviewDate.isAcceptableOrUnknown(
              data['review_date']!, _reviewDateMeta));
    } else if (isInserting) {
      context.missing(_reviewDateMeta);
    }
    if (data.containsKey('performance_rating')) {
      context.handle(
          _performanceRatingMeta,
          performanceRating.isAcceptableOrUnknown(
              data['performance_rating']!, _performanceRatingMeta));
    } else if (isInserting) {
      context.missing(_performanceRatingMeta);
    }
    if (data.containsKey('time_spent_ms')) {
      context.handle(
          _timeSpentMsMeta,
          timeSpentMs.isAcceptableOrUnknown(
              data['time_spent_ms']!, _timeSpentMsMeta));
    } else if (isInserting) {
      context.missing(_timeSpentMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReviewStatsDataClass map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewStatsDataClass(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}card_id'])!,
      reviewDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}review_date'])!,
      performanceRating: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}performance_rating'])!,
      timeSpentMs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}time_spent_ms'])!,
    );
  }

  @override
  $ReviewStatsTable createAlias(String alias) {
    return $ReviewStatsTable(attachedDatabase, alias);
  }
}

class ReviewStatsDataClass extends DataClass
    implements Insertable<ReviewStatsDataClass> {
  final int id;
  final int cardId;
  final DateTime reviewDate;
  final int performanceRating;
  final int timeSpentMs;
  const ReviewStatsDataClass(
      {required this.id,
      required this.cardId,
      required this.reviewDate,
      required this.performanceRating,
      required this.timeSpentMs});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['card_id'] = Variable<int>(cardId);
    map['review_date'] = Variable<DateTime>(reviewDate);
    map['performance_rating'] = Variable<int>(performanceRating);
    map['time_spent_ms'] = Variable<int>(timeSpentMs);
    return map;
  }

  ReviewStatsCompanion toCompanion(bool nullToAbsent) {
    return ReviewStatsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      reviewDate: Value(reviewDate),
      performanceRating: Value(performanceRating),
      timeSpentMs: Value(timeSpentMs),
    );
  }

  factory ReviewStatsDataClass.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewStatsDataClass(
      id: serializer.fromJson<int>(json['id']),
      cardId: serializer.fromJson<int>(json['cardId']),
      reviewDate: serializer.fromJson<DateTime>(json['reviewDate']),
      performanceRating: serializer.fromJson<int>(json['performanceRating']),
      timeSpentMs: serializer.fromJson<int>(json['timeSpentMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cardId': serializer.toJson<int>(cardId),
      'reviewDate': serializer.toJson<DateTime>(reviewDate),
      'performanceRating': serializer.toJson<int>(performanceRating),
      'timeSpentMs': serializer.toJson<int>(timeSpentMs),
    };
  }

  ReviewStatsDataClass copyWith(
          {int? id,
          int? cardId,
          DateTime? reviewDate,
          int? performanceRating,
          int? timeSpentMs}) =>
      ReviewStatsDataClass(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        reviewDate: reviewDate ?? this.reviewDate,
        performanceRating: performanceRating ?? this.performanceRating,
        timeSpentMs: timeSpentMs ?? this.timeSpentMs,
      );
  ReviewStatsDataClass copyWithCompanion(ReviewStatsCompanion data) {
    return ReviewStatsDataClass(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      reviewDate:
          data.reviewDate.present ? data.reviewDate.value : this.reviewDate,
      performanceRating: data.performanceRating.present
          ? data.performanceRating.value
          : this.performanceRating,
      timeSpentMs:
          data.timeSpentMs.present ? data.timeSpentMs.value : this.timeSpentMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewStatsDataClass(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('performanceRating: $performanceRating, ')
          ..write('timeSpentMs: $timeSpentMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cardId, reviewDate, performanceRating, timeSpentMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewStatsDataClass &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.reviewDate == this.reviewDate &&
          other.performanceRating == this.performanceRating &&
          other.timeSpentMs == this.timeSpentMs);
}

class ReviewStatsCompanion extends UpdateCompanion<ReviewStatsDataClass> {
  final Value<int> id;
  final Value<int> cardId;
  final Value<DateTime> reviewDate;
  final Value<int> performanceRating;
  final Value<int> timeSpentMs;
  const ReviewStatsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.reviewDate = const Value.absent(),
    this.performanceRating = const Value.absent(),
    this.timeSpentMs = const Value.absent(),
  });
  ReviewStatsCompanion.insert({
    this.id = const Value.absent(),
    required int cardId,
    required DateTime reviewDate,
    required int performanceRating,
    required int timeSpentMs,
  })  : cardId = Value(cardId),
        reviewDate = Value(reviewDate),
        performanceRating = Value(performanceRating),
        timeSpentMs = Value(timeSpentMs);
  static Insertable<ReviewStatsDataClass> custom({
    Expression<int>? id,
    Expression<int>? cardId,
    Expression<DateTime>? reviewDate,
    Expression<int>? performanceRating,
    Expression<int>? timeSpentMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (reviewDate != null) 'review_date': reviewDate,
      if (performanceRating != null) 'performance_rating': performanceRating,
      if (timeSpentMs != null) 'time_spent_ms': timeSpentMs,
    });
  }

  ReviewStatsCompanion copyWith(
      {Value<int>? id,
      Value<int>? cardId,
      Value<DateTime>? reviewDate,
      Value<int>? performanceRating,
      Value<int>? timeSpentMs}) {
    return ReviewStatsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      reviewDate: reviewDate ?? this.reviewDate,
      performanceRating: performanceRating ?? this.performanceRating,
      timeSpentMs: timeSpentMs ?? this.timeSpentMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<int>(cardId.value);
    }
    if (reviewDate.present) {
      map['review_date'] = Variable<DateTime>(reviewDate.value);
    }
    if (performanceRating.present) {
      map['performance_rating'] = Variable<int>(performanceRating.value);
    }
    if (timeSpentMs.present) {
      map['time_spent_ms'] = Variable<int>(timeSpentMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewStatsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('reviewDate: $reviewDate, ')
          ..write('performanceRating: $performanceRating, ')
          ..write('timeSpentMs: $timeSpentMs')
          ..write(')'))
        .toString();
  }
}

abstract class _$Database extends GeneratedDatabase {
  _$Database(QueryExecutor e) : super(e);
  $DatabaseManager get managers => $DatabaseManager(this);
  late final $DeckEntityTable deckEntity = $DeckEntityTable(this);
  late final $CardEntityTable cardEntity = $CardEntityTable(this);
  late final $ReviewStatsTable reviewStats = $ReviewStatsTable(this);
  late final DecksDao decksDao = DecksDao(this as Database);
  late final CardsDao cardsDao = CardsDao(this as Database);
  late final StatsDao statsDao = StatsDao(this as Database);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [deckEntity, cardEntity, reviewStats];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('deck_entity',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('card_entity', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('card_entity',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('review_stats', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$DeckEntityTableCreateCompanionBuilder = DeckEntityCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  Value<int> cardCount,
  Value<DateTime> createdAt,
  Value<DateTime> lastAccessed,
});
typedef $$DeckEntityTableUpdateCompanionBuilder = DeckEntityCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<int> cardCount,
  Value<DateTime> createdAt,
  Value<DateTime> lastAccessed,
});

final class $$DeckEntityTableReferences
    extends BaseReferences<_$Database, $DeckEntityTable, DeckEntityData> {
  $$DeckEntityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CardEntityTable, List<CardEntityData>>
      _cardEntityRefsTable(_$Database db) =>
          MultiTypedResultKey.fromTable(db.cardEntity,
              aliasName:
                  $_aliasNameGenerator(db.deckEntity.id, db.cardEntity.deckId));

  $$CardEntityTableProcessedTableManager get cardEntityRefs {
    final manager = $$CardEntityTableTableManager($_db, $_db.cardEntity)
        .filter((f) => f.deckId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cardEntityRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$DeckEntityTableFilterComposer
    extends Composer<_$Database, $DeckEntityTable> {
  $$DeckEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardCount => $composableBuilder(
      column: $table.cardCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => ColumnFilters(column));

  Expression<bool> cardEntityRefs(
      Expression<bool> Function($$CardEntityTableFilterComposer f) f) {
    final $$CardEntityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cardEntity,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardEntityTableFilterComposer(
              $db: $db,
              $table: $db.cardEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeckEntityTableOrderingComposer
    extends Composer<_$Database, $DeckEntityTable> {
  $$DeckEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardCount => $composableBuilder(
      column: $table.cardCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed,
      builder: (column) => ColumnOrderings(column));
}

class $$DeckEntityTableAnnotationComposer
    extends Composer<_$Database, $DeckEntityTable> {
  $$DeckEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get cardCount =>
      $composableBuilder(column: $table.cardCount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAccessed => $composableBuilder(
      column: $table.lastAccessed, builder: (column) => column);

  Expression<T> cardEntityRefs<T extends Object>(
      Expression<T> Function($$CardEntityTableAnnotationComposer a) f) {
    final $$CardEntityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.cardEntity,
        getReferencedColumn: (t) => t.deckId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardEntityTableAnnotationComposer(
              $db: $db,
              $table: $db.cardEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$DeckEntityTableTableManager extends RootTableManager<
    _$Database,
    $DeckEntityTable,
    DeckEntityData,
    $$DeckEntityTableFilterComposer,
    $$DeckEntityTableOrderingComposer,
    $$DeckEntityTableAnnotationComposer,
    $$DeckEntityTableCreateCompanionBuilder,
    $$DeckEntityTableUpdateCompanionBuilder,
    (DeckEntityData, $$DeckEntityTableReferences),
    DeckEntityData,
    PrefetchHooks Function({bool cardEntityRefs})> {
  $$DeckEntityTableTableManager(_$Database db, $DeckEntityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> cardCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastAccessed = const Value.absent(),
          }) =>
              DeckEntityCompanion(
            id: id,
            name: name,
            description: description,
            cardCount: cardCount,
            createdAt: createdAt,
            lastAccessed: lastAccessed,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            Value<int> cardCount = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> lastAccessed = const Value.absent(),
          }) =>
              DeckEntityCompanion.insert(
            id: id,
            name: name,
            description: description,
            cardCount: cardCount,
            createdAt: createdAt,
            lastAccessed: lastAccessed,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$DeckEntityTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cardEntityRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (cardEntityRefs) db.cardEntity],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardEntityRefs)
                    await $_getPrefetchedData<DeckEntityData, $DeckEntityTable,
                            CardEntityData>(
                        currentTable: table,
                        referencedTable: $$DeckEntityTableReferences
                            ._cardEntityRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$DeckEntityTableReferences(db, table, p0)
                                .cardEntityRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.deckId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$DeckEntityTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $DeckEntityTable,
    DeckEntityData,
    $$DeckEntityTableFilterComposer,
    $$DeckEntityTableOrderingComposer,
    $$DeckEntityTableAnnotationComposer,
    $$DeckEntityTableCreateCompanionBuilder,
    $$DeckEntityTableUpdateCompanionBuilder,
    (DeckEntityData, $$DeckEntityTableReferences),
    DeckEntityData,
    PrefetchHooks Function({bool cardEntityRefs})>;
typedef $$CardEntityTableCreateCompanionBuilder = CardEntityCompanion Function({
  Value<int> id,
  required int deckId,
  required String frontText,
  required String backText,
  Value<String> tags,
  Value<String?> frontImage,
  Value<String?> backImage,
  Value<String?> frontAudio,
  Value<String?> backAudio,
  Value<DateTime> createdAt,
  Value<DateTime?> lastReviewed,
  Value<int> interval,
  Value<double> easeFactor,
});
typedef $$CardEntityTableUpdateCompanionBuilder = CardEntityCompanion Function({
  Value<int> id,
  Value<int> deckId,
  Value<String> frontText,
  Value<String> backText,
  Value<String> tags,
  Value<String?> frontImage,
  Value<String?> backImage,
  Value<String?> frontAudio,
  Value<String?> backAudio,
  Value<DateTime> createdAt,
  Value<DateTime?> lastReviewed,
  Value<int> interval,
  Value<double> easeFactor,
});

final class $$CardEntityTableReferences
    extends BaseReferences<_$Database, $CardEntityTable, CardEntityData> {
  $$CardEntityTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DeckEntityTable _deckIdTable(_$Database db) =>
      db.deckEntity.createAlias(
          $_aliasNameGenerator(db.cardEntity.deckId, db.deckEntity.id));

  $$DeckEntityTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<int>('deck_id')!;

    final manager = $$DeckEntityTableTableManager($_db, $_db.deckEntity)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$ReviewStatsTable, List<ReviewStatsDataClass>>
      _reviewStatsRefsTable(_$Database db) => MultiTypedResultKey.fromTable(
          db.reviewStats,
          aliasName:
              $_aliasNameGenerator(db.cardEntity.id, db.reviewStats.cardId));

  $$ReviewStatsTableProcessedTableManager get reviewStatsRefs {
    final manager = $$ReviewStatsTableTableManager($_db, $_db.reviewStats)
        .filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_reviewStatsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CardEntityTableFilterComposer
    extends Composer<_$Database, $CardEntityTable> {
  $$CardEntityTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frontText => $composableBuilder(
      column: $table.frontText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backText => $composableBuilder(
      column: $table.backText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frontImage => $composableBuilder(
      column: $table.frontImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backImage => $composableBuilder(
      column: $table.backImage, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frontAudio => $composableBuilder(
      column: $table.frontAudio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backAudio => $composableBuilder(
      column: $table.backAudio, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReviewed => $composableBuilder(
      column: $table.lastReviewed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnFilters(column));

  $$DeckEntityTableFilterComposer get deckId {
    final $$DeckEntityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckEntityTableFilterComposer(
              $db: $db,
              $table: $db.deckEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> reviewStatsRefs(
      Expression<bool> Function($$ReviewStatsTableFilterComposer f) f) {
    final $$ReviewStatsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewStats,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewStatsTableFilterComposer(
              $db: $db,
              $table: $db.reviewStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CardEntityTableOrderingComposer
    extends Composer<_$Database, $CardEntityTable> {
  $$CardEntityTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frontText => $composableBuilder(
      column: $table.frontText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backText => $composableBuilder(
      column: $table.backText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frontImage => $composableBuilder(
      column: $table.frontImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backImage => $composableBuilder(
      column: $table.backImage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frontAudio => $composableBuilder(
      column: $table.frontAudio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backAudio => $composableBuilder(
      column: $table.backAudio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReviewed => $composableBuilder(
      column: $table.lastReviewed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => ColumnOrderings(column));

  $$DeckEntityTableOrderingComposer get deckId {
    final $$DeckEntityTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckEntityTableOrderingComposer(
              $db: $db,
              $table: $db.deckEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CardEntityTableAnnotationComposer
    extends Composer<_$Database, $CardEntityTable> {
  $$CardEntityTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frontText =>
      $composableBuilder(column: $table.frontText, builder: (column) => column);

  GeneratedColumn<String> get backText =>
      $composableBuilder(column: $table.backText, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get frontImage => $composableBuilder(
      column: $table.frontImage, builder: (column) => column);

  GeneratedColumn<String> get backImage =>
      $composableBuilder(column: $table.backImage, builder: (column) => column);

  GeneratedColumn<String> get frontAudio => $composableBuilder(
      column: $table.frontAudio, builder: (column) => column);

  GeneratedColumn<String> get backAudio =>
      $composableBuilder(column: $table.backAudio, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReviewed => $composableBuilder(
      column: $table.lastReviewed, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<double> get easeFactor => $composableBuilder(
      column: $table.easeFactor, builder: (column) => column);

  $$DeckEntityTableAnnotationComposer get deckId {
    final $$DeckEntityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.deckId,
        referencedTable: $db.deckEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$DeckEntityTableAnnotationComposer(
              $db: $db,
              $table: $db.deckEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> reviewStatsRefs<T extends Object>(
      Expression<T> Function($$ReviewStatsTableAnnotationComposer a) f) {
    final $$ReviewStatsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.reviewStats,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewStatsTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewStats,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CardEntityTableTableManager extends RootTableManager<
    _$Database,
    $CardEntityTable,
    CardEntityData,
    $$CardEntityTableFilterComposer,
    $$CardEntityTableOrderingComposer,
    $$CardEntityTableAnnotationComposer,
    $$CardEntityTableCreateCompanionBuilder,
    $$CardEntityTableUpdateCompanionBuilder,
    (CardEntityData, $$CardEntityTableReferences),
    CardEntityData,
    PrefetchHooks Function({bool deckId, bool reviewStatsRefs})> {
  $$CardEntityTableTableManager(_$Database db, $CardEntityTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardEntityTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardEntityTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardEntityTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> deckId = const Value.absent(),
            Value<String> frontText = const Value.absent(),
            Value<String> backText = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<String?> frontImage = const Value.absent(),
            Value<String?> backImage = const Value.absent(),
            Value<String?> frontAudio = const Value.absent(),
            Value<String?> backAudio = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastReviewed = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
          }) =>
              CardEntityCompanion(
            id: id,
            deckId: deckId,
            frontText: frontText,
            backText: backText,
            tags: tags,
            frontImage: frontImage,
            backImage: backImage,
            frontAudio: frontAudio,
            backAudio: backAudio,
            createdAt: createdAt,
            lastReviewed: lastReviewed,
            interval: interval,
            easeFactor: easeFactor,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int deckId,
            required String frontText,
            required String backText,
            Value<String> tags = const Value.absent(),
            Value<String?> frontImage = const Value.absent(),
            Value<String?> backImage = const Value.absent(),
            Value<String?> frontAudio = const Value.absent(),
            Value<String?> backAudio = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> lastReviewed = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<double> easeFactor = const Value.absent(),
          }) =>
              CardEntityCompanion.insert(
            id: id,
            deckId: deckId,
            frontText: frontText,
            backText: backText,
            tags: tags,
            frontImage: frontImage,
            backImage: backImage,
            frontAudio: frontAudio,
            backAudio: backAudio,
            createdAt: createdAt,
            lastReviewed: lastReviewed,
            interval: interval,
            easeFactor: easeFactor,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CardEntityTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({deckId = false, reviewStatsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (reviewStatsRefs) db.reviewStats],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (deckId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.deckId,
                    referencedTable:
                        $$CardEntityTableReferences._deckIdTable(db),
                    referencedColumn:
                        $$CardEntityTableReferences._deckIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (reviewStatsRefs)
                    await $_getPrefetchedData<CardEntityData, $CardEntityTable,
                            ReviewStatsDataClass>(
                        currentTable: table,
                        referencedTable: $$CardEntityTableReferences
                            ._reviewStatsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CardEntityTableReferences(db, table, p0)
                                .reviewStatsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cardId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CardEntityTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $CardEntityTable,
    CardEntityData,
    $$CardEntityTableFilterComposer,
    $$CardEntityTableOrderingComposer,
    $$CardEntityTableAnnotationComposer,
    $$CardEntityTableCreateCompanionBuilder,
    $$CardEntityTableUpdateCompanionBuilder,
    (CardEntityData, $$CardEntityTableReferences),
    CardEntityData,
    PrefetchHooks Function({bool deckId, bool reviewStatsRefs})>;
typedef $$ReviewStatsTableCreateCompanionBuilder = ReviewStatsCompanion
    Function({
  Value<int> id,
  required int cardId,
  required DateTime reviewDate,
  required int performanceRating,
  required int timeSpentMs,
});
typedef $$ReviewStatsTableUpdateCompanionBuilder = ReviewStatsCompanion
    Function({
  Value<int> id,
  Value<int> cardId,
  Value<DateTime> reviewDate,
  Value<int> performanceRating,
  Value<int> timeSpentMs,
});

final class $$ReviewStatsTableReferences extends BaseReferences<_$Database,
    $ReviewStatsTable, ReviewStatsDataClass> {
  $$ReviewStatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CardEntityTable _cardIdTable(_$Database db) =>
      db.cardEntity.createAlias(
          $_aliasNameGenerator(db.reviewStats.cardId, db.cardEntity.id));

  $$CardEntityTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<int>('card_id')!;

    final manager = $$CardEntityTableTableManager($_db, $_db.cardEntity)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ReviewStatsTableFilterComposer
    extends Composer<_$Database, $ReviewStatsTable> {
  $$ReviewStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get performanceRating => $composableBuilder(
      column: $table.performanceRating,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timeSpentMs => $composableBuilder(
      column: $table.timeSpentMs, builder: (column) => ColumnFilters(column));

  $$CardEntityTableFilterComposer get cardId {
    final $$CardEntityTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cardEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardEntityTableFilterComposer(
              $db: $db,
              $table: $db.cardEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewStatsTableOrderingComposer
    extends Composer<_$Database, $ReviewStatsTable> {
  $$ReviewStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get performanceRating => $composableBuilder(
      column: $table.performanceRating,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timeSpentMs => $composableBuilder(
      column: $table.timeSpentMs, builder: (column) => ColumnOrderings(column));

  $$CardEntityTableOrderingComposer get cardId {
    final $$CardEntityTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cardEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardEntityTableOrderingComposer(
              $db: $db,
              $table: $db.cardEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewStatsTableAnnotationComposer
    extends Composer<_$Database, $ReviewStatsTable> {
  $$ReviewStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get reviewDate => $composableBuilder(
      column: $table.reviewDate, builder: (column) => column);

  GeneratedColumn<int> get performanceRating => $composableBuilder(
      column: $table.performanceRating, builder: (column) => column);

  GeneratedColumn<int> get timeSpentMs => $composableBuilder(
      column: $table.timeSpentMs, builder: (column) => column);

  $$CardEntityTableAnnotationComposer get cardId {
    final $$CardEntityTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.cardEntity,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardEntityTableAnnotationComposer(
              $db: $db,
              $table: $db.cardEntity,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ReviewStatsTableTableManager extends RootTableManager<
    _$Database,
    $ReviewStatsTable,
    ReviewStatsDataClass,
    $$ReviewStatsTableFilterComposer,
    $$ReviewStatsTableOrderingComposer,
    $$ReviewStatsTableAnnotationComposer,
    $$ReviewStatsTableCreateCompanionBuilder,
    $$ReviewStatsTableUpdateCompanionBuilder,
    (ReviewStatsDataClass, $$ReviewStatsTableReferences),
    ReviewStatsDataClass,
    PrefetchHooks Function({bool cardId})> {
  $$ReviewStatsTableTableManager(_$Database db, $ReviewStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> cardId = const Value.absent(),
            Value<DateTime> reviewDate = const Value.absent(),
            Value<int> performanceRating = const Value.absent(),
            Value<int> timeSpentMs = const Value.absent(),
          }) =>
              ReviewStatsCompanion(
            id: id,
            cardId: cardId,
            reviewDate: reviewDate,
            performanceRating: performanceRating,
            timeSpentMs: timeSpentMs,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int cardId,
            required DateTime reviewDate,
            required int performanceRating,
            required int timeSpentMs,
          }) =>
              ReviewStatsCompanion.insert(
            id: id,
            cardId: cardId,
            reviewDate: reviewDate,
            performanceRating: performanceRating,
            timeSpentMs: timeSpentMs,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReviewStatsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cardId,
                    referencedTable:
                        $$ReviewStatsTableReferences._cardIdTable(db),
                    referencedColumn:
                        $$ReviewStatsTableReferences._cardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ReviewStatsTableProcessedTableManager = ProcessedTableManager<
    _$Database,
    $ReviewStatsTable,
    ReviewStatsDataClass,
    $$ReviewStatsTableFilterComposer,
    $$ReviewStatsTableOrderingComposer,
    $$ReviewStatsTableAnnotationComposer,
    $$ReviewStatsTableCreateCompanionBuilder,
    $$ReviewStatsTableUpdateCompanionBuilder,
    (ReviewStatsDataClass, $$ReviewStatsTableReferences),
    ReviewStatsDataClass,
    PrefetchHooks Function({bool cardId})>;

class $DatabaseManager {
  final _$Database _db;
  $DatabaseManager(this._db);
  $$DeckEntityTableTableManager get deckEntity =>
      $$DeckEntityTableTableManager(_db, _db.deckEntity);
  $$CardEntityTableTableManager get cardEntity =>
      $$CardEntityTableTableManager(_db, _db.cardEntity);
  $$ReviewStatsTableTableManager get reviewStats =>
      $$ReviewStatsTableTableManager(_db, _db.reviewStats);
}

mixin _$DecksDaoMixin on DatabaseAccessor<Database> {
  $DeckEntityTable get deckEntity => attachedDatabase.deckEntity;
}
mixin _$CardsDaoMixin on DatabaseAccessor<Database> {
  $DeckEntityTable get deckEntity => attachedDatabase.deckEntity;
  $CardEntityTable get cardEntity => attachedDatabase.cardEntity;
}
mixin _$StatsDaoMixin on DatabaseAccessor<Database> {
  $DeckEntityTable get deckEntity => attachedDatabase.deckEntity;
  $CardEntityTable get cardEntity => attachedDatabase.cardEntity;
  $ReviewStatsTable get reviewStats => attachedDatabase.reviewStats;
}
