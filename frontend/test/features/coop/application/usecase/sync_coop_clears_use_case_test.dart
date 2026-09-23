import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  late FakeCoopStorage storage;
  late FakeHistoryRepository histories;
  late SyncCoopClearsUseCase syncClears;

  setUp(() async {
    storage = FakeCoopStorage();
    histories = FakeHistoryRepository();
    syncClears = SyncCoopClearsUseCase(storage: storage, histories: histories);
    await seedCoopHistory(histories);
  });

  test('発見者を反映し、不足しているサムネを取得する', () async {
    await syncClears(fx.code, [
      fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      fx.clear('b', 'y'),
    ]);

    final spots = histories.histories[fx.code]!.spots;
    expect(spots[0].discovererUid, 'x');
    expect(spots[0].discovererThumbPath, 'history:/tmp/download/1.jpg');
    expect(spots[1].discovererUid, 'y');
    expect(spots[1].discovererThumbPath, isNull);
    expect(spots[2].isCleared, isFalse);
  });

  test('反映済みの発見と、サムネがそろったかを返す', () async {
    final result = await syncClears(fx.code, [
      fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      fx.clear('b', 'y'),
    ]);

    expect(result.hasAllThumbs, isFalse);
    expect(result.discoveries.keys, [fx.spot('a'), fx.spot('b')]);
    expect(
      result.discoveries[fx.spot('a')]!.localThumbPath,
      'history:/tmp/download/1.jpg',
    );
  });

  test('取得済みのサムネは取り直さない', () async {
    final clears = [
      fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
    ];
    await syncClears(fx.code, clears);
    final result = await syncClears(fx.code, clears);

    expect(storage.downloadedThumbs, hasLength(1));
    expect(result.hasAllThumbs, isTrue);
  });

  test('履歴がなければ何もしない', () async {
    final result = await syncClears(RoomCode.tryParse('ZZZZ22')!, [
      fx.clear('a', 'x', thumbPath: 'p'),
    ]);

    expect(storage.downloadedThumbs, isEmpty);
    expect(result.hasAllThumbs, isFalse);
  });
}
