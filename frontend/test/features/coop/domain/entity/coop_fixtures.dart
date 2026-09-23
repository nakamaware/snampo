import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

final createdAt = DateTime.utc(2026, 9, 23, 10);

Room room({
  RoomStatus status = RoomStatus.playing,
  List<String> spotIds = const ['a', 'b', 'c'],
}) => Room(
  code: RoomCode.tryParse('ABCD23')!,
  hostId: 'host',
  status: status,
  settings: RoomSettings.random(radius: Radius(meters: 1000)),
  spotIds: spotIds,
  createdAt: createdAt,
  expiresAt: createdAt.add(Room.playableDuration),
  deleteAt: createdAt.add(Room.retentionDuration),
);

RoomMember member(String uid, {int joinedMinutes = 0, bool left = false}) =>
    RoomMember(
      uid: uid,
      nickname: uid,
      joinedAt: createdAt.add(Duration(minutes: joinedMinutes)),
      leftAt: left ? createdAt.add(const Duration(hours: 1)) : null,
    );

SpotClear clear(String spotId, String uid, {String? thumbPath}) => SpotClear(
  spotId: spotId,
  clearedBy: uid,
  nickname: uid,
  clearedAt: createdAt.add(const Duration(minutes: 30)),
  thumbPath: thumbPath,
);
