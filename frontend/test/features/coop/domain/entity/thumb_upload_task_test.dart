import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/thumb_upload_task.dart';

void main() {
  final now = DateTime.utc(2026, 9, 23, 12);

  ThumbUploadTask task(
    String spotId, {
    Duration left = const Duration(hours: 1),
  }) => ThumbUploadTask(
    roomCode: 'ABCD23',
    spotId: spotId,
    localPath: '/tmp/$spotId.jpg',
    expiresAt: now.add(left),
  );

  group('ThumbUploadQueue', () {
    test('同じルームとスポットのタスクは置き換える', () {
      final queue = const ThumbUploadQueue()
          .enqueue(task('a'))
          .enqueue(task('a', left: const Duration(hours: 2)));

      expect(queue.tasks, hasLength(1));
      expect(queue.tasks.single.expiresAt, now.add(const Duration(hours: 2)));
    });

    test('遊べる期限を過ぎたタスクは破棄する', () {
      final queue = ThumbUploadQueue(
        tasks: [
          task('a'),
          task('b', left: Duration.zero),
          task('c', left: const Duration(hours: -1)),
        ],
      );

      final pruned = queue.pruneExpired(now);

      expect(pruned.tasks.map((t) => t.spotId), ['a']);
    });

    test('成功したタスクを取り除く', () {
      final queue = ThumbUploadQueue(tasks: [task('a'), task('b')]);

      expect(queue.remove(task('a')).tasks.map((t) => t.spotId), ['b']);
    });

    test('JSON と相互変換できる (キルされても消えないように保存する)', () {
      final queue = ThumbUploadQueue(tasks: [task('a')]);

      expect(ThumbUploadQueue.fromJson(queue.toJson()), queue);
    });
  });
}
