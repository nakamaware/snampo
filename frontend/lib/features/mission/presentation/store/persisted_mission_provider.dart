import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

part 'persisted_mission_provider.g.dart';

/// 再開用に [MissionEntity] を SQLite に永続化するプロバイダー
@Riverpod(keepAlive: true)
@JsonPersist()
class PersistedMission extends _$PersistedMission {
  @override
  Future<MissionEntity?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// 現在のミッションを保存する（API 取得成功時など）
  void setMission(MissionEntity mission) {
    state = AsyncValue.data(mission);
  }

  /// ミッション完了時などにクリアする
  void clearMission() {
    state = const AsyncValue.data(null);
  }
}
