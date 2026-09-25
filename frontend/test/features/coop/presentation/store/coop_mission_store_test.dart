import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/prepare_coop_mission_use_case.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../../application/coop_fakes.dart';
import '../../domain/entity/coop_fixtures.dart';

/// 端末の DB を使わない進捗 (まだ何も保存していない)
class _EmptyProgress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async => null;
}

/// 端末の DB を使わないミッション (まだ何も保存していない)
class _EmptyMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => null;
}

final _mission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  destination: ImageCoordinate(
    coordinate: Coordinate(latitude: 35, longitude: 139),
    imageBase64: '',
  ),
  overviewPolyline: 'p',
);

/// このルームの進捗 (用意済み)
class _PreparedProgress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async =>
      MissionProgressEntity(startedAt: createdAt, roomCode: code);
}

/// 用意済みのミッション
class _PreparedMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => _mission;
}

class _FakeSignedInUid implements GetCoopSignedInUidUseCase {
  @override
  Future<String?> call() async => 'me';
}

/// 用意した回数を数える
class _FakePrepare implements PrepareCoopMissionUseCase {
  int calls = 0;

  @override
  Future<MissionEntity> call(
    Room room, {
    required String uid,
    MissionEntity? prepared,
  }) async {
    calls++;
    return _mission;
  }
}

ImageCoordinate _spotOf(String spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: spot(spotId),
);

/// スポット a, b, c, d のミッション
final _fourSpotMission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  waypoints: [_spotOf('a'), _spotOf('b'), _spotOf('c')],
  destination: _spotOf('d'),
  overviewPolyline: 'p',
);

/// スポット a, b, c, d のルームの進捗 (用意済み)
class _FourSpotProgress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async =>
      MissionProgressEntity(
        startedAt: createdAt,
        roomCode: code,
        checkpoints: const [null, null, null, null],
      );
}

/// スポット a, b, c, d のミッション (用意済み)
class _FourSpotMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async =>
      _fourSpotMission;
}

class _FakePrepareFourSpots implements PrepareCoopMissionUseCase {
  @override
  Future<MissionEntity> call(
    Room room, {
    required String uid,
    MissionEntity? prepared,
  }) async => _fourSpotMission;
}

void main() {
  group('CoopMissionStore', () {
    test('ルームを先に読み込んでいても (ホームの「ルームに戻る」)、作るときに失敗しない', () async {
      final container = ProviderContainer(
        overrides: [
          coopRoomProvider(code).overrideWith((ref) => Stream.value(room())),
          coopClearsProvider(code).overrideWith((ref) => const Stream.empty()),
          coopMembersProvider(code).overrideWith((ref) => const Stream.empty()),
          missionProgressStoreProvider.overrideWith(_EmptyProgress.new),
          persistedMissionProvider.overrideWith(_EmptyMission.new),
        ],
      );
      addTearDown(container.dispose);

      // ホームがルームの状態を読んでいる
      container.listen(coopRoomProvider(code), (_, __) {});
      await container.read(coopRoomProvider(code).future);

      // ルームに戻ると、すでに届いているルームで最初の通知が来る
      container.listen(coopMissionStoreProvider(code), (_, __) {});
      await pumpEventQueue();

      expect(container.read(coopMissionStoreProvider(code)).isReady, isFalse);
    });

    test('抜けて作り直したあと、同じルームに入り直すと、もう一度用意する', () async {
      final prepare = _FakePrepare();
      final container = ProviderContainer(
        overrides: [
          coopRoomProvider(code).overrideWith((ref) => Stream.value(room())),
          coopClearsProvider(code).overrideWith((ref) => const Stream.empty()),
          coopMembersProvider(code).overrideWith((ref) => const Stream.empty()),
          missionProgressStoreProvider.overrideWith(_PreparedProgress.new),
          persistedMissionProvider.overrideWith(_PreparedMission.new),
          getCoopSignedInUidUseCaseProvider.overrideWithValue(
            _FakeSignedInUid(),
          ),
          prepareCoopMissionUseCaseProvider.overrideWithValue(prepare),
        ],
      );
      addTearDown(container.dispose);
      container.listen(coopRoomProvider(code), (_, __) {});
      await container.read(coopRoomProvider(code).future);
      container.listen(coopMissionStoreProvider(code), (_, __) {});
      await pumpEventQueue();
      expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);

      // ルームを抜けると作り直す (CoopSessionStore.close)。ルームはまだ読み込んだまま
      container.invalidate(coopMissionStoreProvider(code));
      await pumpEventQueue();

      expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);
      expect(prepare.calls, 2);
    });

    group('他の人の発見のお知らせ', () {
      late StreamController<SpotClearsSnapshot> clears;
      late ProviderContainer container;

      setUp(() async {
        clears = StreamController<SpotClearsSnapshot>();
        addTearDown(clears.close);
        final rooms = FakeRoomRepository();
        final fourSpotRoom = room(spotIds: ['a', 'b', 'c', 'd']);
        rooms.rooms[code] = fourSpotRoom;
        container = ProviderContainer(
          overrides: [
            coopRoomProvider(
              code,
            ).overrideWith((ref) => Stream.value(fourSpotRoom)),
            coopClearsProvider(code).overrideWith((ref) => clears.stream),
            coopMembersProvider(code).overrideWith((ref) => Stream.value([])),
            missionProgressStoreProvider.overrideWith(_FourSpotProgress.new),
            persistedMissionProvider.overrideWith(_FourSpotMission.new),
            getCoopSignedInUidUseCaseProvider.overrideWithValue(
              _FakeSignedInUid(),
            ),
            prepareCoopMissionUseCaseProvider.overrideWithValue(
              _FakePrepareFourSpots(),
            ),
            roomRepositoryProvider.overrideWithValue(rooms),
            coopStorageProvider.overrideWithValue(FakeCoopStorage()),
            historyRepositoryProvider.overrideWithValue(
              FakeHistoryRepository(),
            ),
          ],
        );
        addTearDown(container.dispose);
        container.listen(coopMissionStoreProvider(code), (_, __) {});
        await pumpEventQueue();
        expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);
      });

      Future<void> receive(
        List<SpotClear> list, {
        required bool isFromCache,
      }) async {
        clears.add((clears: list, isFromCache: isFromCache));
        await pumpEventQueue();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced;
      }

      CoopMissionState state() =>
          container.read(coopMissionStoreProvider(code));

      test('ルームに戻ったとき、アプリを終了していた間の発見は知らせない (キャッシュのあとにサーバの値が届く)', () async {
        await receive([clear('a', 'other')], isFromCache: true);
        // 終了していた間の発見 (b) は、サーバの最初の値で届く
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
        ], isFromCache: false);

        expect(state().notice, isNull);
        expect(state().discovery, isNull);
      });

      test('サーバと同期したあとの発見は知らせて、そのスポットの結果画面へ移る', () async {
        await receive([clear('a', 'other')], isFromCache: true);
        await receive([clear('a', 'other')], isFromCache: false);
        await receive([
          clear('a', 'other'),
          clear('c', 'other'),
        ], isFromCache: false);

        expect(state().notice?.message, 'otherさんがスポット 3を発見!');
        expect(state().discovery?.spotIndex, 2);
      });
    });
  });
}
