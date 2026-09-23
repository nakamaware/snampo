import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

/// Firestore のドキュメントと協力プレイのエンティティの相互変換
class RoomMapper {
  RoomMapper._();

  /// サーバの時刻が未確定 (serverTimestamp の送信待ち) のときは端末の時刻で代用する
  static DateTime _time(Object? value) =>
      value is Timestamp ? value.toDate() : DateTime.now();

  static DateTime? _optionalTime(Object? value) =>
      value is Timestamp ? value.toDate() : null;

  /// [RoomSettings] を Firestore の map にする
  static Map<String, Object?> settingsToFirestore(RoomSettings settings) =>
      switch (settings) {
        RoomSettingsRandom(:final radius) => {
          'mode': 'random',
          'radius': radius.meters,
        },
        RoomSettingsDestination(:final destination) => {
          'mode': 'destination',
          'destination': {
            'lat': destination.latitude,
            'lng': destination.longitude,
          },
        },
      };

  /// Firestore の map を [RoomSettings] にする
  static RoomSettings settingsFromFirestore(Map<String, dynamic> map) {
    if (map['mode'] == 'destination') {
      final destination = map['destination'] as Map<String, dynamic>;
      return RoomSettings.destination(
        destination: Coordinate(
          latitude: (destination['lat'] as num).toDouble(),
          longitude: (destination['lng'] as num).toDouble(),
        ),
      );
    }
    return RoomSettings.random(
      radius: Radius(meters: (map['radius'] as num).toInt()),
    );
  }

  /// 作成時の `rooms/{roomCode}` の中身
  static Map<String, Object?> roomToFirestore(Room room) => {
    'hostId': room.hostId,
    'status': room.status.name,
    'settings': settingsToFirestore(room.settings),
    'createdAt': Timestamp.fromDate(room.createdAt),
    'expiresAt': Timestamp.fromDate(room.expiresAt),
    'deleteAt': Timestamp.fromDate(room.deleteAt),
  };

  /// `rooms/{roomCode}` を [Room] にする
  static Room roomFromFirestore(String code, Map<String, dynamic> data) {
    final roomCode =
        RoomCode.tryParse(code) ?? (throw FormatException('不正なルームコード', code));
    final finishReason = data['finishReason'] as String?;
    return Room(
      code: roomCode,
      hostId: data['hostId'] as String,
      status: RoomStatus.values.byName(data['status'] as String),
      settings: settingsFromFirestore(data['settings'] as Map<String, dynamic>),
      createdAt: _time(data['createdAt']),
      expiresAt: _time(data['expiresAt']),
      deleteAt: _time(data['deleteAt']),
      missionRef: data['missionRef'] as String?,
      spotIds: [
        for (final id in data['spotIds'] as List<dynamic>? ?? const [])
          SpotId.parse(id as String),
      ],
      generationError: data['generationError'] as String?,
      finishReason:
          finishReason == null
              ? null
              : FinishReason.values.byName(finishReason),
      startedAt: _optionalTime(data['startedAt']),
      finishedAt: _optionalTime(data['finishedAt']),
    );
  }

  /// `rooms/{roomCode}/members/{uid}` を [RoomMember] にする
  static RoomMember memberFromFirestore(
    String uid,
    Map<String, dynamic> data,
  ) => RoomMember(
    uid: uid,
    nickname: data['nickname'] as String,
    joinedAt: _time(data['joinedAt']),
    leftAt: _optionalTime(data['leftAt']),
  );

  /// `rooms/{roomCode}/clears/{spotId}` を [SpotClear] にする
  static SpotClear clearFromFirestore(
    String spotId,
    Map<String, dynamic> data,
  ) => SpotClear(
    spotId: SpotId.parse(spotId),
    clearedBy: data['clearedBy'] as String,
    nickname: data['nickname'] as String,
    clearedAt: _time(data['clearedAt']),
    thumbPath: data['thumbPath'] as String,
  );
}
