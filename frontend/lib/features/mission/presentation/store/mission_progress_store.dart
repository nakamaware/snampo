import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

part 'mission_progress_store.g.dart';

/// ミッション進捗を管理するストア
@Riverpod(keepAlive: true)
@JsonPersist()
class MissionProgressStoreNotifier extends _$MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// ミッション進捗を開始する
  ///
  /// [checkpointCount] はチェックポイントの数（waypoints + destination）
  void startProgress(int checkpointCount) {
    state = AsyncValue.data(
      MissionProgressEntity(
        startedAt: DateTime.now(),
        checkpoints: List.filled(checkpointCount, null),
      ),
    );
  }

  /// 撮影した写真を保存し、チェックポイントを更新する
  Future<void> savePhoto(int index, String tempPhotoPath) async {
    final current = state.value;
    if (current == null) return;
    if (index < 0 || index >= current.checkpoints.length) return;

    final useCase = ref.read(savePhotoUseCaseProvider);
    final checkpoint = await useCase.call(
      tempPhotoPath: tempPhotoPath,
      checkpointIndex: index,
    );

    final updated = List<CheckpointProgress?>.from(current.checkpoints);
    updated[index] = checkpoint;
    state = AsyncValue.data(current.copyWith(checkpoints: updated));
  }

  /// 進捗状態のみリセットする（写真ファイルは削除しない）
  ///
  /// ミッション完了後に履歴へ写したあと、再開用ストアだけ空にする場合に使う。
  void resetState() {
    state = const AsyncValue.data(null);
  }

  /// 進捗をクリアする（保存した写真ファイルも削除）
  Future<void> clearProgress() async {
    final current = state.value;
    if (current != null) {
      final useCase = ref.read(clearMissionProgressUseCaseProvider);
      await useCase.call(current);
    }
    state = const AsyncValue.data(null);
  }
}
