import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

/// 全スポットがクリアされていれば、ルームを finished (allCleared) にする
///
/// 書き込みが競合しても結果は同じなので、どの端末が書いてもよい。
class FinishIfAllClearedUseCase {
  /// [FinishIfAllClearedUseCase] を作成する
  FinishIfAllClearedUseCase(this._rooms, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final DateTime Function() _now;

  /// finished にしたら true を返す
  Future<bool> call(Room room, List<SpotClear> clears) async {
    if (room.status != RoomStatus.playing ||
        !room.isPlayable(_now()) ||
        !isAllCleared(room, clears)) {
      return false;
    }
    await _rooms.finish(room.code, FinishReason.allCleared);
    return true;
  }
}
