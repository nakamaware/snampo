import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

part 'mission_history_entity.freezed.dart';
part 'mission_history_entity.g.dart';

/// 完了したミッションを履歴として保存するためのエンティティ
@freezed
abstract class MissionHistoryEntity with _$MissionHistoryEntity {
  /// [MissionHistoryEntity] を作成する
  @JsonSerializable(explicitToJson: true)
  const factory MissionHistoryEntity({
    required String id,
    required DateTime completedAt,
    required MissionEntity mission,
    required MissionProgressEntity progress,
  }) = _MissionHistoryEntity;

  /// JSON から [MissionHistoryEntity] を生成する
  factory MissionHistoryEntity.fromJson(Map<String, dynamic> json) =>
      _$MissionHistoryEntityFromJson(json);
}
