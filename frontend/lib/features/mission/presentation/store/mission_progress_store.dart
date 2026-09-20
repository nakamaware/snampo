import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

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

  /// チェックポイントの撮影結果と採点結果を確定する
  Future<CheckpointProgress?> completeCheckpoint({
    required int index,
    required String tempPhotoPath,
    required Coordinate? guessPosition,
    required double? capturedHeading,
    required PhotoJudgeRank judgeRank,
    required double distanceErrorMeters,
    required double? headingErrorDegrees,
  }) async {
    final current = state.value;
    if (current == null) return null;
    if (index < 0 || index >= current.checkpoints.length) return null;

    final useCase = ref.read(savePhotoUseCaseProvider);
    final photoStorage = ref.read(photoStorageProvider);
    final checkpoint = await useCase.call(
      tempPhotoPath: tempPhotoPath,
      checkpointIndex: index,
      guessPosition: guessPosition,
      capturedHeading: capturedHeading,
      judgeRank: judgeRank,
      distanceErrorMeters: distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees,
    );

    final latest = state.value;
    if (latest == null || index >= latest.checkpoints.length) {
      final orphanPath = checkpoint.userPhotoPath;
      if (orphanPath != null) {
        try {
          await photoStorage.deletePhoto(orphanPath);
        } on Object {
          // 競合時に後始末失敗したら、呼び出し元へは null を返す
        }
      }
      return null;
    }

    final updated = List<CheckpointProgress?>.from(latest.checkpoints);
    updated[index] = checkpoint;
    state = AsyncValue.data(latest.copyWith(checkpoints: updated));
    return checkpoint;
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
