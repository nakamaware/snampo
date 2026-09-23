import 'dart:developer';

import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/application/usecase/submit_clear_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// スポットのクリアの結果
sealed class ClearSpotResult {
  const ClearSpotResult();
}

/// 自分が発見者になった
final class ClearSpotCleared extends ClearSpotResult {
  /// [ClearSpotCleared] を作成する
  const ClearSpotCleared();
}

/// 先に他の人が発見していた (自分の写真と採点は手元に残す)
final class ClearSpotAlreadyCleared extends ClearSpotResult {
  /// [ClearSpotAlreadyCleared] を作成する
  const ClearSpotAlreadyCleared(this.existing);

  /// 先に作成されていたクリア
  final SpotClear existing;
}

/// Rules に拒否された (ルームが終わったあと、遊べる期限を過ぎたなど)。送り直しても通らない
final class ClearSpotRejected extends ClearSpotResult {
  /// [ClearSpotRejected] を作成する
  const ClearSpotRejected();
}

/// 撮影して採点したスポットをクリアにする (1 人のクリアで全員のクリアになる)
///
/// 1. 自分の写真と採点を履歴に残す (先に他の人が発見していても手元に残す)
/// 2. サムネを作り、発見をキューに積む (途中でキルされても、次の起動で作り直せるように)
/// 3. サムネを上げてクリアを作成する ([SubmitClearUseCase]。サムネは 15 秒で打ち切る)
/// 4. 自分が発見者になったら、履歴に発見者と自分のサムネを反映する
class ClearSpotUseCase {
  /// [ClearSpotUseCase] を作成する
  ClearSpotUseCase({
    required IThumbnailService thumbnails,
    required IPendingClearRepository queue,
    required IHistoryRepository histories,
    required SubmitClearUseCase submitClear,
    DateTime Function()? now,
  }) : _thumbnails = thumbnails,
       _queue = queue,
       _histories = histories,
       _submitClear = submitClear,
       _now = now ?? DateTime.now;

  final IThumbnailService _thumbnails;
  final IPendingClearRepository _queue;
  final IHistoryRepository _histories;
  final SubmitClearUseCase _submitClear;
  final DateTime Function() _now;

  /// クリアにする
  ///
  /// [onSharing] はサムネの共有を始めたとき、[onSharingDone] はサムネのアップロードが
  /// 終わるかタイムアウトしたときに呼ぶ (「発見を共有中…」の表示用)。クリアの送信は
  /// オフラインなら復帰まで完了しないため、表示はそれを待たずに終える。
  Future<ClearSpotResult> call({
    required Room room,
    required String uid,
    required Nickname nickname,
    required SpotId spotId,
    required CheckpointProgress checkpoint,
    void Function()? onSharing,
    void Function()? onSharingDone,
  }) async {
    final photoPath =
        checkpoint.userPhotoPath ?? (throw ArgumentError('写真がありません'));
    try {
      await _histories.saveCoopUserPhoto(
        roomCode: room.code,
        spotId: spotId,
        checkpoint: checkpoint,
      );
    } on Object catch (e) {
      log('履歴への写真の保存に失敗した: $e', name: 'ClearSpot');
    }

    final localThumbPath = await _thumbnails.createThumbnail(photoPath);
    final task = PendingClearTask(
      roomCode: room.code,
      spotId: spotId,
      nickname: nickname,
      localThumbPath: localThumbPath,
      expiresAt: room.expiresAt,
    );
    await _queue.update((queue) => queue.enqueue(task));
    onSharing?.call();

    final SubmitClearResult result;
    try {
      result = await _submitClear(
        room,
        task,
        uid: uid,
        onThumbDone: onSharingDone,
      );
    } on CoopPermissionDeniedException {
      await _queue.update((queue) => queue.remove(task));
      return const ClearSpotRejected();
    }
    switch (result) {
      case SubmitClearCreated():
        await _histories.applyCoopDiscoverer(
          roomCode: room.code,
          spotId: spotId,
          discovererUid: uid,
          discovererNickname: nickname.value,
          clearedAt: checkpoint.achievedAt ?? _now(),
        );
        await _histories.saveCoopThumb(
          roomCode: room.code,
          spotId: spotId,
          sourcePath: localThumbPath,
        );
        return const ClearSpotCleared();
      case SubmitClearAlreadyExists(:final existing):
        return ClearSpotAlreadyCleared(existing);
    }
  }
}
