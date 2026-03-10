import 'package:freezed_annotation/freezed_annotation.dart';
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
    /// 撮影時の位置（将来用、現状は null）
    @NullableCoordinateConverter() Coordinate? guessPosition,
    /// 保存した写真のファイルパス
    String? userPhotoPath,
    /// 達成した日時
    DateTime? achievedAt,
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

/// ミッション進捗エンティティ
///
/// ミッション開始時刻と各チェックポイントの進捗を保持する
@freezed
abstract class MissionProgressEntity with _$MissionProgressEntity {
  /// [MissionProgressEntity] を作成する
  const factory MissionProgressEntity({
    /// ミッション開始時刻
    required DateTime startedAt,
    /// 各チェックポイントの進捗（インデックス = スポット番号、null = 未挑戦）
    @Default([]) List<CheckpointProgress?> checkpoints,
  }) = _MissionProgressEntity;

  const MissionProgressEntity._();

  /// JSON から [MissionProgressEntity] を生成する
  factory MissionProgressEntity.fromJson(Map<String, dynamic> json) =>
      _$MissionProgressEntityFromJson(json);
}
