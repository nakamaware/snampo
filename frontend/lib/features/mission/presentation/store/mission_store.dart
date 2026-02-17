import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

part 'mission_store.g.dart';

/// ミッション情報を管理するストア
@riverpod
@JsonPersist()
class MissionStoreNotifier extends _$MissionStoreNotifier {
  @override
  Future<MissionEntity?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// 新規ミッション開始 (API から取得)
  Future<void> startNewMission(Radius radius) async {
    state = const AsyncValue.loading();
    try {
      final useCase = ref.read(getMissionUseCaseProvider);
      final mission = await useCase.call(radius);
      state = AsyncValue.data(mission);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// ミッション完了時にデータクリア
  void clearMission() {
    state = const AsyncValue.data(null);
  }
}
