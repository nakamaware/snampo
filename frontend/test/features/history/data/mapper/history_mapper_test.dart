import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/mapper/history_mapper.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

const _history = MissionHistoryRow(
  id: 'history-id',
  completedAt: 0,
  startedAt: 0,
  departureLat: 35,
  departureLng: 139,
  overviewPolyline: 'polyline',
  radiusMeters: 1000,
  mode: historyModeRandom,
);

void main() {
  test('自分と発見者のズームの倍率を履歴に復元する', () {
    final history = missionHistoryFromDriftRows(_history, const [
      HistorySpotRow(
        id: 1,
        historyId: 'history-id',
        sortOrder: 0,
        isDestination: 1,
        lat: 35,
        lng: 139,
        streetViewImagePath: '/tmp/street-view.jpg',
        judgeRank: 'good',
        distanceErrorMeters: 30,
        zoomLevel: 2,
        discovererJudgeRank: 'fair',
        discovererDistanceErrorMeters: 40,
        discovererZoomLevel: 1.5,
        isCleared: 1,
      ),
    ]);

    final spot = history.spots.single;
    expect(spot.zoomLevel, 2);
    expect(spot.discovererJudgement?.zoomLevel, 1.5);
  });

  test('撮影した進捗のズームの倍率を、スポットの行に書く', () {
    final row = HistoryFromMissionMapper.spotRowCompanion(
      historyId: 'history-id',
      sortOrder: 0,
      isLastSpot: true,
      spot: ImageCoordinate(
        coordinate: Coordinate(latitude: 35, longitude: 139),
        imageBase64: '',
      ),
      streetViewImagePath: '/tmp/street-view.jpg',
      checkpointProgress: const CheckpointProgress(zoomLevel: 2),
    );

    expect(row.zoomLevel.value, 2);
  });

  test('旧形式の retry ランクを miss として履歴に復元する', () {
    final history = missionHistoryFromDriftRows(
      const MissionHistoryRow(
        id: 'history-id',
        completedAt: 0,
        startedAt: 0,
        departureLat: 35,
        departureLng: 139,
        overviewPolyline: 'polyline',
        radiusMeters: 1000,
        mode: historyModeRandom,
      ),
      const [
        HistorySpotRow(
          id: 1,
          historyId: 'history-id',
          sortOrder: 0,
          isDestination: 1,
          lat: 35,
          lng: 139,
          streetViewImagePath: '/tmp/street-view.jpg',
          judgeRank: 'retry',
          isCleared: 1,
        ),
      ],
    );

    expect(history.spots.single.judgeRank, PhotoJudgeRank.miss);
  });
}
