import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';

MissionHistorySpot _spot({
  String? userPhotoPath,
  PhotoJudgeRank? judgeRank,
  String? discovererThumbPath,
  PhotoJudgement? discovererJudgement,
  String? discovererUid,
  bool isCleared = true,
}) => MissionHistorySpot(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  sortOrder: 0,
  isDestination: false,
  streetViewImagePath: '/sv.jpg',
  userPhotoPath: userPhotoPath,
  judgeRank: judgeRank,
  discovererThumbPath: discovererThumbPath,
  discovererJudgement: discovererJudgement,
  discovererUid: discovererUid,
  isCleared: isCleared,
);

void main() {
  test('MissionHistorySpot.hasResult は、自分の撮影か発見者があれば true', () {
    expect(_spot(userPhotoPath: '/mine.jpg').hasResult, isTrue);
    expect(_spot(discovererUid: 'other').hasResult, isTrue);
    expect(_spot().hasResult, isFalse);
  });

  group('MissionHistorySpot に出す写真と判定', () {
    test('自分の写真と判定があれば、それを使う', () {
      final spot = _spot(
        userPhotoPath: '/mine.jpg',
        judgeRank: PhotoJudgeRank.good,
        discovererThumbPath: '/thumb.jpg',
      );

      expect(spot.shownPhotoPath, '/mine.jpg');
      expect(spot.shownRank, PhotoJudgeRank.good);
    });

    test('自分が撮っていなければ、発見者のサムネと採点を使う', () {
      final spot = _spot(
        discovererThumbPath: '/thumb.jpg',
        discovererJudgement: const PhotoJudgement(
          rank: PhotoJudgeRank.fair,
          distanceErrorMeters: 30,
        ),
      );

      expect(spot.shownPhotoPath, '/thumb.jpg');
      expect(spot.shownRank, PhotoJudgeRank.fair);
    });

    test('未クリアのスポットは、写真も判定も出さない', () {
      final spot = _spot(isCleared: false, discovererThumbPath: '/thumb.jpg');

      expect(spot.shownPhotoPath, isNull);
      expect(spot.shownRank, isNull);
    });
  });

  group('MissionHistory', () {
    final start = DateTime(2026, 9, 25, 4, 39);
    MissionHistory history(DateTime completedAt, List<DateTime?> achieved) =>
        MissionHistory(
          id: 'h',
          startedAt: start,
          completedAt: completedAt,
          departure: Coordinate(latitude: 35, longitude: 139),
          overviewPolyline: '',
          settings: MissionSettings.random(radius: Radius(meters: 1000)),
          spots: [
            for (final at in achieved)
              MissionHistorySpot(
                coordinate: Coordinate(latitude: 35, longitude: 139),
                sortOrder: 0,
                isDestination: false,
                streetViewImagePath: '/sv.jpg',
                achievedAt: at,
              ),
          ],
        );

    test('協力プレイの情報がなければソロ', () {
      expect(history(start, const []).sessionKind, MissionSessionKind.solo);
    });

    test('終わった時刻があれば、それを使う', () {
      final end = start.add(const Duration(minutes: 30));
      expect(history(end, [start]).playEndedAt, end);
    });

    test('協力プレイの途中 (終わった時刻がまだない) なら、最後の発見の時刻を使う', () {
      final last = start.add(const Duration(minutes: 12));
      expect(
        history(start, [
          start.add(const Duration(minutes: 5)),
          last,
          null,
        ]).playEndedAt,
        last,
      );
      expect(history(start, [null]).playEndedAt, isNull);
    });
  });
}
