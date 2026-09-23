import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

part 'mission_progress_entity.freezed.dart';
part 'mission_progress_entity.g.dart';

/// チェックポイントの進捗
///
/// 各チェックポイント（経由地・目的地）におけるユーザの行動記録
@freezed
abstract class CheckpointProgress with _$CheckpointProgress {
  /// [CheckpointProgress] を作成する
  const factory CheckpointProgress({
    /// 撮影時の位置
    @NullableCoordinateConverter() Coordinate? guessPosition,

    /// 保存した写真のファイルパス
    String? userPhotoPath,

    /// 撮影時の方角
    double? capturedHeading,

    /// 位置誤差 (メートル)
    double? distanceErrorMeters,

    /// 方角誤差 (度)
    double? headingErrorDegrees,

    /// 採点ランク
    @PhotoJudgeRankConverter() PhotoJudgeRank? judgeRank,

    /// 達成した日時 (協力プレイでは発見された日時)
    DateTime? achievedAt,

    /// 協力プレイの発見者の uid (他の人のクリアは「発見者情報つき・自分の写真なし」で反映する)
    String? discovererUid,

    /// 協力プレイの発見者のニックネーム (発見時点)
    String? discovererNickname,

    /// 協力プレイの発見者のサムネのパス (取得できていなければ null)
    String? discovererThumbPath,
  }) = _CheckpointProgress;

  /// JSON から [CheckpointProgress] を生成する
  factory CheckpointProgress.fromJson(Map<String, dynamic> json) =>
      _$CheckpointProgressFromJson(json);
}

/// Coordinate? の JSON 変換
///
/// nullable な [Coordinate] を JSON と相互変換する
class NullableCoordinateConverter
    implements JsonConverter<Coordinate?, Map<String, dynamic>?> {
  /// [NullableCoordinateConverter] を作成する
  const NullableCoordinateConverter();

  @override
  Coordinate? fromJson(Map<String, dynamic>? json) =>
      json == null ? null : const CoordinateConverter().fromJson(json);

  @override
  Map<String, dynamic>? toJson(Coordinate? object) =>
      object == null ? null : const CoordinateConverter().toJson(object);
}

/// PhotoJudgeRank? の JSON 変換
///
/// 旧バージョンで永続化された未知の値 `retry` は [PhotoJudgeRank.miss] として
/// 復元する (未知の enum 名で `$enumDecodeNullable` が例外を投げるのを防ぐ)。
class PhotoJudgeRankConverter
    implements JsonConverter<PhotoJudgeRank?, String?> {
  /// [PhotoJudgeRankConverter] を作成する
  const PhotoJudgeRankConverter();

  @override
  PhotoJudgeRank? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    if (json == 'retry') {
      return PhotoJudgeRank.miss;
    }
    for (final rank in PhotoJudgeRank.values) {
      if (rank.name == json) {
        return rank;
      }
    }
    return null;
  }

  @override
  String? toJson(PhotoJudgeRank? object) => object?.name;
}

/// ミッション進捗エンティティ
///
/// ミッション開始時刻と各チェックポイントの進捗を保持する
@freezed
abstract class MissionProgressEntity with _$MissionProgressEntity {
  /// [MissionProgressEntity] を作成する
  const factory MissionProgressEntity({
    /// ミッション開始時刻
    required DateTime startedAt,

    /// 協力プレイのルームコード (ソロでは null)
    String? roomCode,

    /// 各チェックポイントの進捗（インデックス = スポット番号、null = 未挑戦）
    @Default([])
    @JsonKey(toJson: _missionProgressCheckpointsToJson)
    List<CheckpointProgress?> checkpoints,
  }) = _MissionProgressEntity;

  const MissionProgressEntity._();

  /// JSON から [MissionProgressEntity] を生成する
  factory MissionProgressEntity.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressEntityFromJson(json);
}

List<Object?> _missionProgressCheckpointsToJson(
  List<CheckpointProgress?> list,
) => list.map((e) => e?.toJson()).toList();
