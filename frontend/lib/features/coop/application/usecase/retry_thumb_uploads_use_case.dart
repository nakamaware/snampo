import 'dart:developer';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/interface/thumb_upload_queue_store.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

/// 再送キューに積んだサムネを再送し、成功したら thumbPath を後から埋める
///
/// 次のネットワーク復帰、アプリの復帰、起動のタイミングで呼ぶ。再送するのは遊べる期限まで。
class RetryThumbUploadsUseCase {
  /// [RetryThumbUploadsUseCase] を作成する
  RetryThumbUploadsUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required IThumbUploadQueueStore queue,
    required Future<String?> Function() uid,
    DateTime Function()? now,
  }) : _rooms = rooms,
       _storage = storage,
       _queue = queue,
       _uid = uid,
       _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final IThumbUploadQueueStore _queue;

  /// サインイン済みならその uid (未サインインなら null。ここではサインインを試さない)
  final Future<String?> Function() _uid;
  final DateTime Function() _now;

  Future<void>? _running;

  /// 再送する (実行中に呼ばれたら、実行中の処理を待つ)
  Future<void> call() =>
      _running ??= _run().whenComplete(() => _running = null);

  Future<void> _run() async {
    final queue = (await _queue.load()).pruneExpired(_now());
    await _queue.save(queue);
    if (queue.tasks.isEmpty) {
      return;
    }
    final uid = await _uid();
    if (uid == null) {
      return;
    }
    for (final task in queue.tasks) {
      final code = RoomCode.tryParse(task.roomCode);
      if (code == null) {
        await _queue.save((await _queue.load()).remove(task));
        continue;
      }
      try {
        final thumbPath = await _storage.uploadThumb(
          code: code,
          spotId: SpotId.parse(task.spotId),
          uid: uid,
          localPath: task.localPath,
        );
        await _rooms.fillThumbPath(code, task.spotId, thumbPath);
        await _queue.save((await _queue.load()).remove(task));
      } on CoopPermissionDeniedException catch (e) {
        // 自分が発見者でない、既に埋まっている、期限切れなど。再送しても通らないので破棄する
        log('サムネの再送が拒否されたため破棄する: $e', name: 'RetryThumbUploads');
        await _queue.save((await _queue.load()).remove(task));
      } on Object catch (e) {
        log('サムネの再送に失敗した: $e', name: 'RetryThumbUploads');
      }
    }
  }
}
