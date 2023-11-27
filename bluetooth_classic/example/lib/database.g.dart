// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PreviousRecordTable extends PreviousRecord
    with TableInfo<$PreviousRecordTable, PreviousRecordData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreviousRecordTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 11),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _brushingTimeMeta =
      const VerificationMeta('brushingTime');
  @override
  late final GeneratedColumn<String> brushingTime = GeneratedColumn<String>(
      'brushing_time', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 6),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _sectionRatioMeta =
      const VerificationMeta('sectionRatio');
  @override
  late final GeneratedColumn<String> sectionRatio = GeneratedColumn<String>(
      'section_ratio', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 15),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _brushingMethodMeta =
      const VerificationMeta('brushingMethod');
  @override
  late final GeneratedColumn<String> brushingMethod = GeneratedColumn<String>(
      'brushing_method', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 8),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, brushingTime, sectionRatio, brushingMethod];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'previous_record';
  @override
  VerificationContext validateIntegrity(Insertable<PreviousRecordData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('brushing_time')) {
      context.handle(
          _brushingTimeMeta,
          brushingTime.isAcceptableOrUnknown(
              data['brushing_time']!, _brushingTimeMeta));
    } else if (isInserting) {
      context.missing(_brushingTimeMeta);
    }
    if (data.containsKey('section_ratio')) {
      context.handle(
          _sectionRatioMeta,
          sectionRatio.isAcceptableOrUnknown(
              data['section_ratio']!, _sectionRatioMeta));
    } else if (isInserting) {
      context.missing(_sectionRatioMeta);
    }
    if (data.containsKey('brushing_method')) {
      context.handle(
          _brushingMethodMeta,
          brushingMethod.isAcceptableOrUnknown(
              data['brushing_method']!, _brushingMethodMeta));
    } else if (isInserting) {
      context.missing(_brushingMethodMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreviousRecordData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreviousRecordData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      brushingTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brushing_time'])!,
      sectionRatio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}section_ratio'])!,
      brushingMethod: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}brushing_method'])!,
    );
  }

  @override
  $PreviousRecordTable createAlias(String alias) {
    return $PreviousRecordTable(attachedDatabase, alias);
  }
}

class PreviousRecordData extends DataClass
    implements Insertable<PreviousRecordData> {
  final int id;
  final String date;
  final String brushingTime;
  final String sectionRatio;
  final String brushingMethod;
  const PreviousRecordData(
      {required this.id,
      required this.date,
      required this.brushingTime,
      required this.sectionRatio,
      required this.brushingMethod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['brushing_time'] = Variable<String>(brushingTime);
    map['section_ratio'] = Variable<String>(sectionRatio);
    map['brushing_method'] = Variable<String>(brushingMethod);
    return map;
  }

  PreviousRecordCompanion toCompanion(bool nullToAbsent) {
    return PreviousRecordCompanion(
      id: Value(id),
      date: Value(date),
      brushingTime: Value(brushingTime),
      sectionRatio: Value(sectionRatio),
      brushingMethod: Value(brushingMethod),
    );
  }

  factory PreviousRecordData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreviousRecordData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      brushingTime: serializer.fromJson<String>(json['brushingTime']),
      sectionRatio: serializer.fromJson<String>(json['sectionRatio']),
      brushingMethod: serializer.fromJson<String>(json['brushingMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'brushingTime': serializer.toJson<String>(brushingTime),
      'sectionRatio': serializer.toJson<String>(sectionRatio),
      'brushingMethod': serializer.toJson<String>(brushingMethod),
    };
  }

  PreviousRecordData copyWith(
          {int? id,
          String? date,
          String? brushingTime,
          String? sectionRatio,
          String? brushingMethod}) =>
      PreviousRecordData(
        id: id ?? this.id,
        date: date ?? this.date,
        brushingTime: brushingTime ?? this.brushingTime,
        sectionRatio: sectionRatio ?? this.sectionRatio,
        brushingMethod: brushingMethod ?? this.brushingMethod,
      );
  @override
  String toString() {
    return (StringBuffer('PreviousRecordData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('brushingTime: $brushingTime, ')
          ..write('sectionRatio: $sectionRatio, ')
          ..write('brushingMethod: $brushingMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, brushingTime, sectionRatio, brushingMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreviousRecordData &&
          other.id == this.id &&
          other.date == this.date &&
          other.brushingTime == this.brushingTime &&
          other.sectionRatio == this.sectionRatio &&
          other.brushingMethod == this.brushingMethod);
}

class PreviousRecordCompanion extends UpdateCompanion<PreviousRecordData> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> brushingTime;
  final Value<String> sectionRatio;
  final Value<String> brushingMethod;
  const PreviousRecordCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.brushingTime = const Value.absent(),
    this.sectionRatio = const Value.absent(),
    this.brushingMethod = const Value.absent(),
  });
  PreviousRecordCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String brushingTime,
    required String sectionRatio,
    required String brushingMethod,
  })  : date = Value(date),
        brushingTime = Value(brushingTime),
        sectionRatio = Value(sectionRatio),
        brushingMethod = Value(brushingMethod);
  static Insertable<PreviousRecordData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? brushingTime,
    Expression<String>? sectionRatio,
    Expression<String>? brushingMethod,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (brushingTime != null) 'brushing_time': brushingTime,
      if (sectionRatio != null) 'section_ratio': sectionRatio,
      if (brushingMethod != null) 'brushing_method': brushingMethod,
    });
  }

  PreviousRecordCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? brushingTime,
      Value<String>? sectionRatio,
      Value<String>? brushingMethod}) {
    return PreviousRecordCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      brushingTime: brushingTime ?? this.brushingTime,
      sectionRatio: sectionRatio ?? this.sectionRatio,
      brushingMethod: brushingMethod ?? this.brushingMethod,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (brushingTime.present) {
      map['brushing_time'] = Variable<String>(brushingTime.value);
    }
    if (sectionRatio.present) {
      map['section_ratio'] = Variable<String>(sectionRatio.value);
    }
    if (brushingMethod.present) {
      map['brushing_method'] = Variable<String>(brushingMethod.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreviousRecordCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('brushingTime: $brushingTime, ')
          ..write('sectionRatio: $sectionRatio, ')
          ..write('brushingMethod: $brushingMethod')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $PreviousRecordTable previousRecord = $PreviousRecordTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [previousRecord];
}
