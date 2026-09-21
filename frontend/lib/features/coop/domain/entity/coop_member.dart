import 'package:snampo/features/coop/domain/value_object/player_id.dart';

/// Firestore `rooms/{roomCode}/members/{uid}`。
class CoopMember {
  /// [CoopMember] を作成する。
  const CoopMember({
    required this.playerId,
    required this.joinedAt,
    this.nickname,
  });

  /// メンバーの Auth `uid`。ドキュメント ID と一致させる。
  final PlayerId playerId;

  /// 任意ニックネーム。
  final String? nickname;

  /// 参加時刻。
  final DateTime joinedAt;
}
