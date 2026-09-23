import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// 入室の結果
@immutable
sealed class JoinRoomResult {
  const JoinRoomResult();
}

/// 入室できた
final class JoinRoomJoined extends JoinRoomResult {
  /// [JoinRoomJoined] を作成する
  const JoinRoomJoined(this.room);

  /// 入室したルーム
  final Room room;

  @override
  bool operator ==(Object other) =>
      other is JoinRoomJoined && other.room == room;

  @override
  int get hashCode => room.hashCode;
}

/// 入室できなかった
final class JoinRoomFailed extends JoinRoomResult {
  /// [JoinRoomFailed] を作成する
  const JoinRoomFailed(this.error);

  /// 理由
  final JoinRoomError error;

  @override
  bool operator ==(Object other) =>
      other is JoinRoomFailed && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

/// ルームに入室する (途中参加と、同じ uid での復帰を含む)
class JoinRoomUseCase {
  /// [JoinRoomUseCase] を作成する
  JoinRoomUseCase(this._rooms, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final DateTime Function() _now;

  /// 入室する
  ///
  /// 人数の上限は Rules では強制しないため、入室してからメンバーを読み、
  /// 上限を超えていたら抜けたことにして [JoinRoomError.full] を返す。
  Future<JoinRoomResult> call({
    required RoomCode code,
    required String uid,
    required String nickname,
  }) async {
    final room = await _rooms.fetchRoom(code);
    final error = checkJoinable(room, _now());
    if (error != null) {
      return JoinRoomFailed(error);
    }
    await _rooms.joinRoom(room!, uid: uid, nickname: nickname);
    final members = await _rooms.fetchMembers(code);
    if (!isWithinCapacity(members, uid)) {
      await _rooms.leaveRoom(code, uid);
      return const JoinRoomFailed(JoinRoomError.full);
    }
    return JoinRoomJoined(room);
  }
}
