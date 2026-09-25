import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';

MissionHistorySpot _spot({
  String? userPhotoPath,
  PhotoJudgeRank? judgeRank,
  String? discovererThumbPath,
  PhotoJudgement? discovererJudgement,
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
  isCleared: isCleared,
);

void main() {
  test('一覧の日付は、月日・曜日・時刻にする', () {
    expect(formatHistoryDate(DateTime(2026, 9, 23, 14, 5)), '9月23日 (水) 14:05');
    expect(formatHistoryMonth(DateTime(2026, 9, 23)), '2026年9月');
  });

  test('一覧のかかった時間は、秒を省く (1 分未満なら秒)', () {
    final start = DateTime(2026, 9, 23, 14);
    expect(
      formatMissionDurationShort(
        start,
        start.add(const Duration(hours: 1, minutes: 12, seconds: 40)),
      ),
      '1時間12分',
    );
    expect(
      formatMissionDurationShort(
        start,
        start.add(const Duration(minutes: 48, seconds: 5)),
      ),
      '48分',
    );
    expect(
      formatMissionDurationShort(start, start.add(const Duration(seconds: 40))),
      '40秒',
    );
  });

  group('履歴のスポットに出す写真と判定', () {
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

  group('MissionHistory.playEndedAt', () {
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
