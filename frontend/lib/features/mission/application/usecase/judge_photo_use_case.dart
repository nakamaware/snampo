import 'package:geolocator/geolocator.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

/// 写真採点結果
class PhotoJudgeResult {
  /// PhotoJudgeResultのコンストラクタ
  const PhotoJudgeResult({
    required this.rank,
    required this.distanceErrorMeters,
    required this.headingErrorDegrees,
    required this.zoomLevel,
  });

  /// 4 段階評価
  final PhotoJudgeRank rank;

  /// 位置誤差
  final double distanceErrorMeters;

  /// 方角誤差
  final double? headingErrorDegrees;

  /// 撮影したときのズームの倍率
  final double zoomLevel;
}

/// 写真を採点するユースケース
class JudgePhotoUseCase {
  /// 現在位置と基準地点から採点する
  ///
  /// [zoomLevel] はカメラの光学ズーム倍率。N 倍ズームすると被写体が N 倍近く
  /// 見えることを利用し、実距離を N で割った有効距離でランクを判定する。
  /// UI 表示には生の実距離 ([PhotoJudgeResult.distanceErrorMeters]) を使う。
  PhotoJudgeResult call({
    required Coordinate currentPosition,
    required ImageCoordinate target,
    required double? capturedHeading,
    required double zoomLevel,
  }) {
    final distanceErrorMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      target.coordinate.latitude,
      target.coordinate.longitude,
    );
    final headingErrorDegrees = _calculateHeadingError(
      referenceHeading: target.referenceHeading,
      capturedHeading: capturedHeading,
    );

    return PhotoJudgeResult(
      rank: _resolveRank(
        distanceErrorMeters: effectiveDistanceMeters(
          distanceErrorMeters,
          zoomLevel,
        ),
        headingErrorDegrees: headingErrorDegrees,
      ),
      distanceErrorMeters: distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees,
      zoomLevel: zoomLevel,
    );
  }

  PhotoJudgeRank _resolveRank({
    required double distanceErrorMeters,
    required double? headingErrorDegrees,
  }) {
    if (headingErrorDegrees != null &&
        headingErrorDegrees.abs() > photoJudgeHeadingLimitDegrees) {
      return PhotoJudgeRank.miss;
    }
    for (final rank in PhotoJudgeRank.values) {
      final limit = rank.distanceLimitMeters;
      if (limit == null || distanceErrorMeters <= limit) {
        return rank;
      }
    }
    return PhotoJudgeRank.miss;
  }

  /// 方角誤差を符号付きで返す
  ///
  /// 正の値 = 基準より右 (時計回り) にズレている
  /// 負の値 = 基準より左 (反時計回り) にズレている
  double? _calculateHeadingError({
    required double? referenceHeading,
    required double? capturedHeading,
  }) {
    if (referenceHeading == null || capturedHeading == null) {
      return null;
    }

    final raw = capturedHeading - referenceHeading;
    // [-180, 180) に正規化
    return ((raw + 180) % 360) - 180;
  }
}
