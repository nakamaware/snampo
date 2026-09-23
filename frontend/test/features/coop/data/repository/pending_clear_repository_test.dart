import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/data/repository/pending_clear_repository.dart';
import 'package:snampo/features/coop/domain/entity/pending_clear_task.dart';

void main() {
  late Directory dir;
  late PendingClearRepository repository;

  PendingClearTask task(String spotId) => PendingClearTask(
    roomCode: RoomCode.tryParse('ABCD23')!,
    spotId: SpotId.parse(spotId),
    nickname: Nickname.parse('たろう'),
    localThumbPath: '/tmp/$spotId.jpg',
    expiresAt: DateTime.utc(2026, 9, 23, 22),
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('pending_clear_test');
    repository = PendingClearRepository(
      file: () async => File('${dir.path}/queue.json'),
    );
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('保存したキューを読み込める', () async {
    await repository.update((queue) => queue.enqueue(task('a')));

    final loaded =
        await PendingClearRepository(
          file: () async => File('${dir.path}/queue.json'),
        ).load();

    expect(loaded.tasks.map((t) => t.spotId.value), ['a']);
  });

  test('同時に更新しても、どちらの変更も失われない', () async {
    await Future.wait([
      for (final spotId in ['a', 'b', 'c', 'd'])
        repository.update((queue) => queue.enqueue(task(spotId))),
    ]);

    final loaded = await repository.load();
    expect(loaded.tasks.map((t) => t.spotId.value).toSet(), {
      'a',
      'b',
      'c',
      'd',
    });
  });
}
