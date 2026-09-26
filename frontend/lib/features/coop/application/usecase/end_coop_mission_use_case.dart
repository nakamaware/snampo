import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

/// ホストがミッションを途中終了する (playing → finished)
class EndCoopMissionUseCase {
  /// [EndCoopMissionUseCase] を作成する
  EndCoopMissionUseCase(this._rooms);

  final IRoomRepository _rooms;

  /// 途中終了する
  Future<void> call(RoomCode code) =>
      _rooms.finish(code, FinishReason.hostEnded);
}
