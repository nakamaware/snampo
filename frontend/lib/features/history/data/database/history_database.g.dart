// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_database.dart';

// ignore_for_file: type=lint
class $MissionHistoriesTable extends MissionHistories
    with TableInfo<$MissionHistoriesTable, MissionHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureLatMeta = const VerificationMeta(
    'departureLat',
  );
  @override
  late final GeneratedColumn<double> departureLat = GeneratedColumn<double>(
    'departure_lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureLngMeta = const VerificationMeta(
    'departureLng',
  );
  @override
  late final GeneratedColumn<double> departureLng = GeneratedColumn<double>(
    'departure_lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overviewPolylineMeta = const VerificationMeta(
    'overviewPolyline',
  );
  @override
  late final GeneratedColumn<String> overviewPolyline = GeneratedColumn<String>(
    'overview_polyline',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<int> radiusMeters = GeneratedColumn<int>(
    'radius_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('random'),
  );
  static const VerificationMeta _destinationLatMeta = const VerificationMeta(
    'destinationLat',
  );
  @override
  late final GeneratedColumn<double> destinationLat = GeneratedColumn<double>(
    'destination_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _destinationLngMeta = const VerificationMeta(
    'destinationLng',
  );
  @override
  late final GeneratedColumn<double> destinationLng = GeneratedColumn<double>(
    'destination_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    completedAt,
    startedAt,
    departureLat,
    departureLng,
    overviewPolyline,
    radiusMeters,
    mode,
    destinationLat,
    destinationLng,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mission_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MissionHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('departure_lat')) {
      context.handle(
        _departureLatMeta,
        departureLat.isAcceptableOrUnknown(
          data['departure_lat']!,
          _departureLatMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureLatMeta);
    }
    if (data.containsKey('departure_lng')) {
      context.handle(
        _departureLngMeta,
        departureLng.isAcceptableOrUnknown(
          data['departure_lng']!,
          _departureLngMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_departureLngMeta);
    }
    if (data.containsKey('overview_polyline')) {
      context.handle(
        _overviewPolylineMeta,
        overviewPolyline.isAcceptableOrUnknown(
          data['overview_polyline']!,
          _overviewPolylineMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overviewPolylineMeta);
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('destination_lat')) {
      context.handle(
        _destinationLatMeta,
        destinationLat.isAcceptableOrUnknown(
          data['destination_lat']!,
          _destinationLatMeta,
        ),
      );
    }
    if (data.containsKey('destination_lng')) {
      context.handle(
        _destinationLngMeta,
        destinationLng.isAcceptableOrUnknown(
          data['destination_lng']!,
          _destinationLngMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MissionHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MissionHistoryRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      completedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}completed_at'],
          )!,
      startedAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}started_at'],
          )!,
      departureLat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}departure_lat'],
          )!,
      departureLng:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}departure_lng'],
          )!,
      overviewPolyline:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}overview_polyline'],
          )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}radius_meters'],
      ),
      mode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}mode'],
          )!,
      destinationLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lat'],
      ),
      destinationLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}destination_lng'],
      ),
    );
  }

  @override
  $MissionHistoriesTable createAlias(String alias) {
    return $MissionHistoriesTable(attachedDatabase, alias);
  }
}

class MissionHistoryRow extends DataClass
    implements Insertable<MissionHistoryRow> {
  /// 履歴レコード ID (UUID)
  final String id;

  /// 完了日時 (Unix ms)
  final int completedAt;

  /// 開始日時 (Unix ms)
  final int startedAt;

  /// 出発地緯度
  final double departureLat;

  /// 出発地経度
  final double departureLng;

  /// ルート概要のエンコード済みポリライン
  final String overviewPolyline;

  /// 探索半径 (m)。目的地指定モードでは null
  final int? radiusMeters;

  /// ミッション開始モード: `random` / `destination`
  final String mode;

  /// ユーザーが指定した目的地の緯度 (ランダムモードでは null)
  final double? destinationLat;

  /// ユーザーが指定した目的地の経度 (ランダムモードでは null)
  final double? destinationLng;
  const MissionHistoryRow({
    required this.id,
    required this.completedAt,
    required this.startedAt,
    required this.departureLat,
    required this.departureLng,
    required this.overviewPolyline,
    this.radiusMeters,
    required this.mode,
    this.destinationLat,
    this.destinationLng,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['completed_at'] = Variable<int>(completedAt);
    map['started_at'] = Variable<int>(startedAt);
    map['departure_lat'] = Variable<double>(departureLat);
    map['departure_lng'] = Variable<double>(departureLng);
    map['overview_polyline'] = Variable<String>(overviewPolyline);
    if (!nullToAbsent || radiusMeters != null) {
      map['radius_meters'] = Variable<int>(radiusMeters);
    }
    map['mode'] = Variable<String>(mode);
    if (!nullToAbsent || destinationLat != null) {
      map['destination_lat'] = Variable<double>(destinationLat);
    }
    if (!nullToAbsent || destinationLng != null) {
      map['destination_lng'] = Variable<double>(destinationLng);
    }
    return map;
  }

  MissionHistoriesCompanion toCompanion(bool nullToAbsent) {
    return MissionHistoriesCompanion(
      id: Value(id),
      completedAt: Value(completedAt),
      startedAt: Value(startedAt),
      departureLat: Value(departureLat),
      departureLng: Value(departureLng),
      overviewPolyline: Value(overviewPolyline),
      radiusMeters:
          radiusMeters == null && nullToAbsent
              ? const Value.absent()
              : Value(radiusMeters),
      mode: Value(mode),
      destinationLat:
          destinationLat == null && nullToAbsent
              ? const Value.absent()
              : Value(destinationLat),
      destinationLng:
          destinationLng == null && nullToAbsent
              ? const Value.absent()
              : Value(destinationLng),
    );
  }

  factory MissionHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MissionHistoryRow(
      id: serializer.fromJson<String>(json['id']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
      startedAt: serializer.fromJson<int>(json['startedAt']),
      departureLat: serializer.fromJson<double>(json['departureLat']),
      departureLng: serializer.fromJson<double>(json['departureLng']),
      overviewPolyline: serializer.fromJson<String>(json['overviewPolyline']),
      radiusMeters: serializer.fromJson<int?>(json['radiusMeters']),
      mode: serializer.fromJson<String>(json['mode']),
      destinationLat: serializer.fromJson<double?>(json['destinationLat']),
      destinationLng: serializer.fromJson<double?>(json['destinationLng']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'completedAt': serializer.toJson<int>(completedAt),
      'startedAt': serializer.toJson<int>(startedAt),
      'departureLat': serializer.toJson<double>(departureLat),
      'departureLng': serializer.toJson<double>(departureLng),
      'overviewPolyline': serializer.toJson<String>(overviewPolyline),
      'radiusMeters': serializer.toJson<int?>(radiusMeters),
      'mode': serializer.toJson<String>(mode),
      'destinationLat': serializer.toJson<double?>(destinationLat),
      'destinationLng': serializer.toJson<double?>(destinationLng),
    };
  }

  MissionHistoryRow copyWith({
    String? id,
    int? completedAt,
    int? startedAt,
    double? departureLat,
    double? departureLng,
    String? overviewPolyline,
    Value<int?> radiusMeters = const Value.absent(),
    String? mode,
    Value<double?> destinationLat = const Value.absent(),
    Value<double?> destinationLng = const Value.absent(),
  }) => MissionHistoryRow(
    id: id ?? this.id,
    completedAt: completedAt ?? this.completedAt,
    startedAt: startedAt ?? this.startedAt,
    departureLat: departureLat ?? this.departureLat,
    departureLng: departureLng ?? this.departureLng,
    overviewPolyline: overviewPolyline ?? this.overviewPolyline,
    radiusMeters: radiusMeters.present ? radiusMeters.value : this.radiusMeters,
    mode: mode ?? this.mode,
    destinationLat:
        destinationLat.present ? destinationLat.value : this.destinationLat,
    destinationLng:
        destinationLng.present ? destinationLng.value : this.destinationLng,
  );
  MissionHistoryRow copyWithCompanion(MissionHistoriesCompanion data) {
    return MissionHistoryRow(
      id: data.id.present ? data.id.value : this.id,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      departureLat:
          data.departureLat.present
              ? data.departureLat.value
              : this.departureLat,
      departureLng:
          data.departureLng.present
              ? data.departureLng.value
              : this.departureLng,
      overviewPolyline:
          data.overviewPolyline.present
              ? data.overviewPolyline.value
              : this.overviewPolyline,
      radiusMeters:
          data.radiusMeters.present
              ? data.radiusMeters.value
              : this.radiusMeters,
      mode: data.mode.present ? data.mode.value : this.mode,
      destinationLat:
          data.destinationLat.present
              ? data.destinationLat.value
              : this.destinationLat,
      destinationLng:
          data.destinationLng.present
              ? data.destinationLng.value
              : this.destinationLng,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MissionHistoryRow(')
          ..write('id: $id, ')
          ..write('completedAt: $completedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('departureLat: $departureLat, ')
          ..write('departureLng: $departureLng, ')
          ..write('overviewPolyline: $overviewPolyline, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('mode: $mode, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    completedAt,
    startedAt,
    departureLat,
    departureLng,
    overviewPolyline,
    radiusMeters,
    mode,
    destinationLat,
    destinationLng,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MissionHistoryRow &&
          other.id == this.id &&
          other.completedAt == this.completedAt &&
          other.startedAt == this.startedAt &&
          other.departureLat == this.departureLat &&
          other.departureLng == this.departureLng &&
          other.overviewPolyline == this.overviewPolyline &&
          other.radiusMeters == this.radiusMeters &&
          other.mode == this.mode &&
          other.destinationLat == this.destinationLat &&
          other.destinationLng == this.destinationLng);
}

class MissionHistoriesCompanion extends UpdateCompanion<MissionHistoryRow> {
  final Value<String> id;
  final Value<int> completedAt;
  final Value<int> startedAt;
  final Value<double> departureLat;
  final Value<double> departureLng;
  final Value<String> overviewPolyline;
  final Value<int?> radiusMeters;
  final Value<String> mode;
  final Value<double?> destinationLat;
  final Value<double?> destinationLng;
  final Value<int> rowid;
  const MissionHistoriesCompanion({
    this.id = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.departureLat = const Value.absent(),
    this.departureLng = const Value.absent(),
    this.overviewPolyline = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.mode = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionHistoriesCompanion.insert({
    required String id,
    required int completedAt,
    required int startedAt,
    required double departureLat,
    required double departureLng,
    required String overviewPolyline,
    this.radiusMeters = const Value.absent(),
    this.mode = const Value.absent(),
    this.destinationLat = const Value.absent(),
    this.destinationLng = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       completedAt = Value(completedAt),
       startedAt = Value(startedAt),
       departureLat = Value(departureLat),
       departureLng = Value(departureLng),
       overviewPolyline = Value(overviewPolyline);
  static Insertable<MissionHistoryRow> custom({
    Expression<String>? id,
    Expression<int>? completedAt,
    Expression<int>? startedAt,
    Expression<double>? departureLat,
    Expression<double>? departureLng,
    Expression<String>? overviewPolyline,
    Expression<int>? radiusMeters,
    Expression<String>? mode,
    Expression<double>? destinationLat,
    Expression<double>? destinationLng,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (completedAt != null) 'completed_at': completedAt,
      if (startedAt != null) 'started_at': startedAt,
      if (departureLat != null) 'departure_lat': departureLat,
      if (departureLng != null) 'departure_lng': departureLng,
      if (overviewPolyline != null) 'overview_polyline': overviewPolyline,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (mode != null) 'mode': mode,
      if (destinationLat != null) 'destination_lat': destinationLat,
      if (destinationLng != null) 'destination_lng': destinationLng,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionHistoriesCompanion copyWith({
    Value<String>? id,
    Value<int>? completedAt,
    Value<int>? startedAt,
    Value<double>? departureLat,
    Value<double>? departureLng,
    Value<String>? overviewPolyline,
    Value<int?>? radiusMeters,
    Value<String>? mode,
    Value<double?>? destinationLat,
    Value<double?>? destinationLng,
    Value<int>? rowid,
  }) {
    return MissionHistoriesCompanion(
      id: id ?? this.id,
      completedAt: completedAt ?? this.completedAt,
      startedAt: startedAt ?? this.startedAt,
      departureLat: departureLat ?? this.departureLat,
      departureLng: departureLng ?? this.departureLng,
      overviewPolyline: overviewPolyline ?? this.overviewPolyline,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      mode: mode ?? this.mode,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (departureLat.present) {
      map['departure_lat'] = Variable<double>(departureLat.value);
    }
    if (departureLng.present) {
      map['departure_lng'] = Variable<double>(departureLng.value);
    }
    if (overviewPolyline.present) {
      map['overview_polyline'] = Variable<String>(overviewPolyline.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<int>(radiusMeters.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (destinationLat.present) {
      map['destination_lat'] = Variable<double>(destinationLat.value);
    }
    if (destinationLng.present) {
      map['destination_lng'] = Variable<double>(destinationLng.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionHistoriesCompanion(')
          ..write('id: $id, ')
          ..write('completedAt: $completedAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('departureLat: $departureLat, ')
          ..write('departureLng: $departureLng, ')
          ..write('overviewPolyline: $overviewPolyline, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('mode: $mode, ')
          ..write('destinationLat: $destinationLat, ')
          ..write('destinationLng: $destinationLng, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HistorySpotsTable extends HistorySpots
    with TableInfo<$HistorySpotsTable, HistorySpotRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HistorySpotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _historyIdMeta = const VerificationMeta(
    'historyId',
  );
  @override
  late final GeneratedColumn<String> historyId = GeneratedColumn<String>(
    'history_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES mission_histories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDestinationMeta = const VerificationMeta(
    'isDestination',
  );
  @override
  late final GeneratedColumn<int> isDestination = GeneratedColumn<int>(
    'is_destination',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latMeta = const VerificationMeta('lat');
  @override
  late final GeneratedColumn<double> lat = GeneratedColumn<double>(
    'lat',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lngMeta = const VerificationMeta('lng');
  @override
  late final GeneratedColumn<double> lng = GeneratedColumn<double>(
    'lng',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _streetViewImagePathMeta =
      const VerificationMeta('streetViewImagePath');
  @override
  late final GeneratedColumn<String> streetViewImagePath =
      GeneratedColumn<String>(
        'street_view_image_path',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userPhotoPathMeta = const VerificationMeta(
    'userPhotoPath',
  );
  @override
  late final GeneratedColumn<String> userPhotoPath = GeneratedColumn<String>(
    'user_photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<int> achievedAt = GeneratedColumn<int>(
    'achieved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    historyId,
    sortOrder,
    isDestination,
    lat,
    lng,
    streetViewImagePath,
    userPhotoPath,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'history_spots';
  @override
  VerificationContext validateIntegrity(
    Insertable<HistorySpotRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('history_id')) {
      context.handle(
        _historyIdMeta,
        historyId.isAcceptableOrUnknown(data['history_id']!, _historyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_historyIdMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_destination')) {
      context.handle(
        _isDestinationMeta,
        isDestination.isAcceptableOrUnknown(
          data['is_destination']!,
          _isDestinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isDestinationMeta);
    }
    if (data.containsKey('lat')) {
      context.handle(
        _latMeta,
        lat.isAcceptableOrUnknown(data['lat']!, _latMeta),
      );
    } else if (isInserting) {
      context.missing(_latMeta);
    }
    if (data.containsKey('lng')) {
      context.handle(
        _lngMeta,
        lng.isAcceptableOrUnknown(data['lng']!, _lngMeta),
      );
    } else if (isInserting) {
      context.missing(_lngMeta);
    }
    if (data.containsKey('street_view_image_path')) {
      context.handle(
        _streetViewImagePathMeta,
        streetViewImagePath.isAcceptableOrUnknown(
          data['street_view_image_path']!,
          _streetViewImagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_streetViewImagePathMeta);
    }
    if (data.containsKey('user_photo_path')) {
      context.handle(
        _userPhotoPathMeta,
        userPhotoPath.isAcceptableOrUnknown(
          data['user_photo_path']!,
          _userPhotoPathMeta,
        ),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HistorySpotRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HistorySpotRow(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      historyId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}history_id'],
          )!,
      sortOrder:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}sort_order'],
          )!,
      isDestination:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_destination'],
          )!,
      lat:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lat'],
          )!,
      lng:
          attachedDatabase.typeMapping.read(
            DriftSqlType.double,
            data['${effectivePrefix}lng'],
          )!,
      streetViewImagePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}street_view_image_path'],
          )!,
      userPhotoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_photo_path'],
      ),
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_at'],
      ),
    );
  }

  @override
  $HistorySpotsTable createAlias(String alias) {
    return $HistorySpotsTable(attachedDatabase, alias);
  }
}

class HistorySpotRow extends DataClass implements Insertable<HistorySpotRow> {
  /// 行 ID (自動採番)
  final int id;

  /// [MissionHistories.id] への外部キー
  final String historyId;

  /// 経路順 (0 始まり、最後が目的地)
  final int sortOrder;

  /// 目的地なら 1、経由地なら 0
  final int isDestination;

  /// スポット緯度
  final double lat;

  /// スポット経度
  final double lng;

  /// Street View 画像ファイルの絶対パス
  final String streetViewImagePath;

  /// ユーザー撮影写真のパス (あれば)
  final String? userPhotoPath;

  /// チェックポイント達成日時 (Unix ms)
  final int? achievedAt;
  const HistorySpotRow({
    required this.id,
    required this.historyId,
    required this.sortOrder,
    required this.isDestination,
    required this.lat,
    required this.lng,
    required this.streetViewImagePath,
    this.userPhotoPath,
    this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['history_id'] = Variable<String>(historyId);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_destination'] = Variable<int>(isDestination);
    map['lat'] = Variable<double>(lat);
    map['lng'] = Variable<double>(lng);
    map['street_view_image_path'] = Variable<String>(streetViewImagePath);
    if (!nullToAbsent || userPhotoPath != null) {
      map['user_photo_path'] = Variable<String>(userPhotoPath);
    }
    if (!nullToAbsent || achievedAt != null) {
      map['achieved_at'] = Variable<int>(achievedAt);
    }
    return map;
  }

  HistorySpotsCompanion toCompanion(bool nullToAbsent) {
    return HistorySpotsCompanion(
      id: Value(id),
      historyId: Value(historyId),
      sortOrder: Value(sortOrder),
      isDestination: Value(isDestination),
      lat: Value(lat),
      lng: Value(lng),
      streetViewImagePath: Value(streetViewImagePath),
      userPhotoPath:
          userPhotoPath == null && nullToAbsent
              ? const Value.absent()
              : Value(userPhotoPath),
      achievedAt:
          achievedAt == null && nullToAbsent
              ? const Value.absent()
              : Value(achievedAt),
    );
  }

  factory HistorySpotRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HistorySpotRow(
      id: serializer.fromJson<int>(json['id']),
      historyId: serializer.fromJson<String>(json['historyId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isDestination: serializer.fromJson<int>(json['isDestination']),
      lat: serializer.fromJson<double>(json['lat']),
      lng: serializer.fromJson<double>(json['lng']),
      streetViewImagePath: serializer.fromJson<String>(
        json['streetViewImagePath'],
      ),
      userPhotoPath: serializer.fromJson<String?>(json['userPhotoPath']),
      achievedAt: serializer.fromJson<int?>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'historyId': serializer.toJson<String>(historyId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isDestination': serializer.toJson<int>(isDestination),
      'lat': serializer.toJson<double>(lat),
      'lng': serializer.toJson<double>(lng),
      'streetViewImagePath': serializer.toJson<String>(streetViewImagePath),
      'userPhotoPath': serializer.toJson<String?>(userPhotoPath),
      'achievedAt': serializer.toJson<int?>(achievedAt),
    };
  }

  HistorySpotRow copyWith({
    int? id,
    String? historyId,
    int? sortOrder,
    int? isDestination,
    double? lat,
    double? lng,
    String? streetViewImagePath,
    Value<String?> userPhotoPath = const Value.absent(),
    Value<int?> achievedAt = const Value.absent(),
  }) => HistorySpotRow(
    id: id ?? this.id,
    historyId: historyId ?? this.historyId,
    sortOrder: sortOrder ?? this.sortOrder,
    isDestination: isDestination ?? this.isDestination,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    streetViewImagePath: streetViewImagePath ?? this.streetViewImagePath,
    userPhotoPath:
        userPhotoPath.present ? userPhotoPath.value : this.userPhotoPath,
    achievedAt: achievedAt.present ? achievedAt.value : this.achievedAt,
  );
  HistorySpotRow copyWithCompanion(HistorySpotsCompanion data) {
    return HistorySpotRow(
      id: data.id.present ? data.id.value : this.id,
      historyId: data.historyId.present ? data.historyId.value : this.historyId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isDestination:
          data.isDestination.present
              ? data.isDestination.value
              : this.isDestination,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
      streetViewImagePath:
          data.streetViewImagePath.present
              ? data.streetViewImagePath.value
              : this.streetViewImagePath,
      userPhotoPath:
          data.userPhotoPath.present
              ? data.userPhotoPath.value
              : this.userPhotoPath,
      achievedAt:
          data.achievedAt.present ? data.achievedAt.value : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HistorySpotRow(')
          ..write('id: $id, ')
          ..write('historyId: $historyId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDestination: $isDestination, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('streetViewImagePath: $streetViewImagePath, ')
          ..write('userPhotoPath: $userPhotoPath, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    historyId,
    sortOrder,
    isDestination,
    lat,
    lng,
    streetViewImagePath,
    userPhotoPath,
    achievedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HistorySpotRow &&
          other.id == this.id &&
          other.historyId == this.historyId &&
          other.sortOrder == this.sortOrder &&
          other.isDestination == this.isDestination &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.streetViewImagePath == this.streetViewImagePath &&
          other.userPhotoPath == this.userPhotoPath &&
          other.achievedAt == this.achievedAt);
}

class HistorySpotsCompanion extends UpdateCompanion<HistorySpotRow> {
  final Value<int> id;
  final Value<String> historyId;
  final Value<int> sortOrder;
  final Value<int> isDestination;
  final Value<double> lat;
  final Value<double> lng;
  final Value<String> streetViewImagePath;
  final Value<String?> userPhotoPath;
  final Value<int?> achievedAt;
  const HistorySpotsCompanion({
    this.id = const Value.absent(),
    this.historyId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isDestination = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.streetViewImagePath = const Value.absent(),
    this.userPhotoPath = const Value.absent(),
    this.achievedAt = const Value.absent(),
  });
  HistorySpotsCompanion.insert({
    this.id = const Value.absent(),
    required String historyId,
    required int sortOrder,
    required int isDestination,
    required double lat,
    required double lng,
    required String streetViewImagePath,
    this.userPhotoPath = const Value.absent(),
    this.achievedAt = const Value.absent(),
  }) : historyId = Value(historyId),
       sortOrder = Value(sortOrder),
       isDestination = Value(isDestination),
       lat = Value(lat),
       lng = Value(lng),
       streetViewImagePath = Value(streetViewImagePath);
  static Insertable<HistorySpotRow> custom({
    Expression<int>? id,
    Expression<String>? historyId,
    Expression<int>? sortOrder,
    Expression<int>? isDestination,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? streetViewImagePath,
    Expression<String>? userPhotoPath,
    Expression<int>? achievedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (historyId != null) 'history_id': historyId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isDestination != null) 'is_destination': isDestination,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (streetViewImagePath != null)
        'street_view_image_path': streetViewImagePath,
      if (userPhotoPath != null) 'user_photo_path': userPhotoPath,
      if (achievedAt != null) 'achieved_at': achievedAt,
    });
  }

  HistorySpotsCompanion copyWith({
    Value<int>? id,
    Value<String>? historyId,
    Value<int>? sortOrder,
    Value<int>? isDestination,
    Value<double>? lat,
    Value<double>? lng,
    Value<String>? streetViewImagePath,
    Value<String?>? userPhotoPath,
    Value<int?>? achievedAt,
  }) {
    return HistorySpotsCompanion(
      id: id ?? this.id,
      historyId: historyId ?? this.historyId,
      sortOrder: sortOrder ?? this.sortOrder,
      isDestination: isDestination ?? this.isDestination,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      streetViewImagePath: streetViewImagePath ?? this.streetViewImagePath,
      userPhotoPath: userPhotoPath ?? this.userPhotoPath,
      achievedAt: achievedAt ?? this.achievedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (historyId.present) {
      map['history_id'] = Variable<String>(historyId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isDestination.present) {
      map['is_destination'] = Variable<int>(isDestination.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (streetViewImagePath.present) {
      map['street_view_image_path'] = Variable<String>(
        streetViewImagePath.value,
      );
    }
    if (userPhotoPath.present) {
      map['user_photo_path'] = Variable<String>(userPhotoPath.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<int>(achievedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HistorySpotsCompanion(')
          ..write('id: $id, ')
          ..write('historyId: $historyId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isDestination: $isDestination, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('streetViewImagePath: $streetViewImagePath, ')
          ..write('userPhotoPath: $userPhotoPath, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$HistoryDatabase extends GeneratedDatabase {
  _$HistoryDatabase(QueryExecutor e) : super(e);
  $HistoryDatabaseManager get managers => $HistoryDatabaseManager(this);
  late final $MissionHistoriesTable missionHistories = $MissionHistoriesTable(
    this,
  );
  late final $HistorySpotsTable historySpots = $HistorySpotsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    missionHistories,
    historySpots,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'mission_histories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('history_spots', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MissionHistoriesTableCreateCompanionBuilder =
    MissionHistoriesCompanion Function({
      required String id,
      required int completedAt,
      required int startedAt,
      required double departureLat,
      required double departureLng,
      required String overviewPolyline,
      Value<int?> radiusMeters,
      Value<String> mode,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<int> rowid,
    });
typedef $$MissionHistoriesTableUpdateCompanionBuilder =
    MissionHistoriesCompanion Function({
      Value<String> id,
      Value<int> completedAt,
      Value<int> startedAt,
      Value<double> departureLat,
      Value<double> departureLng,
      Value<String> overviewPolyline,
      Value<int?> radiusMeters,
      Value<String> mode,
      Value<double?> destinationLat,
      Value<double?> destinationLng,
      Value<int> rowid,
    });

final class $$MissionHistoriesTableReferences
    extends
        BaseReferences<
          _$HistoryDatabase,
          $MissionHistoriesTable,
          MissionHistoryRow
        > {
  $$MissionHistoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$HistorySpotsTable, List<HistorySpotRow>>
  _historySpotsRefsTable(_$HistoryDatabase db) => MultiTypedResultKey.fromTable(
    db.historySpots,
    aliasName: $_aliasNameGenerator(
      db.missionHistories.id,
      db.historySpots.historyId,
    ),
  );

  $$HistorySpotsTableProcessedTableManager get historySpotsRefs {
    final manager = $$HistorySpotsTableTableManager(
      $_db,
      $_db.historySpots,
    ).filter((f) => f.historyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_historySpotsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MissionHistoriesTableFilterComposer
    extends Composer<_$HistoryDatabase, $MissionHistoriesTable> {
  $$MissionHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overviewPolyline => $composableBuilder(
    column: $table.overviewPolyline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> historySpotsRefs(
    Expression<bool> Function($$HistorySpotsTableFilterComposer f) f,
  ) {
    final $$HistorySpotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historySpots,
      getReferencedColumn: (t) => t.historyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorySpotsTableFilterComposer(
            $db: $db,
            $table: $db.historySpots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionHistoriesTableOrderingComposer
    extends Composer<_$HistoryDatabase, $MissionHistoriesTable> {
  $$MissionHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overviewPolyline => $composableBuilder(
    column: $table.overviewPolyline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionHistoriesTableAnnotationComposer
    extends Composer<_$HistoryDatabase, $MissionHistoriesTable> {
  $$MissionHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<double> get departureLat => $composableBuilder(
    column: $table.departureLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get departureLng => $composableBuilder(
    column: $table.departureLng,
    builder: (column) => column,
  );

  GeneratedColumn<String> get overviewPolyline => $composableBuilder(
    column: $table.overviewPolyline,
    builder: (column) => column,
  );

  GeneratedColumn<int> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<double> get destinationLat => $composableBuilder(
    column: $table.destinationLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get destinationLng => $composableBuilder(
    column: $table.destinationLng,
    builder: (column) => column,
  );

  Expression<T> historySpotsRefs<T extends Object>(
    Expression<T> Function($$HistorySpotsTableAnnotationComposer a) f,
  ) {
    final $$HistorySpotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.historySpots,
      getReferencedColumn: (t) => t.historyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HistorySpotsTableAnnotationComposer(
            $db: $db,
            $table: $db.historySpots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MissionHistoriesTableTableManager
    extends
        RootTableManager<
          _$HistoryDatabase,
          $MissionHistoriesTable,
          MissionHistoryRow,
          $$MissionHistoriesTableFilterComposer,
          $$MissionHistoriesTableOrderingComposer,
          $$MissionHistoriesTableAnnotationComposer,
          $$MissionHistoriesTableCreateCompanionBuilder,
          $$MissionHistoriesTableUpdateCompanionBuilder,
          (MissionHistoryRow, $$MissionHistoriesTableReferences),
          MissionHistoryRow,
          PrefetchHooks Function({bool historySpotsRefs})
        > {
  $$MissionHistoriesTableTableManager(
    _$HistoryDatabase db,
    $MissionHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () =>
                  $$MissionHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MissionHistoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer:
              () => $$MissionHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<double> departureLat = const Value.absent(),
                Value<double> departureLng = const Value.absent(),
                Value<String> overviewPolyline = const Value.absent(),
                Value<int?> radiusMeters = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionHistoriesCompanion(
                id: id,
                completedAt: completedAt,
                startedAt: startedAt,
                departureLat: departureLat,
                departureLng: departureLng,
                overviewPolyline: overviewPolyline,
                radiusMeters: radiusMeters,
                mode: mode,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int completedAt,
                required int startedAt,
                required double departureLat,
                required double departureLng,
                required String overviewPolyline,
                Value<int?> radiusMeters = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<double?> destinationLat = const Value.absent(),
                Value<double?> destinationLng = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionHistoriesCompanion.insert(
                id: id,
                completedAt: completedAt,
                startedAt: startedAt,
                departureLat: departureLat,
                departureLng: departureLng,
                overviewPolyline: overviewPolyline,
                radiusMeters: radiusMeters,
                mode: mode,
                destinationLat: destinationLat,
                destinationLng: destinationLng,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$MissionHistoriesTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({historySpotsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (historySpotsRefs) db.historySpots],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (historySpotsRefs)
                    await $_getPrefetchedData<
                      MissionHistoryRow,
                      $MissionHistoriesTable,
                      HistorySpotRow
                    >(
                      currentTable: table,
                      referencedTable: $$MissionHistoriesTableReferences
                          ._historySpotsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$MissionHistoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).historySpotsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.historyId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MissionHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$HistoryDatabase,
      $MissionHistoriesTable,
      MissionHistoryRow,
      $$MissionHistoriesTableFilterComposer,
      $$MissionHistoriesTableOrderingComposer,
      $$MissionHistoriesTableAnnotationComposer,
      $$MissionHistoriesTableCreateCompanionBuilder,
      $$MissionHistoriesTableUpdateCompanionBuilder,
      (MissionHistoryRow, $$MissionHistoriesTableReferences),
      MissionHistoryRow,
      PrefetchHooks Function({bool historySpotsRefs})
    >;
typedef $$HistorySpotsTableCreateCompanionBuilder =
    HistorySpotsCompanion Function({
      Value<int> id,
      required String historyId,
      required int sortOrder,
      required int isDestination,
      required double lat,
      required double lng,
      required String streetViewImagePath,
      Value<String?> userPhotoPath,
      Value<int?> achievedAt,
    });
typedef $$HistorySpotsTableUpdateCompanionBuilder =
    HistorySpotsCompanion Function({
      Value<int> id,
      Value<String> historyId,
      Value<int> sortOrder,
      Value<int> isDestination,
      Value<double> lat,
      Value<double> lng,
      Value<String> streetViewImagePath,
      Value<String?> userPhotoPath,
      Value<int?> achievedAt,
    });

final class $$HistorySpotsTableReferences
    extends
        BaseReferences<_$HistoryDatabase, $HistorySpotsTable, HistorySpotRow> {
  $$HistorySpotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MissionHistoriesTable _historyIdTable(_$HistoryDatabase db) =>
      db.missionHistories.createAlias(
        $_aliasNameGenerator(db.historySpots.historyId, db.missionHistories.id),
      );

  $$MissionHistoriesTableProcessedTableManager get historyId {
    final $_column = $_itemColumn<String>('history_id')!;

    final manager = $$MissionHistoriesTableTableManager(
      $_db,
      $_db.missionHistories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_historyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HistorySpotsTableFilterComposer
    extends Composer<_$HistoryDatabase, $HistorySpotsTable> {
  $$HistorySpotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streetViewImagePath => $composableBuilder(
    column: $table.streetViewImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userPhotoPath => $composableBuilder(
    column: $table.userPhotoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MissionHistoriesTableFilterComposer get historyId {
    final $$MissionHistoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyId,
      referencedTable: $db.missionHistories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionHistoriesTableFilterComposer(
            $db: $db,
            $table: $db.missionHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorySpotsTableOrderingComposer
    extends Composer<_$HistoryDatabase, $HistorySpotsTable> {
  $$HistorySpotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streetViewImagePath => $composableBuilder(
    column: $table.streetViewImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userPhotoPath => $composableBuilder(
    column: $table.userPhotoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MissionHistoriesTableOrderingComposer get historyId {
    final $$MissionHistoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyId,
      referencedTable: $db.missionHistories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionHistoriesTableOrderingComposer(
            $db: $db,
            $table: $db.missionHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorySpotsTableAnnotationComposer
    extends Composer<_$HistoryDatabase, $HistorySpotsTable> {
  $$HistorySpotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => column,
  );

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get streetViewImagePath => $composableBuilder(
    column: $table.streetViewImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userPhotoPath => $composableBuilder(
    column: $table.userPhotoPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$MissionHistoriesTableAnnotationComposer get historyId {
    final $$MissionHistoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.historyId,
      referencedTable: $db.missionHistories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MissionHistoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.missionHistories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HistorySpotsTableTableManager
    extends
        RootTableManager<
          _$HistoryDatabase,
          $HistorySpotsTable,
          HistorySpotRow,
          $$HistorySpotsTableFilterComposer,
          $$HistorySpotsTableOrderingComposer,
          $$HistorySpotsTableAnnotationComposer,
          $$HistorySpotsTableCreateCompanionBuilder,
          $$HistorySpotsTableUpdateCompanionBuilder,
          (HistorySpotRow, $$HistorySpotsTableReferences),
          HistorySpotRow,
          PrefetchHooks Function({bool historyId})
        > {
  $$HistorySpotsTableTableManager(
    _$HistoryDatabase db,
    $HistorySpotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$HistorySpotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$HistorySpotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () =>
                  $$HistorySpotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> historyId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> isDestination = const Value.absent(),
                Value<double> lat = const Value.absent(),
                Value<double> lng = const Value.absent(),
                Value<String> streetViewImagePath = const Value.absent(),
                Value<String?> userPhotoPath = const Value.absent(),
                Value<int?> achievedAt = const Value.absent(),
              }) => HistorySpotsCompanion(
                id: id,
                historyId: historyId,
                sortOrder: sortOrder,
                isDestination: isDestination,
                lat: lat,
                lng: lng,
                streetViewImagePath: streetViewImagePath,
                userPhotoPath: userPhotoPath,
                achievedAt: achievedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String historyId,
                required int sortOrder,
                required int isDestination,
                required double lat,
                required double lng,
                required String streetViewImagePath,
                Value<String?> userPhotoPath = const Value.absent(),
                Value<int?> achievedAt = const Value.absent(),
              }) => HistorySpotsCompanion.insert(
                id: id,
                historyId: historyId,
                sortOrder: sortOrder,
                isDestination: isDestination,
                lat: lat,
                lng: lng,
                streetViewImagePath: streetViewImagePath,
                userPhotoPath: userPhotoPath,
                achievedAt: achievedAt,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$HistorySpotsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({historyId = false}) {
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
                  dynamic
                >
              >(state) {
                if (historyId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.historyId,
                            referencedTable: $$HistorySpotsTableReferences
                                ._historyIdTable(db),
                            referencedColumn:
                                $$HistorySpotsTableReferences
                                    ._historyIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HistorySpotsTableProcessedTableManager =
    ProcessedTableManager<
      _$HistoryDatabase,
      $HistorySpotsTable,
      HistorySpotRow,
      $$HistorySpotsTableFilterComposer,
      $$HistorySpotsTableOrderingComposer,
      $$HistorySpotsTableAnnotationComposer,
      $$HistorySpotsTableCreateCompanionBuilder,
      $$HistorySpotsTableUpdateCompanionBuilder,
      (HistorySpotRow, $$HistorySpotsTableReferences),
      HistorySpotRow,
      PrefetchHooks Function({bool historyId})
    >;

class $HistoryDatabaseManager {
  final _$HistoryDatabase _db;
  $HistoryDatabaseManager(this._db);
  $$MissionHistoriesTableTableManager get missionHistories =>
      $$MissionHistoriesTableTableManager(_db, _db.missionHistories);
  $$HistorySpotsTableTableManager get historySpots =>
      $$HistorySpotsTableTableManager(_db, _db.historySpots);
}
