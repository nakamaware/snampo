import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/finalize_coop_history_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_history_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  final expiresAt = fx.createdAt.add(Room.playableDuration);
  final deleteAt = fx.createdAt.add(Room.retentionDuration);
  late FakeRoomRepository rooms;
  late FakeHistoryRepository histories;
  late FakeCoopStorage storage;
  late SyncCoopClearsUseCase syncClears;

  setUp(() async {
    rooms = FakeRoomRepository();
    histories = FakeHistoryRepository();
    storage = FakeCoopStorage();
    syncClears = SyncCoopClearsUseCase(storage: storage, histories: histories);
    await seedCoopHistory(histories);
  });

  SyncCoopHistoryUseCase useCase(DateTime now) => SyncCoopHistoryUseCase(
    rooms: rooms,
    histories: histories,
    syncClears: syncClears,
    finalize: FinalizeCoopHistoryUseCase(histories, now: () => now),
    now: () => now,
  );

  CoopSyncState syncState() => histories.histories[fx.code]!.coop!.syncState;

  test('進行中の履歴について clears を 1 回取得して反映する', () async {
    rooms.rooms[fx.code] = fx.room();
    rooms.clears[fx.code] = {
      fx.spot('a'): fx.clear(
        'a',
        'x',
        thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg',
      ),
    };

    await useCase(fx.createdAt.add(const Duration(hours: 1)))();

    expect(histories.histories[fx.code]!.spots[0].discovererUid, 'x');
    expect(syncState(), CoopSyncState.inProgress);
  });

  test('ルームが finished で、サムネが全部そろったら確定する', () async {
    rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
    rooms.clears[fx.code] = {
      fx.spot('a'): fx.clear(
        'a',
        'x',
        thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg',
      ),
    };

    await useCase(fx.createdAt.add(const Duration(hours: 1)))();

    expect(syncState(), CoopSyncState.finalized);
  });

  test('クリアが 0 件で finished なら確定する (以後クリアは作れない)', () async {
    rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);

    await useCase(fx.createdAt.add(const Duration(hours: 1)))();

    expect(syncState(), CoopSyncState.finalized);
  });

  test('ルームが finished でも、サムネを取得できるまでは確定せず、取得できたら確定する', () async {
    rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
    rooms.clears[fx.code] = {fx.spot('a'): fx.clear('a', 'x')};
    final sync = useCase(fx.createdAt.add(const Duration(hours: 1)));
    storage.thumbDownloadError = Exception('network');

    await sync();

    expect(syncState(), CoopSyncState.inProgress);

    storage.thumbDownloadError = null;
    await sync();

    expect(
      histories.histories[fx.code]!.spots[0].discovererThumbPath,
      isNotNull,
    );
    expect(syncState(), CoopSyncState.finalized);
  });

  test('遊べる期限を過ぎていれば確定する', () async {
    rooms.rooms[fx.code] = fx.room();

    await useCase(expiresAt.add(const Duration(minutes: 1)))();

    expect(syncState(), CoopSyncState.finalized);
  });

  test('サーバから取得できなければ (オフライン) 確定せずに次の機会に回す', () async {
    rooms.rooms[fx.code] = fx.room(status: RoomStatus.finished);
    rooms.offline = true;

    await useCase(expiresAt.add(const Duration(minutes: 1)))();

    expect(syncState(), CoopSyncState.inProgress);
  });

  test('保持期限を過ぎた履歴は取りにいかずに確定する (取れなかった分はプレースホルダ)', () async {
    rooms.offline = true;

    await useCase(deleteAt.add(const Duration(minutes: 1)))();

    expect(syncState(), CoopSyncState.finalized);
  });
}
