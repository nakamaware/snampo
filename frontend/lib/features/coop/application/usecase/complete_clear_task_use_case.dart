import 'dart:developer';

import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

/// クリアを作成できたあと、共有しきれていない発見のキューを片付ける
///
/// 送信待ちだった自分のクリア (キルされる前の書き込み) が先に届いていた場合は、サーバのクリアに
/// 今回の thumbPath が入っていないので、ここで後から埋める。thumbPath まで入れば取り除き、
/// まだならサムネの再送だけを残す。
class CompleteClearTaskUseCase {
  /// [CompleteClearTaskUseCase] を作成する
  CompleteClearTaskUseCase({
    required IRoomRepository rooms,
    required IPendingClearRepository queue,
  }) : _rooms = rooms,
       _queue = queue;

  final IRoomRepository _rooms;
  final IPendingClearRepository _queue;

  /// 片付ける
  ///
  /// [thumbPath] は今回アップロードできたサムネのパス (できなければ null)。
  Future<void> call(
    PendingClearTask task, {
    required ClearCreated result,
    required String? thumbPath,
  }) async {
    var thumbPathSaved = result.thumbPathSaved;
    if (!thumbPathSaved && thumbPath != null) {
      try {
        await _rooms.fillThumbPath(task.roomCode, task.spotId, thumbPath);
        thumbPathSaved = true;
      } on Object catch (e) {
        // 次の送り直しでサムネから再送する
        log('thumbPath を埋められなかった: $e', name: 'CompleteClearTask');
      }
    }
    await _queue.update(
      (queue) => queue.settle(task, thumbPathSaved: thumbPathSaved),
    );
  }
}
