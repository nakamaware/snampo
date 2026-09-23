import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

/// Drift [MissionHistories.mode] の値
const String historyModeRandom = 'random';

/// Drift [MissionHistories.mode] の値
const String historyModeDestination = 'destination';

/// Drift [MissionHistories.mode] の値 (協力プレイ)
const String historyModeCoop = 'coop';

PhotoJudgeRank? _judgeRankFromDb(String? value) {
  if (value == null || value.isEmpty) {
    return null;
  }
  if (value == 'retry') {
    return PhotoJudgeRank.miss;
  }
  for (final rank in PhotoJudgeRank.values) {
    if (rank.name == value) {
      return rank;
    }
  }
  return null;
}

Coordinate? _guessPositionFromDb({required double? lat, required double? lng}) {
  if (lat == null || lng == null) {
    return null;
  }
  return Coordinate(latitude: lat, longitude: lng);
}

/// Drift 行とスポット一覧から [MissionSettings] を組み立てる
MissionSettings missionSettingsFromHistoryRow(
  MissionHistoryRow h,
  List<MissionHistorySpot> spots,
) {
  if (h.mode == historyModeRandom) {
    final meters = h.radiusMeters;
    if (meters == null) {
      throw StateError('履歴 ${h.id} は random ですが radius_meters がありません');
    }
    return MissionSettings.random(radius: Radius.internal(meters: meters));
  }
  if (h.mode == historyModeCoop) {
    final meters = h.radiusMeters;
    if (meters != null) {
      return MissionSettings.random(radius: Radius.internal(meters: meters));
    }
  }
  if (h.mode == historyModeDestination || h.mode == historyModeCoop) {
    var lat = h.destinationLat;
    var lng = h.destinationLng;
    if (lat == null || lng == null) {
      for (final s in spots) {
        if (s.isDestination) {
          lat = s.coordinate.latitude;
          lng = s.coordinate.longitude;
          break;
        }
      }
    }
    if (lat == null || lng == null) {
      throw StateError('履歴 ${h.id} は destination ですが座標がありません');
    }
    return MissionSettings.destination(
      destination: Coordinate.internal(latitude: lat, longitude: lng),
    );
  }
  throw StateError('履歴 ${h.id} の mode が不正です: ${h.mode}');
}

/// 履歴 Drift 層とドメイン・mission 境界の相互変換 (書き込み・読み込みを 1 ファイルに集約)

/// Drift 行から履歴表示用 [MissionHistory] を組み立てる
MissionHistory missionHistoryFromDriftRows(
  MissionHistoryRow h,
  List<HistorySpotRow> spotRows,
) {
  if (spotRows.isEmpty) {
    throw StateError('履歴 ${h.id} にスポット行がありません');
  }
  final spots =
      spotRows
          .map(
            (s) => MissionHistorySpot(
              coordinate: Coordinate(latitude: s.lat, longitude: s.lng),
              sortOrder: s.sortOrder,
              isDestination: s.isDestination != 0,
              streetViewImagePath: s.streetViewImagePath,
              userPhotoPath: s.userPhotoPath,
              achievedAt:
                  s.achievedAt == null
                      ? null
                      : DateTime.fromMillisecondsSinceEpoch(s.achievedAt!),
              name: s.name,
              genre: s.genre,
              googleMapsUrl: s.googleMapsUrl,
              referenceHeading: s.referenceHeading,
              judgeRank: _judgeRankFromDb(s.judgeRank),
              distanceErrorMeters: s.distanceErrorMeters,
              headingErrorDegrees: s.headingErrorDegrees,
              guessPosition: _guessPositionFromDb(
                lat: s.guessLat,
                lng: s.guessLng,
              ),
              capturedHeading: s.capturedHeading,
              spotId: s.spotId == null ? null : SpotId.parse(s.spotId!),
              discovererUid: s.discovererUid,
              discovererNickname: s.discovererNickname,
              discovererThumbPath: s.discovererThumbPath,
              isCleared: s.isCleared != 0,
            ),
          )
          .toList();

  final settings = missionSettingsFromHistoryRow(h, spots);

  return MissionHistory(
    id: h.id,
    completedAt: DateTime.fromMillisecondsSinceEpoch(h.completedAt),
    startedAt: DateTime.fromMillisecondsSinceEpoch(h.startedAt),
    departure: Coordinate(latitude: h.departureLat, longitude: h.departureLng),
    overviewPolyline: h.overviewPolyline,
    spots: spots,
    settings: settings,
    coop: _coopInfoFromRow(h),
  );
}

CoopHistoryInfo? _coopInfoFromRow(MissionHistoryRow h) {
  final rawRoomCode = h.roomCode;
  if (h.mode != historyModeCoop || rawRoomCode == null) {
    return null;
  }
  final roomCode = const RoomCodeConverter().fromJson(rawRoomCode);
  final expiresAt = h.coopExpiresAt;
  final deleteAt = h.coopDeleteAt;
  if (expiresAt == null || deleteAt == null) {
    throw StateError('履歴 ${h.id} は coop ですが期限がありません');
  }
  return CoopHistoryInfo(
    roomCode: roomCode,
    syncState: coopSyncStateFromDb(h.coopSyncState),
    isHost: h.coopIsHost == 1,
    members: coopMembersFromDb(h.coopMembers),
    expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt, isUtc: true),
    deleteAt: DateTime.fromMillisecondsSinceEpoch(deleteAt, isUtc: true),
  );
}

/// Drift [MissionHistories.coopSyncState] から [CoopSyncState] に変換する
CoopSyncState coopSyncStateFromDb(String? value) =>
    value == CoopSyncState.finalized.name
        ? CoopSyncState.finalized
        : CoopSyncState.inProgress;

/// Drift [MissionHistories.coopMembers] の JSON からメンバー一覧に変換する
List<CoopHistoryMember> coopMembersFromDb(String? json) {
  if (json == null || json.isEmpty) {
    return const [];
  }
  return (jsonDecode(json) as List<dynamic>)
      .map((e) => CoopHistoryMember.fromJson(e as Map<String, dynamic>))
      .toList();
}

/// メンバー一覧を Drift [MissionHistories.coopMembers] の JSON に変換する
String coopMembersToDb(List<CoopHistoryMember> members) =>
    jsonEncode(members.map((m) => m.toJson()).toList());

/// 完了ミッション (API 用モデル) から Drift 保存用コンパニオンへ変換する境界
///
/// INSERT 時は表示用 [MissionHistory] は組み立てず、DB 行の形に直接寄せる
class HistoryFromMissionMapper {
  HistoryFromMissionMapper._();

  /// 経由地のあとに目的地を並べた一覧 (履歴の sortOrder と一致)
  static List<ImageCoordinate> orderedSpots(MissionEntity mission) {
    return mission.spots;
  }

  /// Drift `mission_histories` へ挿入する 1 行分
  static MissionHistoriesCompanion missionHistoryRowCompanion({
    required String id,
    required MissionEntity mission,
    required DateTime completedAt,
    required DateTime startedAt,
  }) {
    final isRandom = mission.radius != null;
    return MissionHistoriesCompanion.insert(
      id: id,
      completedAt: completedAt.millisecondsSinceEpoch,
      startedAt: startedAt.millisecondsSinceEpoch,
      departureLat: mission.departure.latitude,
      departureLng: mission.departure.longitude,
      overviewPolyline: mission.overviewPolyline,
      radiusMeters: Value(mission.radius?.meters),
      mode: Value(isRandom ? historyModeRandom : historyModeDestination),
      destinationLat: Value(
        isRandom ? null : mission.destination.coordinate.latitude,
      ),
      destinationLng: Value(
        isRandom ? null : mission.destination.coordinate.longitude,
      ),
    );
  }

  /// Drift `mission_histories` へ挿入する協力プレイの 1 行分
  ///
  /// 協力プレイの履歴は playing に遷移した時点で「進行中」として作成し、
  /// その後は roomCode をキーに upsert する。完了日時は開始日時で仮置きする。
  static MissionHistoriesCompanion coopHistoryRowCompanion({
    required String id,
    required MissionEntity mission,
    required DateTime startedAt,
    required CoopHistoryInfo coop,
  }) {
    final isRandom = mission.radius != null;
    return MissionHistoriesCompanion.insert(
      id: id,
      completedAt: startedAt.millisecondsSinceEpoch,
      startedAt: startedAt.millisecondsSinceEpoch,
      departureLat: mission.departure.latitude,
      departureLng: mission.departure.longitude,
      overviewPolyline: mission.overviewPolyline,
      radiusMeters: Value(mission.radius?.meters),
      mode: const Value(historyModeCoop),
      destinationLat: Value(
        isRandom ? null : mission.destination.coordinate.latitude,
      ),
      destinationLng: Value(
        isRandom ? null : mission.destination.coordinate.longitude,
      ),
      roomCode: Value(coop.roomCode.value),
      coopSyncState: Value(coop.syncState.name),
      coopIsHost: Value(coop.isHost ? 1 : 0),
      coopMembers: Value(coopMembersToDb(coop.members)),
      coopExpiresAt: Value(coop.expiresAt.millisecondsSinceEpoch),
      coopDeleteAt: Value(coop.deleteAt.millisecondsSinceEpoch),
    );
  }

  /// Drift `history_spots` へ挿入する 1 行分
  static HistorySpotsCompanion spotRowCompanion({
    required String historyId,
    required int sortOrder,
    required bool isLastSpot,
    required ImageCoordinate spot,
    required String streetViewImagePath,
    CheckpointProgress? checkpointProgress,
    String? userPhotoPath,
    bool isCleared = true,
  }) {
    final cp = checkpointProgress;
    return HistorySpotsCompanion.insert(
      historyId: historyId,
      sortOrder: sortOrder,
      isDestination: isLastSpot ? 1 : 0,
      lat: spot.coordinate.latitude,
      lng: spot.coordinate.longitude,
      streetViewImagePath: streetViewImagePath,
      userPhotoPath: Value(userPhotoPath ?? cp?.userPhotoPath),
      achievedAt: Value(cp?.achievedAt?.millisecondsSinceEpoch),
      name: Value(spot.name),
      genre: Value(spot.genre),
      googleMapsUrl: Value(spot.googleMapsUrl),
      referenceHeading: Value(spot.referenceHeading),
      judgeRank: Value(cp?.judgeRank?.name),
      distanceErrorMeters: Value(cp?.distanceErrorMeters),
      headingErrorDegrees: Value(cp?.headingErrorDegrees),
      guessLat: Value(cp?.guessPosition?.latitude),
      guessLng: Value(cp?.guessPosition?.longitude),
      capturedHeading: Value(cp?.capturedHeading),
      spotId: Value(spot.spotId?.value),
      isCleared: Value(isCleared ? 1 : 0),
    );
  }
}
