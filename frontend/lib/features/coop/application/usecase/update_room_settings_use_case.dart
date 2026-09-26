import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

/// ロビーでホストがミッションの設定を変更する (waiting のとき)
class UpdateRoomSettingsUseCase {
  /// [UpdateRoomSettingsUseCase] を作成する
  UpdateRoomSettingsUseCase(this._rooms);

  final IRoomRepository _rooms;

  /// 変更する
  Future<void> call(RoomCode code, RoomSettings settings) =>
      _rooms.updateSettings(code, settings);
}
