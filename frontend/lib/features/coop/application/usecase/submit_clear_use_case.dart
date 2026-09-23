import 'dart:async';
import 'dart:developer';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/usecase/complete_clear_task_use_case.dart';
import 'package:snampo/features/coop/application/usecase/finish_if_all_cleared_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

/// [SubmitClearUseCase] の結果
sealed class SubmitClearResult {
  const SubmitClearResult();
}

/// クリアを作成できた (自分が発見者になった)
final class SubmitClearCreated extends SubmitClearResult {
  /// [SubmitClearCreated] を作成する
  const SubmitClearCreated();
}

/// 先に他の人がクリアしていた
final class SubmitClearAlreadyExists extends SubmitClearResult {
  /// [SubmitClearAlreadyExists] を作成する
  const SubmitClearAlreadyExists(this.existing);

  /// 先に作成されていたクリア
  final SpotClear existing;
}

/// クリアの送信が時間内に終わらなかった (オフラインなど。キューに残す)
final class SubmitClearTimedOut extends SubmitClearResult {
  /// [SubmitClearTimedOut] を作成する
  const SubmitClearTimedOut();
}

/// キューに積んだ発見について、サムネを上げてクリアを作成する
///
/// 最初の撮影と送り直しで共通の手順。
/// 1. サムネをアップロードする。[thumbUploadTimeout] 以内に終わらなければ打ち切る
///    (発見の同期を優先する)
/// 2. クリアを作成する (thumbPath はアップロードできたときだけ入れる)
/// 3. 作成できたらキューを片付け (サムネが入っていなければ再送だけを残す)、
///    最後のクリアなら finished にする。先に他の人がクリアしていたらキューから取り除く
///
/// Rules に拒否されたら [CoopPermissionDeniedException] をそのまま投げる。
class SubmitClearUseCase {
  /// [SubmitClearUseCase] を作成する
  SubmitClearUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required IPendingClearRepository queue,
    required CompleteClearTaskUseCase completeClearTask,
    required FinishIfAllClearedUseCase finishIfAllCleared,
    this.thumbUploadTimeout = const Duration(seconds: 15),
  }) : _rooms = rooms,
       _storage = storage,
       _queue = queue,
       _completeClearTask = completeClearTask,
       _finishIfAllCleared = finishIfAllCleared;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final IPendingClearRepository _queue;
  final CompleteClearTaskUseCase _completeClearTask;
  final FinishIfAllClearedUseCase _finishIfAllCleared;

  /// サムネのアップロードを待つ時間
  final Duration thumbUploadTimeout;

  /// 送信する
  ///
  /// [onThumbDone] はサムネのアップロードが終わるか打ち切ったときに呼ぶ。
  /// [createClearTimeout] を指定すると、クリアの送信をその時間で打ち切る (指定しなければ、
  /// オフラインの間は SDK が溜めておき、復帰して送信できるまで待つ)。
  Future<SubmitClearResult> call(
    Room room,
    PendingClearTask task, {
    required String uid,
    void Function()? onThumbDone,
    Duration? createClearTimeout,
  }) async {
    String? thumbPath;
    try {
      thumbPath = await _storage
          .uploadThumb(
            code: room.code,
            spotId: task.spotId,
            uid: uid,
            localPath: task.localThumbPath,
          )
          .timeout(thumbUploadTimeout);
    } on Object catch (e) {
      log('サムネのアップロードが間に合わなかった: $e', name: 'SubmitClear');
    } finally {
      onThumbDone?.call();
    }

    final CreateClearResult result;
    try {
      final create = _rooms.createClear(
        room,
        spotId: task.spotId,
        uid: uid,
        nickname: task.nickname,
        thumbPath: thumbPath,
      );
      result =
          await (createClearTimeout == null
              ? create
              : create.timeout(createClearTimeout));
    } on TimeoutException {
      return const SubmitClearTimedOut();
    }

    switch (result) {
      case ClearCreated():
        await _completeClearTask(task, result: result, thumbPath: thumbPath);
        try {
          // 画面でルームを監視していなくても、最後のクリアを書いた端末が finished にする
          await _finishIfAllCleared(room, await _rooms.fetchClears(room.code));
        } on Object catch (e) {
          log('finished への更新に失敗した: $e', name: 'SubmitClear');
        }
        return const SubmitClearCreated();
      case ClearAlreadyExists(:final existing):
        await _queue.update((queue) => queue.remove(task));
        return SubmitClearAlreadyExists(existing);
    }
  }
}
