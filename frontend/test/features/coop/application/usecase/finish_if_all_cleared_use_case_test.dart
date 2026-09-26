import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/finish_if_all_cleared_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  late FakeRoomRepository rooms;

  setUp(() => rooms = FakeRoomRepository());

  FinishIfAllClearedUseCase useCase({Duration elapsed = Duration.zero}) =>
      FinishIfAllClearedUseCase(rooms, now: () => fx.createdAt.add(elapsed));

  test('全スポットがクリアされたら finished (allCleared) にする', () async {
    final room = fx.room(spotIds: ['a', 'b']);
    rooms.rooms[fx.code] = room;

    final finished = await useCase()(room, [
      fx.clear('a', 'x'),
      fx.clear('b', 'y'),
    ]);

    expect(finished, isTrue);
    expect(rooms.rooms[fx.code]!.finishReason, FinishReason.allCleared);
  });

  test('まだクリアされていないスポットがあれば何もしない', () async {
    final room = fx.room(spotIds: ['a', 'b']);
    rooms.rooms[fx.code] = room;

    expect(await useCase()(room, [fx.clear('a', 'x')]), isFalse);
    expect(rooms.rooms[fx.code]!.status, RoomStatus.playing);
  });

  test('playing でなければ、または遊べる期限を過ぎていれば何もしない', () async {
    final finished = fx.room(status: RoomStatus.finished, spotIds: ['a']);

    expect(await useCase()(finished, [fx.clear('a', 'x')]), isFalse);
    expect(
      await useCase(elapsed: const Duration(hours: 13))(
        fx.room(spotIds: ['a']),
        [fx.clear('a', 'x')],
      ),
      isFalse,
    );
  });
}
