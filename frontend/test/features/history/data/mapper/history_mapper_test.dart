import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/mapper/history_mapper.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

void main() {
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
        ),
      ],
    );

    expect(history.spots.single.judgeRank, PhotoJudgeRank.miss);
  });
}
