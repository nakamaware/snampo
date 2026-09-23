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
    await syncClears(fx.code, [fx.clear('a', 'x'), fx.clear('b', 'y')]);

    final spots = histories.histories[fx.code]!.spots;
    expect(spots[0].discovererUid, 'x');
    expect(spots[0].discovererThumbPath, 'history:/tmp/download/1.jpg');
    expect(spots[1].discovererUid, 'y');
    expect(spots[1].discovererThumbPath, 'history:/tmp/download/2.jpg');
    expect(spots[2].isCleared, isFalse);
  });

  test('反映済みの発見と、サムネがそろったかを返す', () async {
    final result = await syncClears(fx.code, [
      fx.clear('a', 'x'),
      fx.clear('b', 'y'),
    ]);

    expect(result.hasAllThumbs, isTrue);
    expect(result.discoveries.keys, [fx.spot('a'), fx.spot('b')]);
    expect(
      result.discoveries[fx.spot('a')]!.thumbPath,
      'history:/tmp/download/1.jpg',
    );
  });

  test('サムネを取得できなければ、発見者だけ反映してそろっていないと返す', () async {
    storage.thumbDownloadError = Exception('network');

    final result = await syncClears(fx.code, [fx.clear('a', 'x')]);

    expect(histories.histories[fx.code]!.spots[0].discovererUid, 'x');
    expect(result.hasAllThumbs, isFalse);
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
