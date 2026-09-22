import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// ルームの寿命。作成時刻から 24 時間。
const coopRoomLifetime = Duration(hours: 24);

/// Firestore `rooms/{roomCode}`。
class CoopRoom {
  /// ホストがルームを開く。[expiresAt] は [createdAt] の 24 時間後。
  factory CoopRoom.open({
    required RoomCode roomCode,
    required PlayerId hostId,
    required Nickname hostNickname,
    required DateTime createdAt,
    required String missionRef,
    required int spotCount,
  }) {
    final ref = missionRef.trim();
    if (ref.isEmpty) {
      throw ArgumentError.value(
        missionRef,
        'missionRef',
        'missionRef は空にできません',
      );
    }
    if (spotCount <= 0) {
      throw ArgumentError.value(spotCount, 'spotCount', 'spotCount は 1 以上です');
    }
    return CoopRoom._(
      roomCode: roomCode,
      hostId: hostId,
      hostNickname: hostNickname,
      createdAt: createdAt,
      expiresAt: createdAt.add(coopRoomLifetime),
      missionRef: ref,
      spotCount: spotCount,
    );
  }

  const CoopRoom._({
    required this.roomCode,
    required this.hostId,
    required this.hostNickname,
    required this.createdAt,
    required this.expiresAt,
    required this.missionRef,
    required this.spotCount,
  });

  /// ルームコード。
  final RoomCode roomCode;

  /// ホストの Auth `uid`。
  final PlayerId hostId;

  /// ホストのニックネーム。
  final Nickname hostNickname;

  /// 作成時刻。
  final DateTime createdAt;

  /// 期限。Rules と Firestore TTL がこのフィールドを見る。
  final DateTime expiresAt;

  /// Cloud Storage 上のミッションパス。
  final String missionRef;

  /// 地点数 (`waypoints + destination`)。
  final int spotCount;
}
