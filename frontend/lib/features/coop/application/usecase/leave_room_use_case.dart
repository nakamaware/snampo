import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';

/// ルームを抜ける (`leftAt` を記録する。ドキュメントは削除しない)
///
/// 削除すると「メンバーか」のチェックに通らなくなり、抜けたあとに履歴の画像を同期できなく
/// なるため。抜けたルームの履歴の同期は続ける。
class LeaveRoomUseCase {
  /// [LeaveRoomUseCase] を作成する
  LeaveRoomUseCase(this._rooms);

  final IRoomRepository _rooms;

  /// 抜ける
  Future<void> call(RoomCode code, String uid) => _rooms.leaveRoom(code, uid);
}
