import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';

/// ロビーで自分のニックネームを変える (waiting のとき)
///
/// オフラインなら例外を投げる。開始後は [CoopPermissionDeniedException] を投げる。
class UpdateMyNicknameUseCase {
  /// [UpdateMyNicknameUseCase] を作成する
  UpdateMyNicknameUseCase(this._rooms);

  final IRoomRepository _rooms;

  /// ロビーで自分 ([uid]) のニックネームを [nickname] に変える
  Future<void> call(
    RoomCode code, {
    required String uid,
    required Nickname nickname,
  }) => _rooms.updateNickname(code, uid: uid, nickname: nickname);
}
