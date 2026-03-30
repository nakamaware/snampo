import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/history/domain/entity/mission_history_entity.dart';

part 'history_persisted_state.freezed.dart';
part 'history_persisted_state.g.dart';

/// SQLite の @JsonPersist 用に履歴一覧を 1 オブジェクトとして扱うラッパー
@freezed
abstract class HistoryPersistedState with _$HistoryPersistedState {
  /// [HistoryPersistedState] を作成する
  @JsonSerializable(explicitToJson: true)
  const factory HistoryPersistedState({
    @Default(<MissionHistoryEntity>[]) List<MissionHistoryEntity> records,
  }) = _HistoryPersistedState;

  /// JSON から [HistoryPersistedState] を生成する
  factory HistoryPersistedState.fromJson(Map<String, dynamic> json) =>
      _$HistoryPersistedStateFromJson(json);
}
