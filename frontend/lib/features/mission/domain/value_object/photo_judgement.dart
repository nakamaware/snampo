import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

part 'photo_judgement.freezed.dart';
part 'photo_judgement.g.dart';

/// 撮影の採点 (判定と、そのもとになった位置と向き)
///
/// 協力プレイでは、発見者の採点をクリアと一緒に共有し、他の人も同じ結果を見られるようにする。
@freezed
abstract class PhotoJudgement with _$PhotoJudgement {
  /// [PhotoJudgement] を作成する
  const factory PhotoJudgement({
    /// 採点ランク
    @JsonKey(fromJson: _rankFromJson, toJson: _rankToJson)
    required PhotoJudgeRank rank,

    /// 位置誤差 (メートル)
    required double distanceErrorMeters,

    /// 方角誤差 (度。向きを取れなければ null)
    double? headingErrorDegrees,

    /// 撮影した位置
    @NullableCoordinateConverter() Coordinate? guessPosition,

    /// 撮影したときの向き (度)
    double? capturedHeading,

    /// 撮影したときのズームの倍率 (共有されていなければ null)
    double? zoomLevel,
  }) = _PhotoJudgement;

  /// JSON から [PhotoJudgement] を生成する
  factory PhotoJudgement.fromJson(Map<String, dynamic> json) =>
      _$PhotoJudgementFromJson(json);

  /// 撮影して採点したチェックポイントの採点 (採点していなければ null)
  static PhotoJudgement? ofCheckpoint(CheckpointProgress checkpoint) {
    final rank = checkpoint.judgeRank;
    final distance = checkpoint.distanceErrorMeters;
    if (rank == null || distance == null) {
      return null;
    }
    return PhotoJudgement(
      rank: rank,
      distanceErrorMeters: distance,
      headingErrorDegrees: checkpoint.headingErrorDegrees,
      guessPosition: checkpoint.guessPosition,
      capturedHeading: checkpoint.capturedHeading,
      zoomLevel: checkpoint.zoomLevel,
    );
  }
}

PhotoJudgeRank _rankFromJson(String json) =>
    const PhotoJudgeRankConverter().fromJson(json) ?? PhotoJudgeRank.miss;

String _rankToJson(PhotoJudgeRank rank) => rank.name;
