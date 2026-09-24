import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/coop/data/mapper/room_mapper.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/photo_judgement.dart';

void main() {
  group('RoomMapper の採点 (judgement)', () {
    test('すべての項目を Firestore の map にして、読み戻せる', () {
      final judgement = PhotoJudgement(
        rank: PhotoJudgeRank.fair,
        distanceErrorMeters: 40.5,
        headingErrorDegrees: 12,
        guessPosition: Coordinate(latitude: 35.68, longitude: 139.76),
        capturedHeading: 270,
      );

      final data = RoomMapper.judgementToFirestore(judgement);

      expect(data, {
        'rank': 'fair',
        'distanceErrorMeters': 40.5,
        'headingErrorDegrees': 12,
        'guessLatitude': 35.68,
        'guessLongitude': 139.76,
        'capturedHeading': 270,
      });
      expect(RoomMapper.judgementFromFirestore(data), judgement);
    });

    test('値のない項目は書かない (Rules は書いた項目だけ型を検証する)', () {
      const judgement = PhotoJudgement(
        rank: PhotoJudgeRank.miss,
        distanceErrorMeters: 120,
      );

      expect(RoomMapper.judgementToFirestore(judgement), {
        'rank': 'miss',
        'distanceErrorMeters': 120,
      });
    });

    test('整数で保存された数値も読める', () {
      expect(
        RoomMapper.judgementFromFirestore({
          'rank': 'good',
          'distanceErrorMeters': 20,
        }),
        const PhotoJudgement(
          rank: PhotoJudgeRank.good,
          distanceErrorMeters: 20,
        ),
      );
    });

    test('古いクリア (judgement なし) や、読めない値は null にする', () {
      expect(RoomMapper.judgementFromFirestore(null), isNull);
      expect(
        RoomMapper.judgementFromFirestore({
          'rank': 'unknown',
          'distanceErrorMeters': 1,
        }),
        isNull,
      );
    });
  });
}
