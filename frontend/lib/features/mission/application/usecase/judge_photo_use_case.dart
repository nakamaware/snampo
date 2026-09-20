import 'package:geolocator/geolocator.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';

const _excellentDistanceThresholdMeters = 12.0;
const _excellentHeadingThresholdDegrees = 90.0;

const _goodDistanceThresholdMeters = 25.0;
const _goodHeadingThresholdDegrees = 90.0;

const _fairDistanceThresholdMeters = 50.0;
const _fairHeadingThresholdDegrees = 90.0;

/// 写真採点結果
class PhotoJudgeResult {
  /// PhotoJudgeResultのコンストラクタ
  const PhotoJudgeResult({
    required this.rank,
    required this.distanceErrorMeters,
    required this.headingErrorDegrees,
  });

  /// 4 段階評価
  final PhotoJudgeRank rank;

  /// 位置誤差
  final double distanceErrorMeters;

  /// 方角誤差
  final double? headingErrorDegrees;
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
    final effectiveDistanceMeters = _applyZoomCorrection(
      distanceErrorMeters,
      zoomLevel,
    );
    final headingErrorDegrees = _calculateHeadingError(
      referenceHeading: target.referenceHeading,
      capturedHeading: capturedHeading,
    );

    return PhotoJudgeResult(
      rank: _resolveRank(
        distanceErrorMeters: effectiveDistanceMeters,
        headingErrorDegrees: headingErrorDegrees,
      ),
      distanceErrorMeters: distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees,
    );
  }

  /// ズームレベルによる距離補正を適用する
  ///
  /// ズームレベルが 1.0 未満の場合は補正なし (1.0 に切り上げる)。
  double _applyZoomCorrection(double distanceMeters, double zoomLevel) {
    final effectiveZoom = zoomLevel.clamp(1.0, double.infinity);
    return distanceMeters / effectiveZoom;
  }

  PhotoJudgeRank _resolveRank({
    required double distanceErrorMeters,
    required double? headingErrorDegrees,
  }) {
    if (_matches(
      distanceErrorMeters,
      headingErrorDegrees,
      _excellentDistanceThresholdMeters,
      _excellentHeadingThresholdDegrees,
    )) {
      return PhotoJudgeRank.excellent;
    }
    if (_matches(
      distanceErrorMeters,
      headingErrorDegrees,
      _goodDistanceThresholdMeters,
      _goodHeadingThresholdDegrees,
    )) {
      return PhotoJudgeRank.good;
    }
    if (_matches(
      distanceErrorMeters,
      headingErrorDegrees,
      _fairDistanceThresholdMeters,
      _fairHeadingThresholdDegrees,
    )) {
      return PhotoJudgeRank.fair;
    }
    return PhotoJudgeRank.miss;
  }

  bool _matches(
    double distanceErrorMeters,
    double? headingErrorDegrees,
    double distanceThreshold,
    double headingThreshold,
  ) {
    if (distanceErrorMeters > distanceThreshold) {
      return false;
    }
    if (headingErrorDegrees == null) {
      return true;
    }
    return headingErrorDegrees.abs() <= headingThreshold;
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
