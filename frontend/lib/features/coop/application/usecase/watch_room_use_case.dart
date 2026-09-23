import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

/// ルームとメンバー、クリアを監視する
class WatchRoomUseCase {
  /// [WatchRoomUseCase] を作成する
  WatchRoomUseCase(this._rooms);

  final IRoomRepository _rooms;

  /// ルームを監視する (消えたら null)
  Stream<Room?> room(RoomCode code) => _rooms.watchRoom(code);

  /// メンバーを監視する (入室順)
  Stream<List<RoomMember>> members(RoomCode code) => _rooms.watchMembers(code);

  /// クリアを監視する
  Stream<List<SpotClear>> clears(RoomCode code) => _rooms.watchClears(code);
}
