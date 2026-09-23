import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/clear_spot_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final spotId = SpotId.parse('a');
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryThumbUploadQueueStore queue;
  late Room room;
  late ClearSpotUseCase useCase;

  setUp(() {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    queue = InMemoryThumbUploadQueueStore();
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

  test('サムネが時間内に終わらなければ thumbPath なしで先にクリアを作成し、再送キューに積む', () async {
    storage.thumbUploadGate = Completer<void>();

    final result = await clear();

    expect(result, isA<ClearSpotCleared>());
    expect(rooms.clears[room.code.value]!['a']!.thumbPath, isNull);
    final task = queue.queue.tasks.single;
    expect(task.spotId, 'a');
    expect(task.localPath, '/photos/a.jpg.thumb');
    expect(task.expiresAt, room.expiresAt);
  });

  test('サムネのアップロードに失敗しても、クリアを作成して再送キューに積む', () async {
    storage.thumbUploadError = Exception('network');

    await clear();

    expect(rooms.clears[room.code.value]!['a'], isNotNull);
    expect(queue.queue.tasks, hasLength(1));
  });

  test('先に他の人がクリアしていたら、その発見者を返し再送しない', () async {
    storage.thumbUploadGate = Completer<void>();
    await clear(uid: 'other');
    storage.thumbUploadGate = null;
    queue.queue = const ThumbUploadQueue();

    final result = await clear();

    expect(result, isA<ClearSpotAlreadyCleared>());
    expect((result as ClearSpotAlreadyCleared).existing.clearedBy, 'other');
    expect(queue.queue.tasks, isEmpty);
  });

  test('サムネの共有を始めたことを通知する', () async {
    var notified = false;

    await useCase(
      room: room,
      uid: 'me',
      nickname: 'me',
      spotId: spotId,
      photoPath: '/photos/a.jpg',
      onSharing: () => notified = true,
    );

    expect(notified, isTrue);
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
