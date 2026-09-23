import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);

  PendingClearTask task(
    String spotId, {
    Duration left = const Duration(hours: 1),
  }) => PendingClearTask(
    roomCode: 'ABCD23',
    spotId: spotId,
    nickname: 'たろう',
    localThumbPath: '/tmp/$spotId.jpg',
    expiresAt: now.add(left),
  );

  group('PendingClearQueue', () {
    test('同じルームとスポットのタスクは置き換える', () {
      final queue = const PendingClearQueue()
          .enqueue(task('a'))
          .enqueue(task('a', left: const Duration(hours: 2)));

      expect(queue.tasks, hasLength(1));
      expect(queue.tasks.single.expiresAt, now.add(const Duration(hours: 2)));
    });

    test('遊べる期限を過ぎたタスクは破棄する', () {
      final queue = PendingClearQueue(
        tasks: [
          task('a'),
          task('b', left: Duration.zero),
          task('c', left: const Duration(hours: -1)),
        ],
      );

      expect(queue.pruneExpired(now).tasks.map((t) => t.spotId), ['a']);
    });

    test('成功したタスクを取り除く', () {
      final queue = PendingClearQueue(tasks: [task('a'), task('b')]);

      expect(queue.remove(task('a')).tasks.map((t) => t.spotId), ['b']);
    });

    test('クリアを作成済みにする (サムネの再送だけが残る)', () {
      final queue = PendingClearQueue(tasks: [task('a')]);

      final updated = queue.markClearCreated(task('a'));

      expect(updated.tasks.single.clearCreated, isTrue);
    });

    test('作成済みにするタスクがなければ何もしない (先に再送で片付いた場合)', () {
      const queue = PendingClearQueue();

      expect(queue.markClearCreated(task('a')).tasks, isEmpty);
    });

    test('JSON と相互変換できる (キルされても消えないように保存する)', () {
      final queue = PendingClearQueue(tasks: [task('a')]);

      expect(PendingClearQueue.fromJson(queue.toJson()), queue);
    });
  });
}
