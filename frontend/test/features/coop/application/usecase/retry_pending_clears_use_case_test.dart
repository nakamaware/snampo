import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/coop/application/usecase/complete_clear_task_use_case.dart';
import 'package:snampo/features/coop/application/usecase/retry_pending_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

void main() {
  final now = fx.createdAt.add(const Duration(hours: 1));
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late InMemoryPendingClearRepository queue;
  late RetryPendingClearsUseCase useCase;

  PendingClearTask task(
    String spotId, {
    Duration left = const Duration(hours: 1),
    bool clearCreated = false,
  }) => PendingClearTask(
    roomCode: fx.code,
    spotId: fx.spot(spotId),
    nickname: Nickname.parse('me'),
    localThumbPath: '/thumbs/$spotId.jpg',
    expiresAt: now.add(left),
    clearCreated: clearCreated,
  );

  void seedClear(String spotId, String uid) {
    rooms.clears.putIfAbsent(fx.code, () => {})[fx.spot(spotId)] = SpotClear(
      spotId: fx.spot(spotId),
      clearedBy: uid,
      nickname: uid,
      clearedAt: now,
    );
  }

  RetryPendingClearsUseCase build({Future<String?> Function()? uid}) =>
      RetryPendingClearsUseCase(
        rooms: rooms,
        storage: storage,
        queue: queue,
        completeClearTask: CompleteClearTaskUseCase(rooms: rooms, queue: queue),
        uid: uid ?? () async => 'me',
        now: () => now,
        createClearTimeout: const Duration(milliseconds: 50),
      );

  setUp(() {
    rooms = FakeRoomRepository()..currentUid = 'me';
    rooms.rooms[fx.code] = fx.room();
    storage = FakeCoopStorage();
    queue = InMemoryPendingClearRepository();
    useCase = build();
  });

  group('クリアを作成していないタスク (キルされたなど)', () {
    test('サムネを上げてクリアを作り直し、キューから取り除く', () async {
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      final created = rooms.clears[fx.code]![fx.spot('a')]!;
      expect(created.clearedBy, 'me');
      expect(created.thumbPath, 'rooms/ABCD23/thumbs/a/me.jpg');
      expect(queue.queue.tasks, isEmpty);
      expect(result.failures, isEmpty);
    });

    test('送信待ちだった自分のクリアが先に届いていても、thumbPath を埋めて取り除く', () async {
      // キルされる前の自分の書き込みが、サムネなしでサーバに届いていた
      seedClear('a', 'me');
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      expect(
        rooms.clears[fx.code]![fx.spot('a')]!.thumbPath,
        'rooms/ABCD23/thumbs/a/me.jpg',
      );
      expect(queue.queue.tasks, isEmpty);
      expect(result.failures, isEmpty);
    });

    test('サムネを上げられなければ、クリアだけ作ってサムネの再送を残す', () async {
      storage.thumbUploadError = Exception('network');
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      await useCase();

      expect(rooms.clears[fx.code]![fx.spot('a')]!.thumbPath, isNull);
      expect(queue.queue.tasks.single.clearCreated, isTrue);
    });

    test('先に他の人がクリアしていたら、競合として返して破棄する', () async {
      seedClear('a', 'other');
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      final failure = result.failures.single;
      expect(failure.reason, PendingClearFailureReason.alreadyCleared);
      expect(failure.existing?.clearedBy, 'other');
      expect(queue.queue.tasks, isEmpty);
    });

    test('ルームが終わっていたら、共有できなかったとして返して破棄する', () async {
      rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      expect(
        result.failures.single.reason,
        PendingClearFailureReason.roomClosed,
      );
      expect(queue.queue.tasks, isEmpty);
    });

    test('自分のクリアが届いてルームが終わっていたら、成功として thumbPath を埋める', () async {
      // キルされる前の自分の書き込みが最後のクリアとして届き、finished になった
      rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
      seedClear('a', 'me');
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      expect(result.failures, isEmpty);
      expect(
        rooms.clears[fx.code]![fx.spot('a')]!.thumbPath,
        'rooms/ABCD23/thumbs/a/me.jpg',
      );
      expect(queue.queue.tasks, isEmpty);
    });

    test('ルームが終わっていて、先に他の人が発見していたら、競合として返す', () async {
      rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
      seedClear('a', 'other');
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      final result = await useCase();

      expect(
        result.failures.single.reason,
        PendingClearFailureReason.alreadyCleared,
      );
      expect(queue.queue.tasks, isEmpty);
    });

    test('クリアの送信が終わらなければ (オフライン) キューに残す', () async {
      rooms.createClearGate = Completer<void>();
      queue.queue = PendingClearQueue(tasks: [task('a')]);

      await useCase();

      expect(queue.queue.tasks.single.clearCreated, isFalse);
    });
  });

  group('クリアを作成済みのタスク (サムネの再送だけ)', () {
    test('再送に成功したら thumbPath を埋めてキューから取り除く', () async {
      seedClear('a', 'me');
      queue.queue = PendingClearQueue(tasks: [task('a', clearCreated: true)]);

      await useCase();

      expect(
        rooms.clears[fx.code]![fx.spot('a')]!.thumbPath,
        'rooms/ABCD23/thumbs/a/me.jpg',
      );
      expect(queue.queue.tasks, isEmpty);
    });

    test('失敗したタスクはキューに残す', () async {
      seedClear('a', 'me');
      storage.thumbUploadError = Exception('network');
      queue.queue = PendingClearQueue(tasks: [task('a', clearCreated: true)]);

      await useCase();

      expect(queue.queue.tasks, hasLength(1));
    });

    test('Rules に拒否されたら (自分が発見者でないなど) 破棄する', () async {
      seedClear('a', 'other');
      seedClear('b', 'me');
      queue.queue = PendingClearQueue(
        tasks: [task('a', clearCreated: true), task('b', clearCreated: true)],
      );

      await useCase();

      expect(queue.queue.tasks, isEmpty);
      expect(rooms.thumbPathFills, ['rooms/ABCD23/thumbs/b/me.jpg']);
    });
  });

  test('遊べる期限を過ぎたタスクは再送せずに破棄する', () async {
    queue.queue = PendingClearQueue(tasks: [task('a', left: Duration.zero)]);

    await useCase();

    expect(storage.uploadedThumbs, isEmpty);
    expect(queue.queue.tasks, isEmpty);
  });

  test('同時に呼ばれても同じタスクを二重に再送しない', () async {
    seedClear('a', 'me');
    queue.queue = PendingClearQueue(tasks: [task('a', clearCreated: true)]);

    await Future.wait([useCase(), useCase()]);

    expect(storage.uploadedThumbs, hasLength(1));
  });

  test('未サインインなら再送せずにキューに残す (サインインの再試行はしない)', () async {
    queue.queue = PendingClearQueue(tasks: [task('a')]);
    useCase = build(uid: () async => null);

    await useCase();

    expect(storage.uploadedThumbs, isEmpty);
    expect(queue.queue.tasks, hasLength(1));
  });
}
