import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';

part 'persisted_mission_provider.g.dart';

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
@Riverpod(keepAlive: true)
@JsonPersist()
class PersistedMission extends _$PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// ソロの既存データをそのまま読めるように、ソロは以前と同じキーを使う
  @override
  String get key => switch (kind) {
    MissionSessionKind.solo => 'PersistedMission',
    MissionSessionKind.coop => 'PersistedMission.coop',
  };

  /// 現在のミッションを保存する（API 取得成功時など）
  void setMission(MissionEntity mission) {
    state = AsyncValue.data(mission);
  }

  /// ミッション完了時などにクリアする
  void clearMission() {
    state = const AsyncValue.data(null);
  }
}
