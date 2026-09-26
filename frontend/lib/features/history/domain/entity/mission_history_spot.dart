import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/spot_id.dart';

part 'mission_history_spot.freezed.dart';

/// ミッション履歴内の1スポット
@freezed
abstract class MissionHistorySpot with _$MissionHistorySpot {
  /// [MissionHistorySpot] を作成する
  const factory MissionHistorySpot({
    required Coordinate coordinate,
    required int sortOrder,
    required bool isDestination,
    required String streetViewImagePath,
    String? userPhotoPath,
    DateTime? achievedAt,
    String? name,
    String? genre,
    String? googleMapsUrl,
    double? referenceHeading,
    PhotoJudgeRank? judgeRank,
    double? distanceErrorMeters,
    double? headingErrorDegrees,
    Coordinate? guessPosition,
    double? capturedHeading,

    /// 撮影したときのズームの倍率 (古い履歴では null)
    double? zoomLevel,

    /// スポット ID (旧データでは null)
    SpotId? spotId,

    /// 協力プレイの発見者の uid
    String? discovererUid,

    /// 協力プレイの発見者のニックネーム (発見時点)
    String? discovererNickname,

    /// 協力プレイの発見者のサムネのパス (取得できなければ null)
    String? discovererThumbPath,

    /// 協力プレイの発見者の採点 (共有されていなければ null)
    PhotoJudgement? discovererJudgement,

    /// クリア済みか (協力プレイの途中終了では未クリアのスポットがある)
    @Default(true) bool isCleared,
  }) = _MissionHistorySpot;

  const MissionHistorySpot._();

  /// 結果 (自分の撮影か、協力プレイの発見者の撮影) があるか
  ///
  /// 協力プレイで他の人が発見したスポットも、発見者の結果を見られる。
  bool get hasResult => userPhotoPath != null || discovererUid != null;

  /// 出す写真のパス
  ///
  /// 自分が撮っていれば自分の写真、撮っていなければ協力プレイの発見者のサムネ。
  /// 未クリアのスポットには出さない。
  String? get shownPhotoPath =>
      isCleared ? userPhotoPath ?? discovererThumbPath : null;

  /// 出す判定
  ///
  /// 自分が撮っていれば自分の判定、撮っていなければ協力プレイの発見者の判定。
  /// 未クリアのスポットには出さない。
  PhotoJudgeRank? get shownRank =>
      isCleared ? judgeRank ?? discovererJudgement?.rank : null;
}
