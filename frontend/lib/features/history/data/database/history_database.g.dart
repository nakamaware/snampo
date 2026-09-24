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
  static const VerificationMeta _roomCodeMeta = const VerificationMeta(
    'roomCode',
  );
  @override
  late final GeneratedColumn<String> roomCode = GeneratedColumn<String>(
    'room_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coopSyncStateMeta = const VerificationMeta(
    'coopSyncState',
  );
  @override
  late final GeneratedColumn<String> coopSyncState = GeneratedColumn<String>(
    'coop_sync_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coopIsHostMeta = const VerificationMeta(
    'coopIsHost',
  );
  @override
  late final GeneratedColumn<int> coopIsHost = GeneratedColumn<int>(
    'coop_is_host',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coopMembersMeta = const VerificationMeta(
    'coopMembers',
  );
  @override
  late final GeneratedColumn<String> coopMembers = GeneratedColumn<String>(
    'coop_members',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coopExpiresAtMeta = const VerificationMeta(
    'coopExpiresAt',
  );
  @override
  late final GeneratedColumn<int> coopExpiresAt = GeneratedColumn<int>(
    'coop_expires_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coopDeleteAtMeta = const VerificationMeta(
    'coopDeleteAt',
  );
  @override
  late final GeneratedColumn<int> coopDeleteAt = GeneratedColumn<int>(
    'coop_delete_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    roomCode,
    coopSyncState,
    coopIsHost,
    coopMembers,
    coopExpiresAt,
    coopDeleteAt,
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
    if (data.containsKey('room_code')) {
      context.handle(
        _roomCodeMeta,
        roomCode.isAcceptableOrUnknown(data['room_code']!, _roomCodeMeta),
      );
    }
    if (data.containsKey('coop_sync_state')) {
      context.handle(
        _coopSyncStateMeta,
        coopSyncState.isAcceptableOrUnknown(
          data['coop_sync_state']!,
          _coopSyncStateMeta,
        ),
      );
    }
    if (data.containsKey('coop_is_host')) {
      context.handle(
        _coopIsHostMeta,
        coopIsHost.isAcceptableOrUnknown(
          data['coop_is_host']!,
          _coopIsHostMeta,
        ),
      );
    }
    if (data.containsKey('coop_members')) {
      context.handle(
        _coopMembersMeta,
        coopMembers.isAcceptableOrUnknown(
          data['coop_members']!,
          _coopMembersMeta,
        ),
      );
    }
    if (data.containsKey('coop_expires_at')) {
      context.handle(
        _coopExpiresAtMeta,
        coopExpiresAt.isAcceptableOrUnknown(
          data['coop_expires_at']!,
          _coopExpiresAtMeta,
        ),
      );
    }
    if (data.containsKey('coop_delete_at')) {
      context.handle(
        _coopDeleteAtMeta,
        coopDeleteAt.isAcceptableOrUnknown(
          data['coop_delete_at']!,
          _coopDeleteAtMeta,
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
      roomCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_code'],
      ),
      coopSyncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coop_sync_state'],
      ),
      coopIsHost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coop_is_host'],
      ),
      coopMembers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coop_members'],
      ),
      coopExpiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coop_expires_at'],
      ),
      coopDeleteAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coop_delete_at'],
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

  /// ミッション開始モード: `random` / `destination` / `coop`
  ///
  /// `coop` のときのミッション設定は [radiusMeters] (random) か
  /// [destinationLat] / [destinationLng] (destination) から判定する。
  final String mode;

  /// ユーザーが指定した目的地の緯度 (ランダムモードでは null)
  final double? destinationLat;

  /// ユーザーが指定した目的地の経度 (ランダムモードでは null)
  final double? destinationLng;

  /// 協力プレイのルームコード (ソロでは null)。協力プレイの履歴はこれをキーに upsert する
  final String? roomCode;

  /// 協力プレイの同期の状態: `inProgress` (進行中) / `finalized` (確定)
  final String? coopSyncState;

  /// 自分がホストだったか (1 / 0)
  final int? coopIsHost;

  /// 協力プレイのメンバー一覧 (`[{"uid": ..., "nickname": ...}]` の JSON)
  final String? coopMembers;

  /// 協力プレイの遊べる期限 (Unix ms)
  final int? coopExpiresAt;

  /// 協力プレイのデータの保持期限 (Unix ms)
  final int? coopDeleteAt;
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
    this.roomCode,
    this.coopSyncState,
    this.coopIsHost,
    this.coopMembers,
    this.coopExpiresAt,
    this.coopDeleteAt,
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
    if (!nullToAbsent || roomCode != null) {
      map['room_code'] = Variable<String>(roomCode);
    }
    if (!nullToAbsent || coopSyncState != null) {
      map['coop_sync_state'] = Variable<String>(coopSyncState);
    }
    if (!nullToAbsent || coopIsHost != null) {
      map['coop_is_host'] = Variable<int>(coopIsHost);
    }
    if (!nullToAbsent || coopMembers != null) {
      map['coop_members'] = Variable<String>(coopMembers);
    }
    if (!nullToAbsent || coopExpiresAt != null) {
      map['coop_expires_at'] = Variable<int>(coopExpiresAt);
    }
    if (!nullToAbsent || coopDeleteAt != null) {
      map['coop_delete_at'] = Variable<int>(coopDeleteAt);
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
      roomCode:
          roomCode == null && nullToAbsent
              ? const Value.absent()
              : Value(roomCode),
      coopSyncState:
          coopSyncState == null && nullToAbsent
              ? const Value.absent()
              : Value(coopSyncState),
      coopIsHost:
          coopIsHost == null && nullToAbsent
              ? const Value.absent()
              : Value(coopIsHost),
      coopMembers:
          coopMembers == null && nullToAbsent
              ? const Value.absent()
              : Value(coopMembers),
      coopExpiresAt:
          coopExpiresAt == null && nullToAbsent
              ? const Value.absent()
              : Value(coopExpiresAt),
      coopDeleteAt:
          coopDeleteAt == null && nullToAbsent
              ? const Value.absent()
              : Value(coopDeleteAt),
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
      roomCode: serializer.fromJson<String?>(json['roomCode']),
      coopSyncState: serializer.fromJson<String?>(json['coopSyncState']),
      coopIsHost: serializer.fromJson<int?>(json['coopIsHost']),
      coopMembers: serializer.fromJson<String?>(json['coopMembers']),
      coopExpiresAt: serializer.fromJson<int?>(json['coopExpiresAt']),
      coopDeleteAt: serializer.fromJson<int?>(json['coopDeleteAt']),
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
      'roomCode': serializer.toJson<String?>(roomCode),
      'coopSyncState': serializer.toJson<String?>(coopSyncState),
      'coopIsHost': serializer.toJson<int?>(coopIsHost),
      'coopMembers': serializer.toJson<String?>(coopMembers),
      'coopExpiresAt': serializer.toJson<int?>(coopExpiresAt),
      'coopDeleteAt': serializer.toJson<int?>(coopDeleteAt),
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
    Value<String?> roomCode = const Value.absent(),
    Value<String?> coopSyncState = const Value.absent(),
    Value<int?> coopIsHost = const Value.absent(),
    Value<String?> coopMembers = const Value.absent(),
    Value<int?> coopExpiresAt = const Value.absent(),
    Value<int?> coopDeleteAt = const Value.absent(),
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
    roomCode: roomCode.present ? roomCode.value : this.roomCode,
    coopSyncState:
        coopSyncState.present ? coopSyncState.value : this.coopSyncState,
    coopIsHost: coopIsHost.present ? coopIsHost.value : this.coopIsHost,
    coopMembers: coopMembers.present ? coopMembers.value : this.coopMembers,
    coopExpiresAt:
        coopExpiresAt.present ? coopExpiresAt.value : this.coopExpiresAt,
    coopDeleteAt: coopDeleteAt.present ? coopDeleteAt.value : this.coopDeleteAt,
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
      roomCode: data.roomCode.present ? data.roomCode.value : this.roomCode,
      coopSyncState:
          data.coopSyncState.present
              ? data.coopSyncState.value
              : this.coopSyncState,
      coopIsHost:
          data.coopIsHost.present ? data.coopIsHost.value : this.coopIsHost,
      coopMembers:
          data.coopMembers.present ? data.coopMembers.value : this.coopMembers,
      coopExpiresAt:
          data.coopExpiresAt.present
              ? data.coopExpiresAt.value
              : this.coopExpiresAt,
      coopDeleteAt:
          data.coopDeleteAt.present
              ? data.coopDeleteAt.value
              : this.coopDeleteAt,
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
          ..write('destinationLng: $destinationLng, ')
          ..write('roomCode: $roomCode, ')
          ..write('coopSyncState: $coopSyncState, ')
          ..write('coopIsHost: $coopIsHost, ')
          ..write('coopMembers: $coopMembers, ')
          ..write('coopExpiresAt: $coopExpiresAt, ')
          ..write('coopDeleteAt: $coopDeleteAt')
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
    roomCode,
    coopSyncState,
    coopIsHost,
    coopMembers,
    coopExpiresAt,
    coopDeleteAt,
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
          other.destinationLng == this.destinationLng &&
          other.roomCode == this.roomCode &&
          other.coopSyncState == this.coopSyncState &&
          other.coopIsHost == this.coopIsHost &&
          other.coopMembers == this.coopMembers &&
          other.coopExpiresAt == this.coopExpiresAt &&
          other.coopDeleteAt == this.coopDeleteAt);
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
  final Value<String?> roomCode;
  final Value<String?> coopSyncState;
  final Value<int?> coopIsHost;
  final Value<String?> coopMembers;
  final Value<int?> coopExpiresAt;
  final Value<int?> coopDeleteAt;
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
    this.roomCode = const Value.absent(),
    this.coopSyncState = const Value.absent(),
    this.coopIsHost = const Value.absent(),
    this.coopMembers = const Value.absent(),
    this.coopExpiresAt = const Value.absent(),
    this.coopDeleteAt = const Value.absent(),
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
    this.roomCode = const Value.absent(),
    this.coopSyncState = const Value.absent(),
    this.coopIsHost = const Value.absent(),
    this.coopMembers = const Value.absent(),
    this.coopExpiresAt = const Value.absent(),
    this.coopDeleteAt = const Value.absent(),
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
    Expression<String>? roomCode,
    Expression<String>? coopSyncState,
    Expression<int>? coopIsHost,
    Expression<String>? coopMembers,
    Expression<int>? coopExpiresAt,
    Expression<int>? coopDeleteAt,
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
      if (roomCode != null) 'room_code': roomCode,
      if (coopSyncState != null) 'coop_sync_state': coopSyncState,
      if (coopIsHost != null) 'coop_is_host': coopIsHost,
      if (coopMembers != null) 'coop_members': coopMembers,
      if (coopExpiresAt != null) 'coop_expires_at': coopExpiresAt,
      if (coopDeleteAt != null) 'coop_delete_at': coopDeleteAt,
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
    Value<String?>? roomCode,
    Value<String?>? coopSyncState,
    Value<int?>? coopIsHost,
    Value<String?>? coopMembers,
    Value<int?>? coopExpiresAt,
    Value<int?>? coopDeleteAt,
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
      roomCode: roomCode ?? this.roomCode,
      coopSyncState: coopSyncState ?? this.coopSyncState,
      coopIsHost: coopIsHost ?? this.coopIsHost,
      coopMembers: coopMembers ?? this.coopMembers,
      coopExpiresAt: coopExpiresAt ?? this.coopExpiresAt,
      coopDeleteAt: coopDeleteAt ?? this.coopDeleteAt,
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
    if (roomCode.present) {
      map['room_code'] = Variable<String>(roomCode.value);
    }
    if (coopSyncState.present) {
      map['coop_sync_state'] = Variable<String>(coopSyncState.value);
    }
    if (coopIsHost.present) {
      map['coop_is_host'] = Variable<int>(coopIsHost.value);
    }
    if (coopMembers.present) {
      map['coop_members'] = Variable<String>(coopMembers.value);
    }
    if (coopExpiresAt.present) {
      map['coop_expires_at'] = Variable<int>(coopExpiresAt.value);
    }
    if (coopDeleteAt.present) {
      map['coop_delete_at'] = Variable<int>(coopDeleteAt.value);
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
          ..write('roomCode: $roomCode, ')
          ..write('coopSyncState: $coopSyncState, ')
          ..write('coopIsHost: $coopIsHost, ')
          ..write('coopMembers: $coopMembers, ')
          ..write('coopExpiresAt: $coopExpiresAt, ')
          ..write('coopDeleteAt: $coopDeleteAt, ')
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _googleMapsUrlMeta = const VerificationMeta(
    'googleMapsUrl',
  );
  @override
  late final GeneratedColumn<String> googleMapsUrl = GeneratedColumn<String>(
    'google_maps_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceHeadingMeta = const VerificationMeta(
    'referenceHeading',
  );
  @override
  late final GeneratedColumn<double> referenceHeading = GeneratedColumn<double>(
    'reference_heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _judgeRankMeta = const VerificationMeta(
    'judgeRank',
  );
  @override
  late final GeneratedColumn<String> judgeRank = GeneratedColumn<String>(
    'judge_rank',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceErrorMetersMeta =
      const VerificationMeta('distanceErrorMeters');
  @override
  late final GeneratedColumn<double> distanceErrorMeters =
      GeneratedColumn<double>(
        'distance_error_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _headingErrorDegreesMeta =
      const VerificationMeta('headingErrorDegrees');
  @override
  late final GeneratedColumn<double> headingErrorDegrees =
      GeneratedColumn<double>(
        'heading_error_degrees',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _guessLatMeta = const VerificationMeta(
    'guessLat',
  );
  @override
  late final GeneratedColumn<double> guessLat = GeneratedColumn<double>(
    'guess_lat',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guessLngMeta = const VerificationMeta(
    'guessLng',
  );
  @override
  late final GeneratedColumn<double> guessLng = GeneratedColumn<double>(
    'guess_lng',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _capturedHeadingMeta = const VerificationMeta(
    'capturedHeading',
  );
  @override
  late final GeneratedColumn<double> capturedHeading = GeneratedColumn<double>(
    'captured_heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _spotIdMeta = const VerificationMeta('spotId');
  @override
  late final GeneratedColumn<String> spotId = GeneratedColumn<String>(
    'spot_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discovererUidMeta = const VerificationMeta(
    'discovererUid',
  );
  @override
  late final GeneratedColumn<String> discovererUid = GeneratedColumn<String>(
    'discoverer_uid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _discovererNicknameMeta =
      const VerificationMeta('discovererNickname');
  @override
  late final GeneratedColumn<String> discovererNickname =
      GeneratedColumn<String>(
        'discoverer_nickname',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererThumbPathMeta =
      const VerificationMeta('discovererThumbPath');
  @override
  late final GeneratedColumn<String> discovererThumbPath =
      GeneratedColumn<String>(
        'discoverer_thumb_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererJudgeRankMeta =
      const VerificationMeta('discovererJudgeRank');
  @override
  late final GeneratedColumn<String> discovererJudgeRank =
      GeneratedColumn<String>(
        'discoverer_judge_rank',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererDistanceErrorMetersMeta =
      const VerificationMeta('discovererDistanceErrorMeters');
  @override
  late final GeneratedColumn<double> discovererDistanceErrorMeters =
      GeneratedColumn<double>(
        'discoverer_distance_error_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererHeadingErrorDegreesMeta =
      const VerificationMeta('discovererHeadingErrorDegrees');
  @override
  late final GeneratedColumn<double> discovererHeadingErrorDegrees =
      GeneratedColumn<double>(
        'discoverer_heading_error_degrees',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererGuessLatMeta =
      const VerificationMeta('discovererGuessLat');
  @override
  late final GeneratedColumn<double> discovererGuessLat =
      GeneratedColumn<double>(
        'discoverer_guess_lat',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererGuessLngMeta =
      const VerificationMeta('discovererGuessLng');
  @override
  late final GeneratedColumn<double> discovererGuessLng =
      GeneratedColumn<double>(
        'discoverer_guess_lng',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _discovererCapturedHeadingMeta =
      const VerificationMeta('discovererCapturedHeading');
  @override
  late final GeneratedColumn<double> discovererCapturedHeading =
      GeneratedColumn<double>(
        'discoverer_captured_heading',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isClearedMeta = const VerificationMeta(
    'isCleared',
  );
  @override
  late final GeneratedColumn<int> isCleared = GeneratedColumn<int>(
    'is_cleared',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    name,
    genre,
    googleMapsUrl,
    referenceHeading,
    judgeRank,
    distanceErrorMeters,
    headingErrorDegrees,
    guessLat,
    guessLng,
    capturedHeading,
    spotId,
    discovererUid,
    discovererNickname,
    discovererThumbPath,
    discovererJudgeRank,
    discovererDistanceErrorMeters,
    discovererHeadingErrorDegrees,
    discovererGuessLat,
    discovererGuessLng,
    discovererCapturedHeading,
    isCleared,
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
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('google_maps_url')) {
      context.handle(
        _googleMapsUrlMeta,
        googleMapsUrl.isAcceptableOrUnknown(
          data['google_maps_url']!,
          _googleMapsUrlMeta,
        ),
      );
    }
    if (data.containsKey('reference_heading')) {
      context.handle(
        _referenceHeadingMeta,
        referenceHeading.isAcceptableOrUnknown(
          data['reference_heading']!,
          _referenceHeadingMeta,
        ),
      );
    }
    if (data.containsKey('judge_rank')) {
      context.handle(
        _judgeRankMeta,
        judgeRank.isAcceptableOrUnknown(data['judge_rank']!, _judgeRankMeta),
      );
    }
    if (data.containsKey('distance_error_meters')) {
      context.handle(
        _distanceErrorMetersMeta,
        distanceErrorMeters.isAcceptableOrUnknown(
          data['distance_error_meters']!,
          _distanceErrorMetersMeta,
        ),
      );
    }
    if (data.containsKey('heading_error_degrees')) {
      context.handle(
        _headingErrorDegreesMeta,
        headingErrorDegrees.isAcceptableOrUnknown(
          data['heading_error_degrees']!,
          _headingErrorDegreesMeta,
        ),
      );
    }
    if (data.containsKey('guess_lat')) {
      context.handle(
        _guessLatMeta,
        guessLat.isAcceptableOrUnknown(data['guess_lat']!, _guessLatMeta),
      );
    }
    if (data.containsKey('guess_lng')) {
      context.handle(
        _guessLngMeta,
        guessLng.isAcceptableOrUnknown(data['guess_lng']!, _guessLngMeta),
      );
    }
    if (data.containsKey('captured_heading')) {
      context.handle(
        _capturedHeadingMeta,
        capturedHeading.isAcceptableOrUnknown(
          data['captured_heading']!,
          _capturedHeadingMeta,
        ),
      );
    }
    if (data.containsKey('spot_id')) {
      context.handle(
        _spotIdMeta,
        spotId.isAcceptableOrUnknown(data['spot_id']!, _spotIdMeta),
      );
    }
    if (data.containsKey('discoverer_uid')) {
      context.handle(
        _discovererUidMeta,
        discovererUid.isAcceptableOrUnknown(
          data['discoverer_uid']!,
          _discovererUidMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_nickname')) {
      context.handle(
        _discovererNicknameMeta,
        discovererNickname.isAcceptableOrUnknown(
          data['discoverer_nickname']!,
          _discovererNicknameMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_thumb_path')) {
      context.handle(
        _discovererThumbPathMeta,
        discovererThumbPath.isAcceptableOrUnknown(
          data['discoverer_thumb_path']!,
          _discovererThumbPathMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_judge_rank')) {
      context.handle(
        _discovererJudgeRankMeta,
        discovererJudgeRank.isAcceptableOrUnknown(
          data['discoverer_judge_rank']!,
          _discovererJudgeRankMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_distance_error_meters')) {
      context.handle(
        _discovererDistanceErrorMetersMeta,
        discovererDistanceErrorMeters.isAcceptableOrUnknown(
          data['discoverer_distance_error_meters']!,
          _discovererDistanceErrorMetersMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_heading_error_degrees')) {
      context.handle(
        _discovererHeadingErrorDegreesMeta,
        discovererHeadingErrorDegrees.isAcceptableOrUnknown(
          data['discoverer_heading_error_degrees']!,
          _discovererHeadingErrorDegreesMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_guess_lat')) {
      context.handle(
        _discovererGuessLatMeta,
        discovererGuessLat.isAcceptableOrUnknown(
          data['discoverer_guess_lat']!,
          _discovererGuessLatMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_guess_lng')) {
      context.handle(
        _discovererGuessLngMeta,
        discovererGuessLng.isAcceptableOrUnknown(
          data['discoverer_guess_lng']!,
          _discovererGuessLngMeta,
        ),
      );
    }
    if (data.containsKey('discoverer_captured_heading')) {
      context.handle(
        _discovererCapturedHeadingMeta,
        discovererCapturedHeading.isAcceptableOrUnknown(
          data['discoverer_captured_heading']!,
          _discovererCapturedHeadingMeta,
        ),
      );
    }
    if (data.containsKey('is_cleared')) {
      context.handle(
        _isClearedMeta,
        isCleared.isAcceptableOrUnknown(data['is_cleared']!, _isClearedMeta),
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
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      googleMapsUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}google_maps_url'],
      ),
      referenceHeading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reference_heading'],
      ),
      judgeRank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}judge_rank'],
      ),
      distanceErrorMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_error_meters'],
      ),
      headingErrorDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading_error_degrees'],
      ),
      guessLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}guess_lat'],
      ),
      guessLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}guess_lng'],
      ),
      capturedHeading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}captured_heading'],
      ),
      spotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spot_id'],
      ),
      discovererUid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discoverer_uid'],
      ),
      discovererNickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discoverer_nickname'],
      ),
      discovererThumbPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discoverer_thumb_path'],
      ),
      discovererJudgeRank: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}discoverer_judge_rank'],
      ),
      discovererDistanceErrorMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discoverer_distance_error_meters'],
      ),
      discovererHeadingErrorDegrees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discoverer_heading_error_degrees'],
      ),
      discovererGuessLat: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discoverer_guess_lat'],
      ),
      discovererGuessLng: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discoverer_guess_lng'],
      ),
      discovererCapturedHeading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discoverer_captured_heading'],
      ),
      isCleared:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}is_cleared'],
          )!,
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

  /// スポット名称 (Places API)
  final String? name;

  /// ジャンル識別子 (Places primaryType)
  final String? genre;

  /// Google Maps の詳細 URL
  final String? googleMapsUrl;

  /// 正解画像の基準方角 (度)
  final double? referenceHeading;

  /// 採点ランク (`excellent` / `good` / `fair` / `miss`)
  ///
  /// 旧バージョンで保存された `retry` は読み込み時に `miss` として扱う。
  final String? judgeRank;

  /// 位置誤差 (m)
  final double? distanceErrorMeters;

  /// 方角誤差 (度)
  final double? headingErrorDegrees;

  /// 撮影時の推定緯度
  final double? guessLat;

  /// 撮影時の推定経度
  final double? guessLng;

  /// 撮影時の方角 (度)
  final double? capturedHeading;

  /// スポット ID (place_id / geo URI)。旧データでは null
  final String? spotId;

  /// 協力プレイの発見者の uid
  final String? discovererUid;

  /// 協力プレイの発見者のニックネーム (発見時点)
  final String? discovererNickname;

  /// 協力プレイの発見者のサムネのパス
  final String? discovererThumbPath;

  /// 協力プレイの発見者の採点ランク (`excellent` / `good` / `fair` / `miss`)
  final String? discovererJudgeRank;

  /// 協力プレイの発見者の位置誤差 (m)
  final double? discovererDistanceErrorMeters;

  /// 協力プレイの発見者の方角誤差 (度)
  final double? discovererHeadingErrorDegrees;

  /// 協力プレイの発見者が撮影した緯度
  final double? discovererGuessLat;

  /// 協力プレイの発見者が撮影した経度
  final double? discovererGuessLng;

  /// 協力プレイの発見者が撮影したときの方角 (度)
  final double? discovererCapturedHeading;

  /// クリア済みなら 1 (協力プレイの途中終了では未クリアのスポットがある)
  final int isCleared;
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
    this.name,
    this.genre,
    this.googleMapsUrl,
    this.referenceHeading,
    this.judgeRank,
    this.distanceErrorMeters,
    this.headingErrorDegrees,
    this.guessLat,
    this.guessLng,
    this.capturedHeading,
    this.spotId,
    this.discovererUid,
    this.discovererNickname,
    this.discovererThumbPath,
    this.discovererJudgeRank,
    this.discovererDistanceErrorMeters,
    this.discovererHeadingErrorDegrees,
    this.discovererGuessLat,
    this.discovererGuessLng,
    this.discovererCapturedHeading,
    required this.isCleared,
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
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || googleMapsUrl != null) {
      map['google_maps_url'] = Variable<String>(googleMapsUrl);
    }
    if (!nullToAbsent || referenceHeading != null) {
      map['reference_heading'] = Variable<double>(referenceHeading);
    }
    if (!nullToAbsent || judgeRank != null) {
      map['judge_rank'] = Variable<String>(judgeRank);
    }
    if (!nullToAbsent || distanceErrorMeters != null) {
      map['distance_error_meters'] = Variable<double>(distanceErrorMeters);
    }
    if (!nullToAbsent || headingErrorDegrees != null) {
      map['heading_error_degrees'] = Variable<double>(headingErrorDegrees);
    }
    if (!nullToAbsent || guessLat != null) {
      map['guess_lat'] = Variable<double>(guessLat);
    }
    if (!nullToAbsent || guessLng != null) {
      map['guess_lng'] = Variable<double>(guessLng);
    }
    if (!nullToAbsent || capturedHeading != null) {
      map['captured_heading'] = Variable<double>(capturedHeading);
    }
    if (!nullToAbsent || spotId != null) {
      map['spot_id'] = Variable<String>(spotId);
    }
    if (!nullToAbsent || discovererUid != null) {
      map['discoverer_uid'] = Variable<String>(discovererUid);
    }
    if (!nullToAbsent || discovererNickname != null) {
      map['discoverer_nickname'] = Variable<String>(discovererNickname);
    }
    if (!nullToAbsent || discovererThumbPath != null) {
      map['discoverer_thumb_path'] = Variable<String>(discovererThumbPath);
    }
    if (!nullToAbsent || discovererJudgeRank != null) {
      map['discoverer_judge_rank'] = Variable<String>(discovererJudgeRank);
    }
    if (!nullToAbsent || discovererDistanceErrorMeters != null) {
      map['discoverer_distance_error_meters'] = Variable<double>(
        discovererDistanceErrorMeters,
      );
    }
    if (!nullToAbsent || discovererHeadingErrorDegrees != null) {
      map['discoverer_heading_error_degrees'] = Variable<double>(
        discovererHeadingErrorDegrees,
      );
    }
    if (!nullToAbsent || discovererGuessLat != null) {
      map['discoverer_guess_lat'] = Variable<double>(discovererGuessLat);
    }
    if (!nullToAbsent || discovererGuessLng != null) {
      map['discoverer_guess_lng'] = Variable<double>(discovererGuessLng);
    }
    if (!nullToAbsent || discovererCapturedHeading != null) {
      map['discoverer_captured_heading'] = Variable<double>(
        discovererCapturedHeading,
      );
    }
    map['is_cleared'] = Variable<int>(isCleared);
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
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      genre:
          genre == null && nullToAbsent ? const Value.absent() : Value(genre),
      googleMapsUrl:
          googleMapsUrl == null && nullToAbsent
              ? const Value.absent()
              : Value(googleMapsUrl),
      referenceHeading:
          referenceHeading == null && nullToAbsent
              ? const Value.absent()
              : Value(referenceHeading),
      judgeRank:
          judgeRank == null && nullToAbsent
              ? const Value.absent()
              : Value(judgeRank),
      distanceErrorMeters:
          distanceErrorMeters == null && nullToAbsent
              ? const Value.absent()
              : Value(distanceErrorMeters),
      headingErrorDegrees:
          headingErrorDegrees == null && nullToAbsent
              ? const Value.absent()
              : Value(headingErrorDegrees),
      guessLat:
          guessLat == null && nullToAbsent
              ? const Value.absent()
              : Value(guessLat),
      guessLng:
          guessLng == null && nullToAbsent
              ? const Value.absent()
              : Value(guessLng),
      capturedHeading:
          capturedHeading == null && nullToAbsent
              ? const Value.absent()
              : Value(capturedHeading),
      spotId:
          spotId == null && nullToAbsent ? const Value.absent() : Value(spotId),
      discovererUid:
          discovererUid == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererUid),
      discovererNickname:
          discovererNickname == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererNickname),
      discovererThumbPath:
          discovererThumbPath == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererThumbPath),
      discovererJudgeRank:
          discovererJudgeRank == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererJudgeRank),
      discovererDistanceErrorMeters:
          discovererDistanceErrorMeters == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererDistanceErrorMeters),
      discovererHeadingErrorDegrees:
          discovererHeadingErrorDegrees == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererHeadingErrorDegrees),
      discovererGuessLat:
          discovererGuessLat == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererGuessLat),
      discovererGuessLng:
          discovererGuessLng == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererGuessLng),
      discovererCapturedHeading:
          discovererCapturedHeading == null && nullToAbsent
              ? const Value.absent()
              : Value(discovererCapturedHeading),
      isCleared: Value(isCleared),
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
      name: serializer.fromJson<String?>(json['name']),
      genre: serializer.fromJson<String?>(json['genre']),
      googleMapsUrl: serializer.fromJson<String?>(json['googleMapsUrl']),
      referenceHeading: serializer.fromJson<double?>(json['referenceHeading']),
      judgeRank: serializer.fromJson<String?>(json['judgeRank']),
      distanceErrorMeters: serializer.fromJson<double?>(
        json['distanceErrorMeters'],
      ),
      headingErrorDegrees: serializer.fromJson<double?>(
        json['headingErrorDegrees'],
      ),
      guessLat: serializer.fromJson<double?>(json['guessLat']),
      guessLng: serializer.fromJson<double?>(json['guessLng']),
      capturedHeading: serializer.fromJson<double?>(json['capturedHeading']),
      spotId: serializer.fromJson<String?>(json['spotId']),
      discovererUid: serializer.fromJson<String?>(json['discovererUid']),
      discovererNickname: serializer.fromJson<String?>(
        json['discovererNickname'],
      ),
      discovererThumbPath: serializer.fromJson<String?>(
        json['discovererThumbPath'],
      ),
      discovererJudgeRank: serializer.fromJson<String?>(
        json['discovererJudgeRank'],
      ),
      discovererDistanceErrorMeters: serializer.fromJson<double?>(
        json['discovererDistanceErrorMeters'],
      ),
      discovererHeadingErrorDegrees: serializer.fromJson<double?>(
        json['discovererHeadingErrorDegrees'],
      ),
      discovererGuessLat: serializer.fromJson<double?>(
        json['discovererGuessLat'],
      ),
      discovererGuessLng: serializer.fromJson<double?>(
        json['discovererGuessLng'],
      ),
      discovererCapturedHeading: serializer.fromJson<double?>(
        json['discovererCapturedHeading'],
      ),
      isCleared: serializer.fromJson<int>(json['isCleared']),
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
      'name': serializer.toJson<String?>(name),
      'genre': serializer.toJson<String?>(genre),
      'googleMapsUrl': serializer.toJson<String?>(googleMapsUrl),
      'referenceHeading': serializer.toJson<double?>(referenceHeading),
      'judgeRank': serializer.toJson<String?>(judgeRank),
      'distanceErrorMeters': serializer.toJson<double?>(distanceErrorMeters),
      'headingErrorDegrees': serializer.toJson<double?>(headingErrorDegrees),
      'guessLat': serializer.toJson<double?>(guessLat),
      'guessLng': serializer.toJson<double?>(guessLng),
      'capturedHeading': serializer.toJson<double?>(capturedHeading),
      'spotId': serializer.toJson<String?>(spotId),
      'discovererUid': serializer.toJson<String?>(discovererUid),
      'discovererNickname': serializer.toJson<String?>(discovererNickname),
      'discovererThumbPath': serializer.toJson<String?>(discovererThumbPath),
      'discovererJudgeRank': serializer.toJson<String?>(discovererJudgeRank),
      'discovererDistanceErrorMeters': serializer.toJson<double?>(
        discovererDistanceErrorMeters,
      ),
      'discovererHeadingErrorDegrees': serializer.toJson<double?>(
        discovererHeadingErrorDegrees,
      ),
      'discovererGuessLat': serializer.toJson<double?>(discovererGuessLat),
      'discovererGuessLng': serializer.toJson<double?>(discovererGuessLng),
      'discovererCapturedHeading': serializer.toJson<double?>(
        discovererCapturedHeading,
      ),
      'isCleared': serializer.toJson<int>(isCleared),
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
    Value<String?> name = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> googleMapsUrl = const Value.absent(),
    Value<double?> referenceHeading = const Value.absent(),
    Value<String?> judgeRank = const Value.absent(),
    Value<double?> distanceErrorMeters = const Value.absent(),
    Value<double?> headingErrorDegrees = const Value.absent(),
    Value<double?> guessLat = const Value.absent(),
    Value<double?> guessLng = const Value.absent(),
    Value<double?> capturedHeading = const Value.absent(),
    Value<String?> spotId = const Value.absent(),
    Value<String?> discovererUid = const Value.absent(),
    Value<String?> discovererNickname = const Value.absent(),
    Value<String?> discovererThumbPath = const Value.absent(),
    Value<String?> discovererJudgeRank = const Value.absent(),
    Value<double?> discovererDistanceErrorMeters = const Value.absent(),
    Value<double?> discovererHeadingErrorDegrees = const Value.absent(),
    Value<double?> discovererGuessLat = const Value.absent(),
    Value<double?> discovererGuessLng = const Value.absent(),
    Value<double?> discovererCapturedHeading = const Value.absent(),
    int? isCleared,
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
    name: name.present ? name.value : this.name,
    genre: genre.present ? genre.value : this.genre,
    googleMapsUrl:
        googleMapsUrl.present ? googleMapsUrl.value : this.googleMapsUrl,
    referenceHeading:
        referenceHeading.present
            ? referenceHeading.value
            : this.referenceHeading,
    judgeRank: judgeRank.present ? judgeRank.value : this.judgeRank,
    distanceErrorMeters:
        distanceErrorMeters.present
            ? distanceErrorMeters.value
            : this.distanceErrorMeters,
    headingErrorDegrees:
        headingErrorDegrees.present
            ? headingErrorDegrees.value
            : this.headingErrorDegrees,
    guessLat: guessLat.present ? guessLat.value : this.guessLat,
    guessLng: guessLng.present ? guessLng.value : this.guessLng,
    capturedHeading:
        capturedHeading.present ? capturedHeading.value : this.capturedHeading,
    spotId: spotId.present ? spotId.value : this.spotId,
    discovererUid:
        discovererUid.present ? discovererUid.value : this.discovererUid,
    discovererNickname:
        discovererNickname.present
            ? discovererNickname.value
            : this.discovererNickname,
    discovererThumbPath:
        discovererThumbPath.present
            ? discovererThumbPath.value
            : this.discovererThumbPath,
    discovererJudgeRank:
        discovererJudgeRank.present
            ? discovererJudgeRank.value
            : this.discovererJudgeRank,
    discovererDistanceErrorMeters:
        discovererDistanceErrorMeters.present
            ? discovererDistanceErrorMeters.value
            : this.discovererDistanceErrorMeters,
    discovererHeadingErrorDegrees:
        discovererHeadingErrorDegrees.present
            ? discovererHeadingErrorDegrees.value
            : this.discovererHeadingErrorDegrees,
    discovererGuessLat:
        discovererGuessLat.present
            ? discovererGuessLat.value
            : this.discovererGuessLat,
    discovererGuessLng:
        discovererGuessLng.present
            ? discovererGuessLng.value
            : this.discovererGuessLng,
    discovererCapturedHeading:
        discovererCapturedHeading.present
            ? discovererCapturedHeading.value
            : this.discovererCapturedHeading,
    isCleared: isCleared ?? this.isCleared,
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
      name: data.name.present ? data.name.value : this.name,
      genre: data.genre.present ? data.genre.value : this.genre,
      googleMapsUrl:
          data.googleMapsUrl.present
              ? data.googleMapsUrl.value
              : this.googleMapsUrl,
      referenceHeading:
          data.referenceHeading.present
              ? data.referenceHeading.value
              : this.referenceHeading,
      judgeRank: data.judgeRank.present ? data.judgeRank.value : this.judgeRank,
      distanceErrorMeters:
          data.distanceErrorMeters.present
              ? data.distanceErrorMeters.value
              : this.distanceErrorMeters,
      headingErrorDegrees:
          data.headingErrorDegrees.present
              ? data.headingErrorDegrees.value
              : this.headingErrorDegrees,
      guessLat: data.guessLat.present ? data.guessLat.value : this.guessLat,
      guessLng: data.guessLng.present ? data.guessLng.value : this.guessLng,
      capturedHeading:
          data.capturedHeading.present
              ? data.capturedHeading.value
              : this.capturedHeading,
      spotId: data.spotId.present ? data.spotId.value : this.spotId,
      discovererUid:
          data.discovererUid.present
              ? data.discovererUid.value
              : this.discovererUid,
      discovererNickname:
          data.discovererNickname.present
              ? data.discovererNickname.value
              : this.discovererNickname,
      discovererThumbPath:
          data.discovererThumbPath.present
              ? data.discovererThumbPath.value
              : this.discovererThumbPath,
      discovererJudgeRank:
          data.discovererJudgeRank.present
              ? data.discovererJudgeRank.value
              : this.discovererJudgeRank,
      discovererDistanceErrorMeters:
          data.discovererDistanceErrorMeters.present
              ? data.discovererDistanceErrorMeters.value
              : this.discovererDistanceErrorMeters,
      discovererHeadingErrorDegrees:
          data.discovererHeadingErrorDegrees.present
              ? data.discovererHeadingErrorDegrees.value
              : this.discovererHeadingErrorDegrees,
      discovererGuessLat:
          data.discovererGuessLat.present
              ? data.discovererGuessLat.value
              : this.discovererGuessLat,
      discovererGuessLng:
          data.discovererGuessLng.present
              ? data.discovererGuessLng.value
              : this.discovererGuessLng,
      discovererCapturedHeading:
          data.discovererCapturedHeading.present
              ? data.discovererCapturedHeading.value
              : this.discovererCapturedHeading,
      isCleared: data.isCleared.present ? data.isCleared.value : this.isCleared,
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
          ..write('achievedAt: $achievedAt, ')
          ..write('name: $name, ')
          ..write('genre: $genre, ')
          ..write('googleMapsUrl: $googleMapsUrl, ')
          ..write('referenceHeading: $referenceHeading, ')
          ..write('judgeRank: $judgeRank, ')
          ..write('distanceErrorMeters: $distanceErrorMeters, ')
          ..write('headingErrorDegrees: $headingErrorDegrees, ')
          ..write('guessLat: $guessLat, ')
          ..write('guessLng: $guessLng, ')
          ..write('capturedHeading: $capturedHeading, ')
          ..write('spotId: $spotId, ')
          ..write('discovererUid: $discovererUid, ')
          ..write('discovererNickname: $discovererNickname, ')
          ..write('discovererThumbPath: $discovererThumbPath, ')
          ..write('discovererJudgeRank: $discovererJudgeRank, ')
          ..write(
            'discovererDistanceErrorMeters: $discovererDistanceErrorMeters, ',
          )
          ..write(
            'discovererHeadingErrorDegrees: $discovererHeadingErrorDegrees, ',
          )
          ..write('discovererGuessLat: $discovererGuessLat, ')
          ..write('discovererGuessLng: $discovererGuessLng, ')
          ..write('discovererCapturedHeading: $discovererCapturedHeading, ')
          ..write('isCleared: $isCleared')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    historyId,
    sortOrder,
    isDestination,
    lat,
    lng,
    streetViewImagePath,
    userPhotoPath,
    achievedAt,
    name,
    genre,
    googleMapsUrl,
    referenceHeading,
    judgeRank,
    distanceErrorMeters,
    headingErrorDegrees,
    guessLat,
    guessLng,
    capturedHeading,
    spotId,
    discovererUid,
    discovererNickname,
    discovererThumbPath,
    discovererJudgeRank,
    discovererDistanceErrorMeters,
    discovererHeadingErrorDegrees,
    discovererGuessLat,
    discovererGuessLng,
    discovererCapturedHeading,
    isCleared,
  ]);
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
          other.achievedAt == this.achievedAt &&
          other.name == this.name &&
          other.genre == this.genre &&
          other.googleMapsUrl == this.googleMapsUrl &&
          other.referenceHeading == this.referenceHeading &&
          other.judgeRank == this.judgeRank &&
          other.distanceErrorMeters == this.distanceErrorMeters &&
          other.headingErrorDegrees == this.headingErrorDegrees &&
          other.guessLat == this.guessLat &&
          other.guessLng == this.guessLng &&
          other.capturedHeading == this.capturedHeading &&
          other.spotId == this.spotId &&
          other.discovererUid == this.discovererUid &&
          other.discovererNickname == this.discovererNickname &&
          other.discovererThumbPath == this.discovererThumbPath &&
          other.discovererJudgeRank == this.discovererJudgeRank &&
          other.discovererDistanceErrorMeters ==
              this.discovererDistanceErrorMeters &&
          other.discovererHeadingErrorDegrees ==
              this.discovererHeadingErrorDegrees &&
          other.discovererGuessLat == this.discovererGuessLat &&
          other.discovererGuessLng == this.discovererGuessLng &&
          other.discovererCapturedHeading == this.discovererCapturedHeading &&
          other.isCleared == this.isCleared);
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
  final Value<String?> name;
  final Value<String?> genre;
  final Value<String?> googleMapsUrl;
  final Value<double?> referenceHeading;
  final Value<String?> judgeRank;
  final Value<double?> distanceErrorMeters;
  final Value<double?> headingErrorDegrees;
  final Value<double?> guessLat;
  final Value<double?> guessLng;
  final Value<double?> capturedHeading;
  final Value<String?> spotId;
  final Value<String?> discovererUid;
  final Value<String?> discovererNickname;
  final Value<String?> discovererThumbPath;
  final Value<String?> discovererJudgeRank;
  final Value<double?> discovererDistanceErrorMeters;
  final Value<double?> discovererHeadingErrorDegrees;
  final Value<double?> discovererGuessLat;
  final Value<double?> discovererGuessLng;
  final Value<double?> discovererCapturedHeading;
  final Value<int> isCleared;
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
    this.name = const Value.absent(),
    this.genre = const Value.absent(),
    this.googleMapsUrl = const Value.absent(),
    this.referenceHeading = const Value.absent(),
    this.judgeRank = const Value.absent(),
    this.distanceErrorMeters = const Value.absent(),
    this.headingErrorDegrees = const Value.absent(),
    this.guessLat = const Value.absent(),
    this.guessLng = const Value.absent(),
    this.capturedHeading = const Value.absent(),
    this.spotId = const Value.absent(),
    this.discovererUid = const Value.absent(),
    this.discovererNickname = const Value.absent(),
    this.discovererThumbPath = const Value.absent(),
    this.discovererJudgeRank = const Value.absent(),
    this.discovererDistanceErrorMeters = const Value.absent(),
    this.discovererHeadingErrorDegrees = const Value.absent(),
    this.discovererGuessLat = const Value.absent(),
    this.discovererGuessLng = const Value.absent(),
    this.discovererCapturedHeading = const Value.absent(),
    this.isCleared = const Value.absent(),
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
    this.name = const Value.absent(),
    this.genre = const Value.absent(),
    this.googleMapsUrl = const Value.absent(),
    this.referenceHeading = const Value.absent(),
    this.judgeRank = const Value.absent(),
    this.distanceErrorMeters = const Value.absent(),
    this.headingErrorDegrees = const Value.absent(),
    this.guessLat = const Value.absent(),
    this.guessLng = const Value.absent(),
    this.capturedHeading = const Value.absent(),
    this.spotId = const Value.absent(),
    this.discovererUid = const Value.absent(),
    this.discovererNickname = const Value.absent(),
    this.discovererThumbPath = const Value.absent(),
    this.discovererJudgeRank = const Value.absent(),
    this.discovererDistanceErrorMeters = const Value.absent(),
    this.discovererHeadingErrorDegrees = const Value.absent(),
    this.discovererGuessLat = const Value.absent(),
    this.discovererGuessLng = const Value.absent(),
    this.discovererCapturedHeading = const Value.absent(),
    this.isCleared = const Value.absent(),
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
    Expression<String>? name,
    Expression<String>? genre,
    Expression<String>? googleMapsUrl,
    Expression<double>? referenceHeading,
    Expression<String>? judgeRank,
    Expression<double>? distanceErrorMeters,
    Expression<double>? headingErrorDegrees,
    Expression<double>? guessLat,
    Expression<double>? guessLng,
    Expression<double>? capturedHeading,
    Expression<String>? spotId,
    Expression<String>? discovererUid,
    Expression<String>? discovererNickname,
    Expression<String>? discovererThumbPath,
    Expression<String>? discovererJudgeRank,
    Expression<double>? discovererDistanceErrorMeters,
    Expression<double>? discovererHeadingErrorDegrees,
    Expression<double>? discovererGuessLat,
    Expression<double>? discovererGuessLng,
    Expression<double>? discovererCapturedHeading,
    Expression<int>? isCleared,
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
      if (name != null) 'name': name,
      if (genre != null) 'genre': genre,
      if (googleMapsUrl != null) 'google_maps_url': googleMapsUrl,
      if (referenceHeading != null) 'reference_heading': referenceHeading,
      if (judgeRank != null) 'judge_rank': judgeRank,
      if (distanceErrorMeters != null)
        'distance_error_meters': distanceErrorMeters,
      if (headingErrorDegrees != null)
        'heading_error_degrees': headingErrorDegrees,
      if (guessLat != null) 'guess_lat': guessLat,
      if (guessLng != null) 'guess_lng': guessLng,
      if (capturedHeading != null) 'captured_heading': capturedHeading,
      if (spotId != null) 'spot_id': spotId,
      if (discovererUid != null) 'discoverer_uid': discovererUid,
      if (discovererNickname != null) 'discoverer_nickname': discovererNickname,
      if (discovererThumbPath != null)
        'discoverer_thumb_path': discovererThumbPath,
      if (discovererJudgeRank != null)
        'discoverer_judge_rank': discovererJudgeRank,
      if (discovererDistanceErrorMeters != null)
        'discoverer_distance_error_meters': discovererDistanceErrorMeters,
      if (discovererHeadingErrorDegrees != null)
        'discoverer_heading_error_degrees': discovererHeadingErrorDegrees,
      if (discovererGuessLat != null)
        'discoverer_guess_lat': discovererGuessLat,
      if (discovererGuessLng != null)
        'discoverer_guess_lng': discovererGuessLng,
      if (discovererCapturedHeading != null)
        'discoverer_captured_heading': discovererCapturedHeading,
      if (isCleared != null) 'is_cleared': isCleared,
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
    Value<String?>? name,
    Value<String?>? genre,
    Value<String?>? googleMapsUrl,
    Value<double?>? referenceHeading,
    Value<String?>? judgeRank,
    Value<double?>? distanceErrorMeters,
    Value<double?>? headingErrorDegrees,
    Value<double?>? guessLat,
    Value<double?>? guessLng,
    Value<double?>? capturedHeading,
    Value<String?>? spotId,
    Value<String?>? discovererUid,
    Value<String?>? discovererNickname,
    Value<String?>? discovererThumbPath,
    Value<String?>? discovererJudgeRank,
    Value<double?>? discovererDistanceErrorMeters,
    Value<double?>? discovererHeadingErrorDegrees,
    Value<double?>? discovererGuessLat,
    Value<double?>? discovererGuessLng,
    Value<double?>? discovererCapturedHeading,
    Value<int>? isCleared,
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
      name: name ?? this.name,
      genre: genre ?? this.genre,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      referenceHeading: referenceHeading ?? this.referenceHeading,
      judgeRank: judgeRank ?? this.judgeRank,
      distanceErrorMeters: distanceErrorMeters ?? this.distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees ?? this.headingErrorDegrees,
      guessLat: guessLat ?? this.guessLat,
      guessLng: guessLng ?? this.guessLng,
      capturedHeading: capturedHeading ?? this.capturedHeading,
      spotId: spotId ?? this.spotId,
      discovererUid: discovererUid ?? this.discovererUid,
      discovererNickname: discovererNickname ?? this.discovererNickname,
      discovererThumbPath: discovererThumbPath ?? this.discovererThumbPath,
      discovererJudgeRank: discovererJudgeRank ?? this.discovererJudgeRank,
      discovererDistanceErrorMeters:
          discovererDistanceErrorMeters ?? this.discovererDistanceErrorMeters,
      discovererHeadingErrorDegrees:
          discovererHeadingErrorDegrees ?? this.discovererHeadingErrorDegrees,
      discovererGuessLat: discovererGuessLat ?? this.discovererGuessLat,
      discovererGuessLng: discovererGuessLng ?? this.discovererGuessLng,
      discovererCapturedHeading:
          discovererCapturedHeading ?? this.discovererCapturedHeading,
      isCleared: isCleared ?? this.isCleared,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (googleMapsUrl.present) {
      map['google_maps_url'] = Variable<String>(googleMapsUrl.value);
    }
    if (referenceHeading.present) {
      map['reference_heading'] = Variable<double>(referenceHeading.value);
    }
    if (judgeRank.present) {
      map['judge_rank'] = Variable<String>(judgeRank.value);
    }
    if (distanceErrorMeters.present) {
      map['distance_error_meters'] = Variable<double>(
        distanceErrorMeters.value,
      );
    }
    if (headingErrorDegrees.present) {
      map['heading_error_degrees'] = Variable<double>(
        headingErrorDegrees.value,
      );
    }
    if (guessLat.present) {
      map['guess_lat'] = Variable<double>(guessLat.value);
    }
    if (guessLng.present) {
      map['guess_lng'] = Variable<double>(guessLng.value);
    }
    if (capturedHeading.present) {
      map['captured_heading'] = Variable<double>(capturedHeading.value);
    }
    if (spotId.present) {
      map['spot_id'] = Variable<String>(spotId.value);
    }
    if (discovererUid.present) {
      map['discoverer_uid'] = Variable<String>(discovererUid.value);
    }
    if (discovererNickname.present) {
      map['discoverer_nickname'] = Variable<String>(discovererNickname.value);
    }
    if (discovererThumbPath.present) {
      map['discoverer_thumb_path'] = Variable<String>(
        discovererThumbPath.value,
      );
    }
    if (discovererJudgeRank.present) {
      map['discoverer_judge_rank'] = Variable<String>(
        discovererJudgeRank.value,
      );
    }
    if (discovererDistanceErrorMeters.present) {
      map['discoverer_distance_error_meters'] = Variable<double>(
        discovererDistanceErrorMeters.value,
      );
    }
    if (discovererHeadingErrorDegrees.present) {
      map['discoverer_heading_error_degrees'] = Variable<double>(
        discovererHeadingErrorDegrees.value,
      );
    }
    if (discovererGuessLat.present) {
      map['discoverer_guess_lat'] = Variable<double>(discovererGuessLat.value);
    }
    if (discovererGuessLng.present) {
      map['discoverer_guess_lng'] = Variable<double>(discovererGuessLng.value);
    }
    if (discovererCapturedHeading.present) {
      map['discoverer_captured_heading'] = Variable<double>(
        discovererCapturedHeading.value,
      );
    }
    if (isCleared.present) {
      map['is_cleared'] = Variable<int>(isCleared.value);
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
          ..write('achievedAt: $achievedAt, ')
          ..write('name: $name, ')
          ..write('genre: $genre, ')
          ..write('googleMapsUrl: $googleMapsUrl, ')
          ..write('referenceHeading: $referenceHeading, ')
          ..write('judgeRank: $judgeRank, ')
          ..write('distanceErrorMeters: $distanceErrorMeters, ')
          ..write('headingErrorDegrees: $headingErrorDegrees, ')
          ..write('guessLat: $guessLat, ')
          ..write('guessLng: $guessLng, ')
          ..write('capturedHeading: $capturedHeading, ')
          ..write('spotId: $spotId, ')
          ..write('discovererUid: $discovererUid, ')
          ..write('discovererNickname: $discovererNickname, ')
          ..write('discovererThumbPath: $discovererThumbPath, ')
          ..write('discovererJudgeRank: $discovererJudgeRank, ')
          ..write(
            'discovererDistanceErrorMeters: $discovererDistanceErrorMeters, ',
          )
          ..write(
            'discovererHeadingErrorDegrees: $discovererHeadingErrorDegrees, ',
          )
          ..write('discovererGuessLat: $discovererGuessLat, ')
          ..write('discovererGuessLng: $discovererGuessLng, ')
          ..write('discovererCapturedHeading: $discovererCapturedHeading, ')
          ..write('isCleared: $isCleared')
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
      Value<String?> roomCode,
      Value<String?> coopSyncState,
      Value<int?> coopIsHost,
      Value<String?> coopMembers,
      Value<int?> coopExpiresAt,
      Value<int?> coopDeleteAt,
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
      Value<String?> roomCode,
      Value<String?> coopSyncState,
      Value<int?> coopIsHost,
      Value<String?> coopMembers,
      Value<int?> coopExpiresAt,
      Value<int?> coopDeleteAt,
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

  ColumnFilters<String> get roomCode => $composableBuilder(
    column: $table.roomCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coopSyncState => $composableBuilder(
    column: $table.coopSyncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coopIsHost => $composableBuilder(
    column: $table.coopIsHost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coopMembers => $composableBuilder(
    column: $table.coopMembers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coopExpiresAt => $composableBuilder(
    column: $table.coopExpiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coopDeleteAt => $composableBuilder(
    column: $table.coopDeleteAt,
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

  ColumnOrderings<String> get roomCode => $composableBuilder(
    column: $table.roomCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coopSyncState => $composableBuilder(
    column: $table.coopSyncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coopIsHost => $composableBuilder(
    column: $table.coopIsHost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coopMembers => $composableBuilder(
    column: $table.coopMembers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coopExpiresAt => $composableBuilder(
    column: $table.coopExpiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coopDeleteAt => $composableBuilder(
    column: $table.coopDeleteAt,
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

  GeneratedColumn<String> get roomCode =>
      $composableBuilder(column: $table.roomCode, builder: (column) => column);

  GeneratedColumn<String> get coopSyncState => $composableBuilder(
    column: $table.coopSyncState,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coopIsHost => $composableBuilder(
    column: $table.coopIsHost,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coopMembers => $composableBuilder(
    column: $table.coopMembers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coopExpiresAt => $composableBuilder(
    column: $table.coopExpiresAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get coopDeleteAt => $composableBuilder(
    column: $table.coopDeleteAt,
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
                Value<String?> roomCode = const Value.absent(),
                Value<String?> coopSyncState = const Value.absent(),
                Value<int?> coopIsHost = const Value.absent(),
                Value<String?> coopMembers = const Value.absent(),
                Value<int?> coopExpiresAt = const Value.absent(),
                Value<int?> coopDeleteAt = const Value.absent(),
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
                roomCode: roomCode,
                coopSyncState: coopSyncState,
                coopIsHost: coopIsHost,
                coopMembers: coopMembers,
                coopExpiresAt: coopExpiresAt,
                coopDeleteAt: coopDeleteAt,
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
                Value<String?> roomCode = const Value.absent(),
                Value<String?> coopSyncState = const Value.absent(),
                Value<int?> coopIsHost = const Value.absent(),
                Value<String?> coopMembers = const Value.absent(),
                Value<int?> coopExpiresAt = const Value.absent(),
                Value<int?> coopDeleteAt = const Value.absent(),
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
                roomCode: roomCode,
                coopSyncState: coopSyncState,
                coopIsHost: coopIsHost,
                coopMembers: coopMembers,
                coopExpiresAt: coopExpiresAt,
                coopDeleteAt: coopDeleteAt,
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
      Value<String?> name,
      Value<String?> genre,
      Value<String?> googleMapsUrl,
      Value<double?> referenceHeading,
      Value<String?> judgeRank,
      Value<double?> distanceErrorMeters,
      Value<double?> headingErrorDegrees,
      Value<double?> guessLat,
      Value<double?> guessLng,
      Value<double?> capturedHeading,
      Value<String?> spotId,
      Value<String?> discovererUid,
      Value<String?> discovererNickname,
      Value<String?> discovererThumbPath,
      Value<String?> discovererJudgeRank,
      Value<double?> discovererDistanceErrorMeters,
      Value<double?> discovererHeadingErrorDegrees,
      Value<double?> discovererGuessLat,
      Value<double?> discovererGuessLng,
      Value<double?> discovererCapturedHeading,
      Value<int> isCleared,
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
      Value<String?> name,
      Value<String?> genre,
      Value<String?> googleMapsUrl,
      Value<double?> referenceHeading,
      Value<String?> judgeRank,
      Value<double?> distanceErrorMeters,
      Value<double?> headingErrorDegrees,
      Value<double?> guessLat,
      Value<double?> guessLng,
      Value<double?> capturedHeading,
      Value<String?> spotId,
      Value<String?> discovererUid,
      Value<String?> discovererNickname,
      Value<String?> discovererThumbPath,
      Value<String?> discovererJudgeRank,
      Value<double?> discovererDistanceErrorMeters,
      Value<double?> discovererHeadingErrorDegrees,
      Value<double?> discovererGuessLat,
      Value<double?> discovererGuessLng,
      Value<double?> discovererCapturedHeading,
      Value<int> isCleared,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get googleMapsUrl => $composableBuilder(
    column: $table.googleMapsUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get referenceHeading => $composableBuilder(
    column: $table.referenceHeading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get judgeRank => $composableBuilder(
    column: $table.judgeRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceErrorMeters => $composableBuilder(
    column: $table.distanceErrorMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headingErrorDegrees => $composableBuilder(
    column: $table.headingErrorDegrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get guessLat => $composableBuilder(
    column: $table.guessLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get guessLng => $composableBuilder(
    column: $table.guessLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get capturedHeading => $composableBuilder(
    column: $table.capturedHeading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spotId => $composableBuilder(
    column: $table.spotId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discovererUid => $composableBuilder(
    column: $table.discovererUid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discovererNickname => $composableBuilder(
    column: $table.discovererNickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discovererThumbPath => $composableBuilder(
    column: $table.discovererThumbPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get discovererJudgeRank => $composableBuilder(
    column: $table.discovererJudgeRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discovererDistanceErrorMeters => $composableBuilder(
    column: $table.discovererDistanceErrorMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discovererHeadingErrorDegrees => $composableBuilder(
    column: $table.discovererHeadingErrorDegrees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discovererGuessLat => $composableBuilder(
    column: $table.discovererGuessLat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discovererGuessLng => $composableBuilder(
    column: $table.discovererGuessLng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discovererCapturedHeading => $composableBuilder(
    column: $table.discovererCapturedHeading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCleared => $composableBuilder(
    column: $table.isCleared,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get googleMapsUrl => $composableBuilder(
    column: $table.googleMapsUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get referenceHeading => $composableBuilder(
    column: $table.referenceHeading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get judgeRank => $composableBuilder(
    column: $table.judgeRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceErrorMeters => $composableBuilder(
    column: $table.distanceErrorMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headingErrorDegrees => $composableBuilder(
    column: $table.headingErrorDegrees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get guessLat => $composableBuilder(
    column: $table.guessLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get guessLng => $composableBuilder(
    column: $table.guessLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get capturedHeading => $composableBuilder(
    column: $table.capturedHeading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spotId => $composableBuilder(
    column: $table.spotId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discovererUid => $composableBuilder(
    column: $table.discovererUid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discovererNickname => $composableBuilder(
    column: $table.discovererNickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discovererThumbPath => $composableBuilder(
    column: $table.discovererThumbPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get discovererJudgeRank => $composableBuilder(
    column: $table.discovererJudgeRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discovererDistanceErrorMeters =>
      $composableBuilder(
        column: $table.discovererDistanceErrorMeters,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get discovererHeadingErrorDegrees =>
      $composableBuilder(
        column: $table.discovererHeadingErrorDegrees,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<double> get discovererGuessLat => $composableBuilder(
    column: $table.discovererGuessLat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discovererGuessLng => $composableBuilder(
    column: $table.discovererGuessLng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discovererCapturedHeading => $composableBuilder(
    column: $table.discovererCapturedHeading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCleared => $composableBuilder(
    column: $table.isCleared,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get googleMapsUrl => $composableBuilder(
    column: $table.googleMapsUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get referenceHeading => $composableBuilder(
    column: $table.referenceHeading,
    builder: (column) => column,
  );

  GeneratedColumn<String> get judgeRank =>
      $composableBuilder(column: $table.judgeRank, builder: (column) => column);

  GeneratedColumn<double> get distanceErrorMeters => $composableBuilder(
    column: $table.distanceErrorMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get headingErrorDegrees => $composableBuilder(
    column: $table.headingErrorDegrees,
    builder: (column) => column,
  );

  GeneratedColumn<double> get guessLat =>
      $composableBuilder(column: $table.guessLat, builder: (column) => column);

  GeneratedColumn<double> get guessLng =>
      $composableBuilder(column: $table.guessLng, builder: (column) => column);

  GeneratedColumn<double> get capturedHeading => $composableBuilder(
    column: $table.capturedHeading,
    builder: (column) => column,
  );

  GeneratedColumn<String> get spotId =>
      $composableBuilder(column: $table.spotId, builder: (column) => column);

  GeneratedColumn<String> get discovererUid => $composableBuilder(
    column: $table.discovererUid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discovererNickname => $composableBuilder(
    column: $table.discovererNickname,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discovererThumbPath => $composableBuilder(
    column: $table.discovererThumbPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get discovererJudgeRank => $composableBuilder(
    column: $table.discovererJudgeRank,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discovererDistanceErrorMeters =>
      $composableBuilder(
        column: $table.discovererDistanceErrorMeters,
        builder: (column) => column,
      );

  GeneratedColumn<double> get discovererHeadingErrorDegrees =>
      $composableBuilder(
        column: $table.discovererHeadingErrorDegrees,
        builder: (column) => column,
      );

  GeneratedColumn<double> get discovererGuessLat => $composableBuilder(
    column: $table.discovererGuessLat,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discovererGuessLng => $composableBuilder(
    column: $table.discovererGuessLng,
    builder: (column) => column,
  );

  GeneratedColumn<double> get discovererCapturedHeading => $composableBuilder(
    column: $table.discovererCapturedHeading,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isCleared =>
      $composableBuilder(column: $table.isCleared, builder: (column) => column);

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
                Value<String?> name = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> googleMapsUrl = const Value.absent(),
                Value<double?> referenceHeading = const Value.absent(),
                Value<String?> judgeRank = const Value.absent(),
                Value<double?> distanceErrorMeters = const Value.absent(),
                Value<double?> headingErrorDegrees = const Value.absent(),
                Value<double?> guessLat = const Value.absent(),
                Value<double?> guessLng = const Value.absent(),
                Value<double?> capturedHeading = const Value.absent(),
                Value<String?> spotId = const Value.absent(),
                Value<String?> discovererUid = const Value.absent(),
                Value<String?> discovererNickname = const Value.absent(),
                Value<String?> discovererThumbPath = const Value.absent(),
                Value<String?> discovererJudgeRank = const Value.absent(),
                Value<double?> discovererDistanceErrorMeters =
                    const Value.absent(),
                Value<double?> discovererHeadingErrorDegrees =
                    const Value.absent(),
                Value<double?> discovererGuessLat = const Value.absent(),
                Value<double?> discovererGuessLng = const Value.absent(),
                Value<double?> discovererCapturedHeading = const Value.absent(),
                Value<int> isCleared = const Value.absent(),
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
                name: name,
                genre: genre,
                googleMapsUrl: googleMapsUrl,
                referenceHeading: referenceHeading,
                judgeRank: judgeRank,
                distanceErrorMeters: distanceErrorMeters,
                headingErrorDegrees: headingErrorDegrees,
                guessLat: guessLat,
                guessLng: guessLng,
                capturedHeading: capturedHeading,
                spotId: spotId,
                discovererUid: discovererUid,
                discovererNickname: discovererNickname,
                discovererThumbPath: discovererThumbPath,
                discovererJudgeRank: discovererJudgeRank,
                discovererDistanceErrorMeters: discovererDistanceErrorMeters,
                discovererHeadingErrorDegrees: discovererHeadingErrorDegrees,
                discovererGuessLat: discovererGuessLat,
                discovererGuessLng: discovererGuessLng,
                discovererCapturedHeading: discovererCapturedHeading,
                isCleared: isCleared,
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
                Value<String?> name = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> googleMapsUrl = const Value.absent(),
                Value<double?> referenceHeading = const Value.absent(),
                Value<String?> judgeRank = const Value.absent(),
                Value<double?> distanceErrorMeters = const Value.absent(),
                Value<double?> headingErrorDegrees = const Value.absent(),
                Value<double?> guessLat = const Value.absent(),
                Value<double?> guessLng = const Value.absent(),
                Value<double?> capturedHeading = const Value.absent(),
                Value<String?> spotId = const Value.absent(),
                Value<String?> discovererUid = const Value.absent(),
                Value<String?> discovererNickname = const Value.absent(),
                Value<String?> discovererThumbPath = const Value.absent(),
                Value<String?> discovererJudgeRank = const Value.absent(),
                Value<double?> discovererDistanceErrorMeters =
                    const Value.absent(),
                Value<double?> discovererHeadingErrorDegrees =
                    const Value.absent(),
                Value<double?> discovererGuessLat = const Value.absent(),
                Value<double?> discovererGuessLng = const Value.absent(),
                Value<double?> discovererCapturedHeading = const Value.absent(),
                Value<int> isCleared = const Value.absent(),
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
                name: name,
                genre: genre,
                googleMapsUrl: googleMapsUrl,
                referenceHeading: referenceHeading,
                judgeRank: judgeRank,
                distanceErrorMeters: distanceErrorMeters,
                headingErrorDegrees: headingErrorDegrees,
                guessLat: guessLat,
                guessLng: guessLng,
                capturedHeading: capturedHeading,
                spotId: spotId,
                discovererUid: discovererUid,
                discovererNickname: discovererNickname,
                discovererThumbPath: discovererThumbPath,
                discovererJudgeRank: discovererJudgeRank,
                discovererDistanceErrorMeters: discovererDistanceErrorMeters,
                discovererHeadingErrorDegrees: discovererHeadingErrorDegrees,
                discovererGuessLat: discovererGuessLat,
                discovererGuessLng: discovererGuessLng,
                discovererCapturedHeading: discovererCapturedHeading,
                isCleared: isCleared,
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
