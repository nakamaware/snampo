import 'dart:async';
import 'dart:developer';

import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumbnail_service.dart';
import 'package:snampo/features/coop/application/usecase/complete_clear_task_use_case.dart';
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

/// 撮影して採点したスポットをクリアにする (1 人のクリアで全員のクリアになる)
///
/// 1. 自分の写真と採点を履歴に残す (先に他の人が発見していても手元に残す)
/// 2. サムネを作り、発見をキューに積む (途中でキルされても、次の起動で作り直せるように)
/// 3. サムネをアップロードする
/// 4. 終わったら thumbPath を入れてクリアを作成し、キューを片付ける
/// 5. [thumbUploadTimeout] 以内に終わらなければ、thumbPath なしでクリアを先に作成する
///    (発見の同期を優先する)。キューにはサムネの再送だけを残す
/// 6. 自分が発見者になったら、履歴に発見者と自分のサムネを反映する
class ClearSpotUseCase {
  /// [ClearSpotUseCase] を作成する
  ClearSpotUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required IThumbnailService thumbnails,
    required IPendingClearRepository queue,
    required IHistoryRepository histories,
    required CompleteClearTaskUseCase completeClearTask,
    this.thumbUploadTimeout = const Duration(seconds: 15),
    DateTime Function()? now,
  }) : _rooms = rooms,
       _storage = storage,
       _thumbnails = thumbnails,
       _queue = queue,
       _histories = histories,
       _completeClearTask = completeClearTask,
       _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final IThumbnailService _thumbnails;
  final IPendingClearRepository _queue;
  final IHistoryRepository _histories;
  final CompleteClearTaskUseCase _completeClearTask;
  final DateTime Function() _now;

  /// サムネのアップロードを待つ時間
  final Duration thumbUploadTimeout;

  /// クリアにする
  ///
  /// [onSharing] はサムネの共有を始めたとき、[onSharingDone] はサムネのアップロードが
  /// 終わるかタイムアウトしたときに呼ぶ (「発見を共有中…」の表示用)。クリアの送信は
  /// オフラインなら復帰まで完了しないため、表示はそれを待たずに終える。
  Future<ClearSpotResult> call({
    required Room room,
    required String uid,
    required String nickname,
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
      log('履歴への写真の保存に失敗した: $e', name: 'ClearSpotUseCase');
    }

    final localThumbPath = await _thumbnails.createThumbnail(photoPath);
    final task = PendingClearTask(
      roomCode: room.code,
      spotId: spotId,
      nickname: nickname,
      localThumbPath: localThumbPath,
      expiresAt: room.expiresAt,
    );
    await _queue.save((await _queue.load()).enqueue(task));
    onSharing?.call();

    String? thumbPath;
    try {
      thumbPath = await _storage
          .uploadThumb(
            code: room.code,
            spotId: spotId,
            uid: uid,
            localPath: localThumbPath,
          )
          .timeout(thumbUploadTimeout);
    } on Object catch (e) {
      log('サムネのアップロードが間に合わなかった: $e', name: 'ClearSpotUseCase');
    } finally {
      onSharingDone?.call();
    }

    final result = await _rooms.createClear(
      room,
      spotId: spotId,
      uid: uid,
      nickname: nickname,
      thumbPath: thumbPath,
    );
    switch (result) {
      case ClearCreated():
        await _completeClearTask(task, result: result, thumbPath: thumbPath);
        await _histories.applyCoopDiscoverer(
          roomCode: room.code,
          spotId: spotId,
          discovererUid: uid,
          discovererNickname: nickname,
          clearedAt: checkpoint.achievedAt ?? _now(),
        );
        await _histories.saveCoopThumb(
          roomCode: room.code,
          spotId: spotId,
          sourcePath: localThumbPath,
        );
        return const ClearSpotCleared();
      case ClearAlreadyExists(:final existing):
        await _queue.save((await _queue.load()).remove(task));
        return ClearSpotAlreadyCleared(existing);
    }
  }
}
