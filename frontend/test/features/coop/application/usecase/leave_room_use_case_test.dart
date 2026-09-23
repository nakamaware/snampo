import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/leave_room_use_case.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  test('抜けたことを記録し、メンバーのドキュメントは残す', () async {
    final rooms = FakeRoomRepository();
    final room = fx.room();
    rooms.rooms[fx.code] = room;
    await rooms.joinRoom(room, uid: 'me', nickname: 'たろう');

    await LeaveRoomUseCase(rooms)(fx.code, 'me');

    final member = rooms.members[fx.code]!.single;
    expect(member.uid, 'me');
    expect(member.hasLeft, isTrue);
  });
}
