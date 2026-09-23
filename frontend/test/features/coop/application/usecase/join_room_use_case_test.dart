import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final code = RoomCode.tryParse('ABCD23')!;
  final now = fx.createdAt.add(const Duration(hours: 1));
  late FakeRoomRepository rooms;
  late JoinRoomUseCase useCase;

  setUp(() {
    rooms = FakeRoomRepository()..now = now;
    useCase = JoinRoomUseCase(rooms, now: () => now);
  });

  test('存在しないコードなら notFound', () async {
    final result = await useCase(code: code, uid: 'u', nickname: 'たろう');

    expect(result, const JoinRoomFailed(JoinRoomError.notFound));
  });

  test('期限切れのルームなら expired', () async {
    rooms.rooms[code] = fx.room(status: RoomStatus.waiting);
    useCase = JoinRoomUseCase(
      rooms,
      now: () => fx.createdAt.add(const Duration(hours: 13)),
    );

    final result = await useCase(code: code, uid: 'u', nickname: 'たろう');

    expect(result, const JoinRoomFailed(JoinRoomError.expired));
  });

  test('入室できたらルームを返す', () async {
    final room = fx.room();
    rooms.rooms[code] = room;

    final result = await useCase(code: code, uid: 'u', nickname: 'たろう');

    expect(result, JoinRoomJoined(room));
    expect(rooms.members[code]!.single.uid, 'u');
  });

  test('満員なら抜けたことにして full を返す', () async {
    rooms.rooms[code] = fx.room(status: RoomStatus.waiting);
    for (var i = 0; i < 8; i++) {
      await rooms.joinRoom(rooms.rooms[code]!, uid: 'u$i', nickname: 'p$i');
    }

    final result = await useCase(code: code, uid: 'late', nickname: 'おそい');

    expect(result, const JoinRoomFailed(JoinRoomError.full));
    final late = rooms.members[code]!.firstWhere((m) => m.uid == 'late');
    expect(late.hasLeft, isTrue);
  });

  test('抜けたメンバーは同じ uid で戻れる', () async {
    final room = fx.room();
    rooms.rooms[code] = room;
    await useCase(code: code, uid: 'u', nickname: 'たろう');
    await rooms.leaveRoom(code, 'u');

    final result = await useCase(code: code, uid: 'u', nickname: 'たろう');

    expect(result, JoinRoomJoined(room));
    expect(rooms.members[code]!.single.hasLeft, isFalse);
  });

  test('入室が早かった人が抜けて入り直しても、満員なら入れない', () async {
    final room = fx.room(status: RoomStatus.waiting);
    rooms.rooms[code] = room;
    await useCase(code: code, uid: 'early', nickname: 'はやい');
    await rooms.leaveRoom(code, 'early');
    for (var i = 0; i < 8; i++) {
      await rooms.joinRoom(room, uid: 'u$i', nickname: 'p$i');
    }

    final result = await useCase(code: code, uid: 'early', nickname: 'はやい');

    expect(result, const JoinRoomFailed(JoinRoomError.full));
  });
}
