import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/retry_thumb_uploads_use_case.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';

import '../coop_fakes.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryThumbUploadQueueStore queue;
  late RetryThumbUploadsUseCase useCase;

  ThumbUploadTask task(
    String spotId, {
    Duration left = const Duration(hours: 1),
  }) => ThumbUploadTask(
    roomCode: 'ABCD23',
    spotId: spotId,
    localPath: '/thumbs/$spotId.jpg',
    expiresAt: now.add(left),
  );

  void seedClear(String spotId, String uid) {
    rooms.clears.putIfAbsent('ABCD23', () => {})[spotId] = SpotClear(
      spotId: spotId,
      clearedBy: uid,
      nickname: uid,
      clearedAt: now,
    );
  }

  setUp(() {
    rooms = FakeRoomRepository()..currentUid = 'me';
    storage = FakeCoopStorage();
    queue = InMemoryThumbUploadQueueStore();
    useCase = RetryThumbUploadsUseCase(
      rooms: rooms,
      storage: storage,
      queue: queue,
      uid: () async => 'me',
      now: () => now,
    );
  });

  test('再送に成功したら thumbPath を埋めてキューから取り除く', () async {
    seedClear('a', 'me');
    queue.queue = ThumbUploadQueue(tasks: [task('a')]);

    await useCase();

    expect(
      rooms.clears['ABCD23']!['a']!.thumbPath,
      'rooms/ABCD23/thumbs/a/me.jpg',
    );
    expect(queue.queue.tasks, isEmpty);
  });

  test('遊べる期限を過ぎたタスクは再送せずに破棄する', () async {
    seedClear('a', 'me');
    queue.queue = ThumbUploadQueue(tasks: [task('a', left: Duration.zero)]);

    await useCase();

    expect(storage.uploadedThumbs, isEmpty);
    expect(queue.queue.tasks, isEmpty);
  });

  test('失敗したタスクはキューに残す', () async {
    seedClear('a', 'me');
    storage.thumbUploadError = Exception('network');
    queue.queue = ThumbUploadQueue(tasks: [task('a')]);

    await useCase();

    expect(queue.queue.tasks, hasLength(1));
  });

  test('Rules に拒否されたら (自分が発見者でないなど) 破棄する', () async {
    seedClear('a', 'other');
    queue.queue = ThumbUploadQueue(tasks: [task('a'), task('b')]);
    seedClear('b', 'me');

    await useCase();

    expect(queue.queue.tasks, isEmpty);
    expect(rooms.thumbPathFills, ['rooms/ABCD23/thumbs/b/me.jpg']);
  });

  test('同時に呼ばれても同じタスクを二重に再送しない', () async {
    seedClear('a', 'me');
    queue.queue = ThumbUploadQueue(tasks: [task('a')]);

    await Future.wait([useCase(), useCase()]);

    expect(storage.uploadedThumbs, hasLength(1));
  });
}
