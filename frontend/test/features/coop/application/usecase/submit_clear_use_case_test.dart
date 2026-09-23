import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/complete_clear_task_use_case.dart';
import 'package:snampo/features/coop/application/usecase/finish_if_all_cleared_use_case.dart';
import 'package:snampo/features/coop/application/usecase/submit_clear_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryPendingClearRepository queue;
  late SubmitClearUseCase useCase;
  late Room room;
  final task = PendingClearTask(
    roomCode: fx.code,
    spotId: fx.spot('a'),
    nickname: Nickname.parse('me'),
    localThumbPath: '/thumbs/a.jpg',
    expiresAt: fx.createdAt.add(Room.playableDuration),
  );

  setUp(() {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    queue =
        InMemoryPendingClearRepository()
          ..queue = PendingClearQueue(tasks: [task]);
    room = fx.room(spotIds: ['a', 'b']);
    rooms.rooms[fx.code] = room;
    useCase = SubmitClearUseCase(
      rooms: rooms,
      storage: storage,
      completeClearTask: CompleteClearTaskUseCase(rooms: rooms, queue: queue),
      finishIfAllCleared: FinishIfAllClearedUseCase(
        rooms,
        now: () => fx.createdAt,
      ),
      queue: queue,
      thumbUploadTimeout: const Duration(milliseconds: 50),
    );
  });

  test('サムネを上げて、thumbPath を入れてクリアを作り、キューから取り除く', () async {
    final result = await useCase(room, task, uid: 'me');

    expect(result, isA<SubmitClearCreated>());
    expect(
      rooms.clears[fx.code]![fx.spot('a')]!.thumbPath,
      'rooms/ABCD23/thumbs/a/me.jpg',
    );
    expect(queue.queue.tasks, isEmpty);
  });

  test('サムネが時間内に上がらなければ、クリアを先に作ってサムネの再送を残す', () async {
    storage.thumbUploadGate = Completer<void>();
    var thumbDone = false;

    await useCase(room, task, uid: 'me', onThumbDone: () => thumbDone = true);

    expect(thumbDone, isTrue);
    expect(rooms.clears[fx.code]![fx.spot('a')]!.thumbPath, isNull);
    expect(queue.queue.tasks.single.clearCreated, isTrue);
  });

  test('最後のクリアなら finished にする', () async {
    rooms.clears[fx.code] = {fx.spot('b'): fx.clear('b', 'other')};

    await useCase(room, task, uid: 'me');

    expect(rooms.rooms[fx.code]!.status, RoomStatus.finished);
  });

  test('先に他の人がクリアしていたら、その発見者を返してキューから取り除く', () async {
    rooms.clears[fx.code] = {fx.spot('a'): fx.clear('a', 'other')};

    final result = await useCase(room, task, uid: 'me');

    expect((result as SubmitClearAlreadyExists).existing.clearedBy, 'other');
    expect(queue.queue.tasks, isEmpty);
  });

  test('クリアの送信が時間内に終わらなければ、キューに残す', () async {
    rooms.createClearGate = Completer<void>();

    final result = await useCase.withTimeout(
      room,
      task,
      uid: 'me',
      createClearTimeout: const Duration(milliseconds: 50),
    );

    expect(result, isNull);
    expect(queue.queue.tasks.single.clearCreated, isFalse);
  });
}
