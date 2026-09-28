import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/usecase/update_my_nickname_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  late FakeRoomRepository rooms;

  setUp(() async {
    rooms = FakeRoomRepository();
    final room = fx.room(status: RoomStatus.waiting);
    rooms.rooms[fx.code] = room;
    await rooms.joinRoom(room, uid: 'me', nickname: Nickname.parse('たろう'));
  });

  test('ロビーで自分のニックネームを変える', () async {
    await UpdateMyNicknameUseCase(rooms)(
      fx.code,
      uid: 'me',
      nickname: Nickname.parse('はなこ'),
    );

    expect(rooms.members[fx.code]!.single.nickname, 'はなこ');
  });

  test('開始後は変えられない', () async {
    rooms.rooms[fx.code] = rooms.rooms[fx.code]!.copyWith(
      status: RoomStatus.generating,
    );

    await expectLater(
      UpdateMyNicknameUseCase(rooms)(
        fx.code,
        uid: 'me',
        nickname: Nickname.parse('はなこ'),
      ),
      throwsA(isA<CoopPermissionDeniedException>()),
    );
    expect(rooms.members[fx.code]!.single.nickname, 'たろう');
  });
}
