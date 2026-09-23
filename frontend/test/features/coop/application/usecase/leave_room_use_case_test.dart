import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/leave_room_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  late FakeRoomRepository rooms;
  late InMemoryPendingClearRepository queue;

  setUp(() async {
    rooms = FakeRoomRepository();
    queue = InMemoryPendingClearRepository();
    final room = fx.room();
    rooms.rooms[fx.code] = room;
    await rooms.joinRoom(room, uid: 'me', nickname: Nickname.parse('たろう'));
  });

  test('抜けたことを記録し、メンバーのドキュメントは残す', () async {
    await LeaveRoomUseCase(rooms, queue)(fx.code, 'me');
    await pumpEventQueue();

    final member = rooms.members[fx.code]!.single;
    expect(member.uid, 'me');
    expect(member.hasLeft, isTrue);
  });

  test('抜けたルームのクリアの送り直しを破棄し、サムネの再送は残す', () async {
    PendingClearTask task(String spotId) => PendingClearTask(
      roomCode: fx.code,
      spotId: fx.spot(spotId),
      nickname: Nickname.parse('たろう'),
      localThumbPath: '/thumbs/$spotId.jpg',
      expiresAt: fx.createdAt.add(Room.playableDuration),
    );
    queue.queue = PendingClearQueue(
      tasks: [task('a'), task('b').copyWith(clearCreated: true)],
    );

    await LeaveRoomUseCase(rooms, queue)(fx.code, 'me');

    expect(queue.queue.tasks.single.spotId, fx.spot('b'));
  });
}
