import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/storage/mission_photo_directory.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

part 'mission_progress_store.g.dart';

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

  @override
  String get key => kind.persistKey('MissionProgressStoreNotifier');

  /// ミッション進捗を開始する
  ///
  /// [checkpointCount] はチェックポイントの数（waypoints + destination）
  /// [roomCode] は協力プレイのルームコード (ソロでは null)
  void startProgress(int checkpointCount, {RoomCode? roomCode}) {
    state = AsyncValue.data(
      MissionProgressEntity(
        startedAt: DateTime.now(),
        roomCode: roomCode,
        checkpoints: List.filled(checkpointCount, null),
      ),
    );
  }

  /// 前の進捗 (保存した写真を含む) を片付けて、新しいミッションの進捗を始める
  ///
  /// build() の完了を待ってから書き換える。build() と並行すると、build() の返り値 (null) が
  /// あとから適用されて、始めた進捗を上書きするため。
  Future<void> restartProgress(
    int checkpointCount, {
    RoomCode? roomCode,
  }) async {
    await future;
    await clearProgress();
    startProgress(checkpointCount, roomCode: roomCode);
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
      photoDirectory: MissionPhotoDirectory.of(roomCode: current.roomCode),
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

  /// [index] の撮影の記録 (自分の写真と採点) を捨てる (写真のファイルも消す)
  ///
  /// 協力プレイで発見を共有できなかったとき、誰もクリアしていない扱いに戻すために使う。
  Future<void> discardCapture(int index) async {
    final current = state.value;
    if (current == null || index < 0 || index >= current.checkpoints.length) {
      return;
    }
    final photoPath = current.checkpoints[index]?.userPhotoPath;
    state = AsyncValue.data(current.withoutCapture(index));
    if (photoPath != null) {
      try {
        await ref.read(photoStorageProvider).deletePhoto(photoPath);
      } on Object {
        // 消せなくても、進捗からは捨ててあるので続ける
      }
    }
  }

  /// 協力プレイの発見者を進捗に反映する (キーはチェックポイントのインデックス)
  ///
  /// [roomCode] がこの進捗のルームと違えば何もしない。
  void applyCoopDiscoveries(
    RoomCode roomCode,
    Map<int, CoopDiscovery> discoveries,
  ) {
    final current = state.value;
    if (current == null) return;
    final next = current.withCoopDiscoveries(roomCode, discoveries);
    if (!identical(next, current)) {
      state = AsyncValue.data(next);
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
