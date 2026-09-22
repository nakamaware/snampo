import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/clear_thumb.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';

void main() {
  final createdAt = DateTime.utc(2026, 9, 22, 10);

  test('expiresAt は作成から 24 時間', () {
    final room = CoopRoom.open(
      roomCode: RoomCode('123456'),
      hostId: PlayerId('host'),
      hostNickname: Nickname('はな'),
      createdAt: createdAt,
      missionRef: 'rooms/123456/mission/bundle.json',
      spotCount: 3,
    );

    expect(room.expiresAt, createdAt.add(const Duration(hours: 24)));
    expect(room.hostNickname.value, 'はな');
  });

  test('空の missionRef と 0 地点は ArgumentError', () {
    expect(
      () => CoopRoom.open(
        roomCode: RoomCode('123456'),
        hostId: PlayerId('host'),
        hostNickname: Nickname('はな'),
        createdAt: createdAt,
        missionRef: '  ',
        spotCount: 3,
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(
      () => CoopRoom.open(
        roomCode: RoomCode('123456'),
        hostId: PlayerId('host'),
        hostNickname: Nickname('はな'),
        createdAt: createdAt,
        missionRef: 'rooms/123456/mission/bundle.json',
        spotCount: 0,
      ),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('クリアは Storage パスを thumbPath に持つ', () {
    final clear = SpotClear.share(
      thumb: ClearThumb(
        roomCode: RoomCode('123456'),
        spotId: SpotId.fromIndex(0),
      ),
      clearedBy: PlayerId('uid-1'),
      nickname: Nickname('はな'),
      clearedAt: createdAt,
    );

    expect(clear.thumbPath, 'rooms/123456/thumbs/0.jpg');
    expect(clear.nickname.value, 'はな');
  });
}
