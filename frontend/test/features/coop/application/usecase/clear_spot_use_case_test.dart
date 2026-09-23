import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final spotId = SpotId.parse('a');
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryPendingClearQueueStore queue;
  late Room room;
  late ClearSpotUseCase useCase;

  setUp(() {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    queue = InMemoryPendingClearQueueStore();
    room = fx.room();
    useCase = ClearSpotUseCase(
      rooms: rooms,
      storage: storage,
      thumbnails: FakeThumbnailService(),
      queue: queue,
      thumbUploadTimeout: const Duration(milliseconds: 50),
    );
  });

  Future<ClearSpotResult> clear({String uid = 'me'}) => useCase(
    room: room,
    uid: uid,
    nickname: uid,
    spotId: spotId,
    photoPath: '/photos/a.jpg',
  );

  test('サムネを先にアップロードし、thumbPath を入れてクリアを作成する', () async {
    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    expect((result as ClearSpotCleared).localThumbPath, '/photos/a.jpg.thumb');
    final created = rooms.clears[room.code.value]!['a']!;
    expect(created.clearedBy, 'me');
    expect(created.thumbPath, 'rooms/ABCD23/thumbs/a/me.jpg');
    expect(queue.queue.tasks, isEmpty);
  });

  test('クリアを作成する前にキューへ積む (途中でキルされても次の起動で作り直せる)', () async {
    final gate = Completer<void>();
    rooms.createClearGate = gate;

    final future = clear();
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final task = queue.queue.tasks.single;
    expect(task.clearCreated, isFalse);
    expect(task.nickname, 'me');
    expect(task.expiresAt, room.expiresAt);
    gate.complete();
    await future;
  });

  test('サムネが時間内に終わらなければ thumbPath なしで先にクリアを作成し、サムネの再送だけを残す', () async {
    storage.thumbUploadGate = Completer<void>();

    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    expect(rooms.clears[room.code.value]!['a']!.thumbPath, isNull);
    final task = queue.queue.tasks.single;
    expect(task.clearCreated, isTrue);
    expect(task.localThumbPath, '/photos/a.jpg.thumb');
  });

  test('サムネのアップロードに失敗しても、クリアを作成してサムネの再送を残す', () async {
    storage.thumbUploadError = Exception('network');

    await clear();

    expect(rooms.clears[room.code.value]!['a'], isNotNull);
    expect(queue.queue.tasks.single.clearCreated, isTrue);
  });

  test('先に他の人がクリアしていたら、その発見者を返しキューから取り除く', () async {
    await clear(uid: 'other');
    queue.queue = const PendingClearQueue();

    final result = await clear();

    expect(result, isA<ClearSpotAlreadyCleared>());
    expect((result as ClearSpotAlreadyCleared).existing.clearedBy, 'other');
    expect(queue.queue.tasks, isEmpty);
  });

  test('「発見を共有中…」はクリアの送信 (オフラインなら送信待ち) を待たずに終える', () async {
    final events = <String>[];
    final gate = Completer<void>();
    rooms.createClearGate = gate;

    final future = useCase(
      room: room,
      uid: 'me',
      nickname: 'me',
      spotId: spotId,
      photoPath: '/photos/a.jpg',
      onSharing: () => events.add('start'),
      onSharingDone: () => events.add('done'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(events, ['start', 'done']);
    gate.complete();
    await future;
  });
}
