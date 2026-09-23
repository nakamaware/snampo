import 'dart:async';
import 'dart:developer';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_queue_store.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

/// 発見を共有できなかった理由
enum PendingClearFailureReason {
  /// 先に他の人が発見していた
  alreadyCleared,

  /// ルームが終わっていた (finished か、消えていた)
  roomClosed,
}

/// 共有できなかった発見
typedef PendingClearFailure =
    ({
      PendingClearTask task,
      PendingClearFailureReason reason,

      /// 先に作成されていたクリア ([PendingClearFailureReason.alreadyCleared] のとき)
      SpotClear? existing,
    });

/// [RetryPendingClearsUseCase] の結果
typedef RetryPendingClearsResult = ({List<PendingClearFailure> failures});

/// 共有しきれていない発見を送り直す
///
/// - クリアを作成していないタスク (作成の前にキルされたなど): サムネを上げてクリアを作り直す。
///   先に他の人が発見していた場合やルームが終わっていた場合は、共有できなかった発見として返す
/// - クリアを作成済みのタスク: サムネを再送し、成功したら thumbPath を後から埋める
///
/// 次のネットワーク復帰、アプリの復帰、起動のタイミングで呼ぶ。再送するのは遊べる期限まで。
class RetryPendingClearsUseCase {
  /// [RetryPendingClearsUseCase] を作成する
  RetryPendingClearsUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required IPendingClearQueueStore queue,
    required Future<String?> Function() uid,
    DateTime Function()? now,
    this.createClearTimeout = const Duration(seconds: 30),
  }) : _rooms = rooms,
       _storage = storage,
       _queue = queue,
       _uid = uid,
       _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final IPendingClearQueueStore _queue;

  /// サインイン済みならその uid (未サインインなら null。ここではサインインを試さない)
  final Future<String?> Function() _uid;
  final DateTime Function() _now;

  /// クリアの送信を待つ時間 (オフラインなら SDK が溜めておき、次の機会にまた送る)
  final Duration createClearTimeout;

  Future<RetryPendingClearsResult>? _running;

  /// 送り直す (実行中に呼ばれたら、実行中の処理を待つ)
  Future<RetryPendingClearsResult> call() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<RetryPendingClearsResult> _run() async {
    final queue = (await _queue.load()).pruneExpired(_now());
    await _queue.save(queue);
    final failures = <PendingClearFailure>[];
    if (queue.tasks.isEmpty) {
      return (failures: failures);
    }
    final uid = await _uid();
    if (uid == null) {
      return (failures: failures);
    }
    for (final task in queue.tasks) {
      final code = RoomCode.tryParse(task.roomCode);
      if (code == null) {
        await _remove(task);
        continue;
      }
      try {
        final failure =
            task.clearCreated
                ? await _retryThumb(code, task, uid)
                : await _retryClear(code, task, uid);
        if (failure != null) {
          failures.add(failure);
        }
      } on CoopPermissionDeniedException catch (e) {
        // 自分が発見者でない、既に埋まっている、期限切れなど。送り直しても通らないので破棄する
        log('発見の送り直しが拒否されたため破棄する: $e', name: 'RetryPendingClears');
        await _remove(task);
      } on Object catch (e) {
        log('発見の送り直しに失敗した: $e', name: 'RetryPendingClears');
      }
    }
    return (failures: failures);
  }

  Future<String?> _uploadThumb(
    RoomCode code,
    PendingClearTask task,
    String uid,
  ) async {
    try {
      return await _storage.uploadThumb(
        code: code,
        spotId: SpotId.parse(task.spotId),
        uid: uid,
        localPath: task.localThumbPath,
      );
    } on Object catch (e) {
      log('サムネの再送に失敗した: $e', name: 'RetryPendingClears');
      return null;
    }
  }

  Future<PendingClearFailure?> _retryClear(
    RoomCode code,
    PendingClearTask task,
    String uid,
  ) async {
    final room = await _rooms.fetchRoom(code);
    if (room == null ||
        room.status != RoomStatus.playing ||
        !room.isPlayable(_now())) {
      await _remove(task);
      return (
        task: task,
        reason: PendingClearFailureReason.roomClosed,
        existing: null,
      );
    }
    final thumbPath = await _uploadThumb(code, task, uid);
    final CreateClearResult result;
    try {
      result = await _rooms
          .createClear(
            room,
            spotId: task.spotId,
            uid: uid,
            nickname: task.nickname,
            thumbPath: thumbPath,
          )
          .timeout(createClearTimeout);
    } on TimeoutException {
      // オフラインなど。キューに残して次の機会に送り直す
      return null;
    }
    switch (result) {
      case ClearCreated():
        final queue = await _queue.load();
        await _queue.save(
          thumbPath == null ? queue.markClearCreated(task) : queue.remove(task),
        );
        return null;
      case ClearAlreadyExists(:final existing):
        await _remove(task);
        return (
          task: task,
          reason: PendingClearFailureReason.alreadyCleared,
          existing: existing,
        );
    }
  }

  Future<PendingClearFailure?> _retryThumb(
    RoomCode code,
    PendingClearTask task,
    String uid,
  ) async {
    final thumbPath = await _uploadThumb(code, task, uid);
    if (thumbPath == null) {
      return null;
    }
    await _rooms.fillThumbPath(code, task.spotId, thumbPath);
    await _remove(task);
    return null;
  }

  Future<void> _remove(PendingClearTask task) async =>
      _queue.save((await _queue.load()).remove(task));
}
