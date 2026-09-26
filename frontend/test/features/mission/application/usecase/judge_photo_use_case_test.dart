import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/features/mission/application/usecase/judge_photo_use_case.dart';

final _target = ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  referenceHeading: 90,
);

/// [_target] から北へ [meters] m 離れた位置
Coordinate _northOf(double meters) =>
    Coordinate(latitude: 35 + meters / 111195, longitude: 139);

PhotoJudgeResult _judge({
  required double meters,
  double? heading = 90,
  double zoomLevel = 1,
}) => JudgePhotoUseCase().call(
  currentPosition: _northOf(meters),
  target: _target,
  capturedHeading: heading,
  zoomLevel: zoomLevel,
);

void main() {
  group('JudgePhotoUseCase', () {
    test('距離の上限ごとに判定が変わる', () {
      expect(_judge(meters: 11).rank, PhotoJudgeRank.excellent);
      expect(_judge(meters: 20).rank, PhotoJudgeRank.good);
      expect(_judge(meters: 40).rank, PhotoJudgeRank.fair);
      expect(_judge(meters: 60).rank, PhotoJudgeRank.miss);
    });

    test('向きが 90 度を超えてずれると、距離によらず Miss', () {
      expect(_judge(meters: 1, heading: 190).rank, PhotoJudgeRank.miss);
    });

    test('ズームした倍率で距離を割って判定し、倍率も結果に残す', () {
      final result = _judge(meters: 30, zoomLevel: 2);

      expect(result.rank, PhotoJudgeRank.good);
      expect(result.distanceErrorMeters, closeTo(30, 0.1));
      expect(result.zoomLevel, 2);
    });
  });

  group('PhotoJudgeRank.distanceLimitMeters', () {
    test('Excellent・Good・Fair には上限があり、Miss にはない', () {
      expect(PhotoJudgeRank.excellent.distanceLimitMeters, 12);
      expect(PhotoJudgeRank.good.distanceLimitMeters, 25);
      expect(PhotoJudgeRank.fair.distanceLimitMeters, 50);
      expect(PhotoJudgeRank.miss.distanceLimitMeters, isNull);
    });
  });

  group('effectiveDistanceMeters', () {
    test('倍率で割る。倍率がない・1 倍未満なら割らない', () {
      expect(effectiveDistanceMeters(30, 2), 15);
      expect(effectiveDistanceMeters(30, null), 30);
      expect(effectiveDistanceMeters(30, 0.5), 30);
    });
  });
}
