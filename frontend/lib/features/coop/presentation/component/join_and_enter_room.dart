import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

/// ルームに入り、入れたら端末で参加中のルームとして記録する
///
/// コードの入力と、ホームの「また入る」で使う。通信に失敗すると例外を投げる。
Future<JoinRoomResult> joinAndEnterRoom(
  WidgetRef ref, {
  required RoomCode code,
  required Nickname nickname,
}) async {
  final uid = await ref.read(ensureCoopSignInUseCaseProvider)();
  final result = await ref.read(joinRoomUseCaseProvider)(
    code: code,
    uid: uid,
    nickname: nickname,
  );
  if (result is JoinRoomJoined) {
    ref
        .read(coopSessionStoreProvider.notifier)
        .enter(CoopSession(roomCode: code, uid: uid));
  }
  return result;
}

/// 入室できなかった理由を、利用者に見せる文にする
String joinRoomErrorMessage(JoinRoomError error) => switch (error) {
  JoinRoomError.notFound => 'ルームが見つかりません。コードを確認してください',
  JoinRoomError.expired => 'このルームは期限切れです',
  JoinRoomError.finished => 'このルームは終了しています',
  JoinRoomError.full => 'このルームは満員です (最大 ${Room.maxActiveMembers} 人)',
};

/// 入室の通信に失敗したときの文
const joinRoomNetworkErrorMessage = '入室できませんでした。電波の良い場所で再度お試しください';
