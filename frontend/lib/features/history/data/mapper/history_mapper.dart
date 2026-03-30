import 'package:drift/drift.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

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
            ),
          )
          .toList();

  return MissionHistory(
    id: h.id,
    completedAt: DateTime.fromMillisecondsSinceEpoch(h.completedAt),
    startedAt: DateTime.fromMillisecondsSinceEpoch(h.startedAt),
    departure: Coordinate(latitude: h.departureLat, longitude: h.departureLng),
    overviewPolyline: h.overviewPolyline,
    spots: spots,
    radius:
        h.radiusMeters == null
            ? null
            : Radius.internal(meters: h.radiusMeters!),
  );
}

/// 完了ミッション (API 用モデル) から Drift 保存用コンパニオンへ変換する境界
///
/// INSERT 時は表示用 [MissionHistory] は組み立てず、DB 行の形に直接寄せる
class HistoryFromMissionMapper {
  HistoryFromMissionMapper._();

  /// 経由地のあとに目的地を並べた一覧 (履歴の sortOrder と一致)
  static List<ImageCoordinate> orderedSpots(MissionEntity mission) {
    return [...mission.waypoints, mission.destination];
  }

  /// Drift `mission_histories` へ挿入する 1 行分
  static MissionHistoriesCompanion missionHistoryRowCompanion({
    required String id,
    required MissionEntity mission,
    required DateTime completedAt,
    required DateTime startedAt,
  }) {
    return MissionHistoriesCompanion.insert(
      id: id,
      completedAt: completedAt.millisecondsSinceEpoch,
      startedAt: startedAt.millisecondsSinceEpoch,
      departureLat: mission.departure.latitude,
      departureLng: mission.departure.longitude,
      overviewPolyline: mission.overviewPolyline,
      radiusMeters: Value(mission.radius?.meters),
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
  }) {
    return HistorySpotsCompanion.insert(
      historyId: historyId,
      sortOrder: sortOrder,
      isDestination: isLastSpot ? 1 : 0,
      lat: spot.coordinate.latitude,
      lng: spot.coordinate.longitude,
      streetViewImagePath: streetViewImagePath,
      userPhotoPath: Value(checkpointProgress?.userPhotoPath),
      achievedAt: Value(checkpointProgress?.achievedAt?.millisecondsSinceEpoch),
    );
  }
}
