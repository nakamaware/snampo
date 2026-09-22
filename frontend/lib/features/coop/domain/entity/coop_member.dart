import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';

/// Firestore `rooms/{roomCode}/members/{uid}`。
class CoopMember {
  /// 参加時に [nickname] を指定して [CoopMember] を作る。
  const CoopMember({
    required this.playerId,
    required this.nickname,
    required this.joinedAt,
  });

  /// メンバーの Auth `uid`。ドキュメント ID と一致させる。
  final PlayerId playerId;

  /// 参加時に指定したニックネーム。
  final Nickname nickname;

  /// 参加時刻。
  final DateTime joinedAt;
}
