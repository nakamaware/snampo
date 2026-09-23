import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/coop/application/usecase/create_room_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../coop_fakes.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 10);
  late FakeRoomRepository rooms;
  late CreateRoomUseCase useCase;

  setUp(() {
    rooms = FakeRoomRepository();
    useCase = CreateRoomUseCase(rooms, random: Random(1), now: () => now);
  });

  test('ホストとしてルームを作成し、自分もメンバーとして入室する', () async {
    final room = await useCase(
      uid: 'host',
      nickname: Nickname.parse('たろう'),
      settings: RoomSettings.random(radius: Radius(meters: 1000)),
    );

    expect(room.hostId, 'host');
    expect(room.status, RoomStatus.waiting);
    expect(room.createdAt, now);
    expect(room.expiresAt, now.add(const Duration(hours: 12)));
    expect(room.deleteAt, now.add(const Duration(days: 7)));
    expect(rooms.rooms[room.code], room);
    expect(rooms.members[room.code]!.single.nickname, 'たろう');
  });

  test('コードが衝突したら作り直して再試行する', () async {
    rooms.collisions = 2;

    final room = await useCase(
      uid: 'host',
      nickname: Nickname.parse('たろう'),
      settings: RoomSettings.random(radius: Radius(meters: 1000)),
    );

    expect(rooms.rooms.keys, [room.code]);
  });

  test('衝突が続いたら諦める', () async {
    rooms.collisions = 100;

    expect(
      () => useCase(
        uid: 'host',
        nickname: Nickname.parse('たろう'),
        settings: RoomSettings.random(radius: Radius(meters: 1000)),
      ),
      throwsStateError,
    );
  });
}
