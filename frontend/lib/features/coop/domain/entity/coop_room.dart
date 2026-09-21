import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// Firestore `rooms/{roomCode}`。
class CoopRoom {
  /// [CoopRoom] を作成する。
  const CoopRoom({
    required this.roomCode,
    required this.hostId,
    required this.createdAt,
    required this.expiresAt,
    required this.missionRef,
    required this.spotCount,
    this.hostNickname,
  });

  /// ルームコード。
  final RoomCode roomCode;

  /// ホストの Auth `uid`。
  final PlayerId hostId;

  /// ホストの任意ニックネーム。
  final String? hostNickname;

  /// 作成時刻。
  final DateTime createdAt;

  /// 期限。Rules がこの時刻以降を拒否する。
  final DateTime expiresAt;

  /// Cloud Storage 上のミッションパス。
  final String missionRef;

  /// 地点数 (`waypoints + destination`)。
  final int spotCount;
}
