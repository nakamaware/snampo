import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';

part 'mission_progress_store.g.dart';

/// 協力プレイで、あるスポットを発見した人
typedef CoopDiscovery =
    ({String uid, String nickname, DateTime clearedAt, String? thumbPath});

/// ミッション進捗を管理するストア
///
/// セッション種別 (ソロ / 協力プレイ) ごとに 1 枠ずつ保存する。
@Riverpod(keepAlive: true)
@JsonPersist()
class MissionProgressStoreNotifier extends _$MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// ソロの既存データをそのまま読めるように、ソロは以前と同じキーを使う
  @override
  String get key => switch (kind) {
    MissionSessionKind.solo => 'MissionProgressStoreNotifier',
    MissionSessionKind.coop => 'MissionProgressStoreNotifier.coop',
  };

  /// ミッション進捗を開始する
  ///
  /// [checkpointCount] はチェックポイントの数（waypoints + destination）
  /// [roomCode] は協力プレイのルームコード (ソロでは null)
  void startProgress(int checkpointCount, {String? roomCode}) {
    state = AsyncValue.data(
      MissionProgressEntity(
        startedAt: DateTime.now(),
        roomCode: roomCode,
        checkpoints: List.filled(checkpointCount, null),
      ),
    );
  }

  /// 撮影した写真の保存先のサブディレクトリ
  String _photoSubdirectory(MissionProgressEntity progress) {
    final roomCode = progress.roomCode;
    return roomCode == null ? 'solo' : 'coop/$roomCode';
  }

  /// チェックポイントの撮影結果と採点結果を確定する
  ///
  /// 協力プレイで既に発見者がいる場合も、発見者の情報は残したまま自分の写真と採点を記録する。
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
      photoSubdirectory: _photoSubdirectory(current),
      guessPosition: guessPosition,
      capturedHeading: capturedHeading,
      judgeRank: judgeRank,
      distanceErrorMeters: distanceErrorMeters,
      headingErrorDegrees: headingErrorDegrees,
    );

    final latest = state.value;
    if (latest == null ||
        index >= latest.checkpoints.length ||
        latest.roomCode != current.roomCode) {
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

    final previous = latest.checkpoints[index];
    final merged = checkpoint.copyWith(
      discovererUid: previous?.discovererUid,
      discovererNickname: previous?.discovererNickname,
      discovererThumbPath: previous?.discovererThumbPath,
      achievedAt: previous?.achievedAt ?? checkpoint.achievedAt,
    );
    final updated = List<CheckpointProgress?>.from(latest.checkpoints);
    updated[index] = merged;
    state = AsyncValue.data(latest.copyWith(checkpoints: updated));
    return merged;
  }

  /// 協力プレイの発見者を進捗に反映する (キーはチェックポイントのインデックス)
  ///
  /// 他の人のクリアは「発見者情報つき・自分の写真なし」として反映する。
  void applyCoopDiscoveries(Map<int, CoopDiscovery> discoveries) {
    final current = state.value;
    if (current == null || current.roomCode == null) return;
    var changed = false;
    final updated = List<CheckpointProgress?>.from(current.checkpoints);
    for (final MapEntry(key: index, value: d) in discoveries.entries) {
      if (index < 0 || index >= updated.length) continue;
      final previous = updated[index];
      final next = (previous ?? const CheckpointProgress()).copyWith(
        discovererUid: d.uid,
        discovererNickname: d.nickname,
        discovererThumbPath:
            d.thumbPath ??
            (previous?.discovererUid == d.uid
                ? previous?.discovererThumbPath
                : null),
        achievedAt: d.clearedAt,
      );
      if (next != previous) {
        updated[index] = next;
        changed = true;
      }
    }
    if (changed) {
      state = AsyncValue.data(current.copyWith(checkpoints: updated));
    }
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
