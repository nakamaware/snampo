import 'dart:async';
import 'dart:developer';

import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/pending_clear_repository.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';

/// ルームを抜ける (`leftAt` を記録する。ドキュメントは削除しない)
///
/// 削除すると「メンバーか」のチェックに通らなくなり、抜けたあとに履歴の画像を同期できなく
/// なるため。抜けたルームの履歴の同期は続ける。
///
/// 抜けたあとはクリアを作成できない (Rules) ので、そのルームのクリアの送り直しは破棄する
/// (作成済みのクリアのサムネの再送は続ける)。
class LeaveRoomUseCase {
  /// [LeaveRoomUseCase] を作成する
  LeaveRoomUseCase(this._rooms, this._queue);

  final IRoomRepository _rooms;
  final IPendingClearRepository _queue;

  /// 抜ける
  ///
  /// `leftAt` の書き込みの完了は待たない (オフラインだとサーバの応答まで返らず、画面が
  /// 止まるため)。送信は SDK が溜めておき、復帰したときに送る。
  Future<void> call(RoomCode code, String uid) async {
    unawaited(
      _rooms.leaveRoom(code, uid).catchError((Object e) {
        log('ルームを抜ける記録に失敗した: $e', name: 'LeaveRoom');
      }),
    );
    await _queue.update((queue) => queue.removeUncreatedClears(code));
  }
}
