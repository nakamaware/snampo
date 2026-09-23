import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

ImageCoordinate _spot(String spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: spotId,
);

void main() {
  const code = 'ABCD23';
  final expiresAt = fx.createdAt.add(Room.playableDuration);
  final deleteAt = fx.createdAt.add(Room.retentionDuration);
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late FakeHistoryRepository histories;
  late SyncCoopClearsUseCase syncClears;

  setUp(() async {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    histories = FakeHistoryRepository();
    syncClears = SyncCoopClearsUseCase(storage: storage, histories: histories);
    await histories.upsertCoopHistory(
      mission: MissionEntity(
        departure: Coordinate(latitude: 35, longitude: 139),
        waypoints: [_spot('a'), _spot('b')],
        destination: _spot('c'),
        overviewPolyline: 'p',
      ),
      startedAt: fx.createdAt,
      coop: CoopHistoryInfo(
        roomCode: code,
        syncState: CoopSyncState.inProgress,
        isHost: false,
        members: const [],
        expiresAt: expiresAt,
        deleteAt: deleteAt,
      ),
    );
  });

  group('SyncCoopClearsUseCase', () {
    test('発見者を反映し、不足しているサムネを取得する', () async {
      await syncClears(code, [
        fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
        fx.clear('b', 'y'),
      ]);

      final spots = histories.histories[code]!.spots;
      expect(spots[0].discovererUid, 'x');
      expect(spots[0].discovererThumbPath, 'history:/tmp/download/1.jpg');
      expect(spots[1].discovererUid, 'y');
      expect(spots[1].discovererThumbPath, isNull);
      expect(spots[2].isCleared, isFalse);
    });

    test('取得済みのサムネは取り直さない', () async {
      final clears = [
        fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      ];
      await syncClears(code, clears);
      await syncClears(code, clears);

      expect(storage.downloadedThumbs, hasLength(1));
    });

    test('履歴がなければ何もしない', () async {
      await syncClears('ZZZZ22', [fx.clear('a', 'x', thumbPath: 'p')]);

      expect(storage.downloadedThumbs, isEmpty);
    });
  });

  group('SyncCoopHistoryUseCase', () {
    SyncCoopHistoryUseCase useCase(DateTime now) => SyncCoopHistoryUseCase(
      rooms: rooms,
      histories: histories,
      syncClears: syncClears,
      now: () => now,
    );

    test('進行中の履歴について clears を 1 回取得して反映する', () async {
      rooms.rooms[code] = fx.room();
      rooms.clears[code] = {
        'a': fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      };

      await useCase(fx.createdAt.add(const Duration(hours: 1)))();

      final history = histories.histories[code]!;
      expect(history.spots[0].discovererUid, 'x');
      expect(history.coop!.syncState, CoopSyncState.inProgress);
    });

    test('ルームが finished で、サムネが全部そろったら確定する', () async {
      rooms.rooms[code] = fx.room(status: RoomStatus.finished);
      rooms.clears[code] = {
        'a': fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      };

      await useCase(fx.createdAt.add(const Duration(hours: 1)))();

      expect(
        histories.histories[code]!.coop!.syncState,
        CoopSyncState.finalized,
      );
    });

    test('ルームが finished でも、サムネが届くまでは確定せず、届いたら取り込んで確定する', () async {
      rooms.rooms[code] = fx.room(status: RoomStatus.finished);
      rooms.clears[code] = {'a': fx.clear('a', 'x')};
      final sync = useCase(fx.createdAt.add(const Duration(hours: 1)));

      await sync();

      expect(
        histories.histories[code]!.coop!.syncState,
        CoopSyncState.inProgress,
      );

      // 発見者の再送で thumbPath が後から埋まる
      rooms.clears[code] = {
        'a': fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
      };
      await sync();

      final history = histories.histories[code]!;
      expect(history.spots[0].discovererThumbPath, isNotNull);
      expect(history.coop!.syncState, CoopSyncState.finalized);
    });

    test('遊べる期限を過ぎていれば確定する', () async {
      rooms.rooms[code] = fx.room();

      await useCase(expiresAt.add(const Duration(minutes: 1)))();

      expect(
        histories.histories[code]!.coop!.syncState,
        CoopSyncState.finalized,
      );
    });

    test('オフラインなら次の機会に回す', () async {
      rooms.offline = true;

      await useCase(fx.createdAt.add(const Duration(hours: 1)))();

      expect(
        histories.histories[code]!.coop!.syncState,
        CoopSyncState.inProgress,
      );
    });

    test('保持期限を過ぎた履歴は取りにいかずに確定する (取れなかった分はプレースホルダ)', () async {
      rooms.offline = true;

      await useCase(deleteAt.add(const Duration(minutes: 1)))();

      expect(
        histories.histories[code]!.coop!.syncState,
        CoopSyncState.finalized,
      );
    });
  });
}
