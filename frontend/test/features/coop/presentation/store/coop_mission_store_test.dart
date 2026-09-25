import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/di/photo_storage_provider.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
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
import '../coop_store_fakes.dart';

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
            FakeSignedInUid(),
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

    group('共有の途中で終了した撮影', () {
      late StreamController<SpotClearsSnapshot> clears;
      late FakeRoomRepository rooms;
      late FakeHistoryRepository histories;
      late ProviderContainer container;

      /// b と c を撮影したが、共有の結果が付かないまま終了した進捗
      final unshared = MissionProgressEntity(
        startedAt: createdAt,
        roomCode: code,
        checkpoints: const [
          null,
          CheckpointProgress(userPhotoPath: '/b.jpg'),
          CheckpointProgress(userPhotoPath: '/c.jpg'),
          null,
        ],
      );

      setUp(() async {
        clears = StreamController<SpotClearsSnapshot>();
        addTearDown(clears.close);
        rooms = FakeRoomRepository();
        final playing = fourSpotRoom();
        rooms.rooms[code] = playing;
        // b の共有はサーバに届いていた
        rooms.clears[code] = {spot('b'): clear('b', 'me')};
        histories = FakeHistoryRepository();
        await seedFourSpotHistory(histories);
        container = ProviderContainer(
          overrides: [
            coopRoomProvider(code).overrideWith((ref) => Stream.value(playing)),
            coopClearsProvider(code).overrideWith((ref) => clears.stream),
            coopMembersProvider(code).overrideWith((ref) => Stream.value([])),
            missionProgressStoreProvider.overrideWith(
              () => ProgressOf(unshared),
            ),
            persistedMissionProvider.overrideWith(FourSpotMission.new),
            getCoopSignedInUidUseCaseProvider.overrideWithValue(
              FakeSignedInUid(),
            ),
            prepareCoopMissionUseCaseProvider.overrideWithValue(
              FakePrepareFourSpots(),
            ),
            roomRepositoryProvider.overrideWithValue(rooms),
            coopStorageProvider.overrideWithValue(FakeCoopStorage()),
            historyRepositoryProvider.overrideWithValue(histories),
            photoStorageProvider.overrideWithValue(FakePhotoStorage()),
          ],
        );
        addTearDown(container.dispose);
      });

      Future<void> start() async {
        container.listen(coopMissionStoreProvider(code), (_, __) {});
        await pumpEventQueue();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced;
      }

      Future<void> receive(
        List<SpotClear> list, {
        required bool isUpToDate,
      }) async {
        clears.add((clears: list, isUpToDate: isUpToDate));
        await pumpEventQueue();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced;
      }

      List<CheckpointProgress?> checkpoints() =>
          container
              .read(missionProgressStoreProvider(MissionSessionKind.coop))
              .value!
              .checkpoints;

      test('クリアを読めなければ捨てず、サーバの最新の値が届いたら決め直す', () async {
        rooms.offline = true;
        await start();

        // 判断できないので、どちらも捨てない
        expect(checkpoints()[1]?.userPhotoPath, '/b.jpg');
        expect(checkpoints()[2]?.userPhotoPath, '/c.jpg');

        // 電波が戻り、サーバの最新の値が届く
        rooms.offline = false;
        await receive([clear('b', 'me')], isUpToDate: true);

        // サーバにクリアのない c は捨て、届いていた b は履歴に残す
        expect(checkpoints()[2], isNull);
        expect(checkpoints()[1]?.userPhotoPath, '/b.jpg');
        expect(checkpoints()[1]?.discovererUid, 'me');
        expect(histories.histories[code]!.spots[1].userPhotoPath, '/b.jpg');
      });
    });

    group('他の人の発見のお知らせ', () {
      late StreamController<SpotClearsSnapshot> clears;
      late ProviderContainer container;

      setUp(() async {
        clears = StreamController<SpotClearsSnapshot>();
        addTearDown(clears.close);
        final rooms = FakeRoomRepository();
        final playing = fourSpotRoom();
        rooms.rooms[code] = playing;
        container = ProviderContainer(
          overrides: [
            coopRoomProvider(code).overrideWith((ref) => Stream.value(playing)),
            coopClearsProvider(code).overrideWith((ref) => clears.stream),
            coopMembersProvider(code).overrideWith((ref) => Stream.value([])),
            missionProgressStoreProvider.overrideWith(_FourSpotProgress.new),
            persistedMissionProvider.overrideWith(FourSpotMission.new),
            getCoopSignedInUidUseCaseProvider.overrideWithValue(
              FakeSignedInUid(),
            ),
            prepareCoopMissionUseCaseProvider.overrideWithValue(
              FakePrepareFourSpots(),
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
        required bool isUpToDate,
      }) async {
        clears.add((clears: list, isUpToDate: isUpToDate));
        await pumpEventQueue();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced;
      }

      CoopMissionState state() =>
          container.read(coopMissionStoreProvider(code));

      test('ルームに戻ったとき、アプリを終了していた間の発見は知らせない (キャッシュのあとにサーバの値が届く)', () async {
        await receive([clear('a', 'other')], isUpToDate: false);
        // 終了していた間の発見 (b) は、サーバの最初の値で届く
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
        ], isUpToDate: true);

        expect(state().notice, isNull);
        expect(state().discovery, isNull);
      });

      test('サーバと同期したあとの発見は知らせて、そのスポットの結果画面へ移る', () async {
        await receive([clear('a', 'other')], isUpToDate: false);
        await receive([clear('a', 'other')], isUpToDate: true);
        await receive([
          clear('a', 'other'),
          clear('c', 'other'),
        ], isUpToDate: true);

        expect(state().notice?.message, 'otherさんがスポット 3を発見!');
        expect(state().discovery?.spotIndex, 2);
      });

      test('電波が戻ったときに届いた発見は、バナーだけにして結果画面を開かない', () async {
        await receive([clear('a', 'other')], isUpToDate: false);
        await receive([clear('a', 'other')], isUpToDate: true);
        // 電波が切れて、端末に残っていた値になる
        await receive([clear('a', 'other')], isUpToDate: false);
        // 電波が戻り、切れていた間の発見 (c) が届く
        await receive([
          clear('a', 'other'),
          clear('c', 'other'),
        ], isUpToDate: true);

        expect(state().notice?.message, 'otherさんがスポット 3を発見!');
        expect(state().discovery, isNull);
      });

      test('一度に複数の発見が届いたら、まとめたバナーを 1 つだけ出し、結果画面を開かない', () async {
        await receive([clear('a', 'other')], isUpToDate: false);
        await receive([clear('a', 'other')], isUpToDate: true);
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'another'),
        ], isUpToDate: true);

        expect(state().notice?.message, '他のメンバーが 2 か所のスポットを発見!');
        expect(state().notice?.id, 1);
        expect(state().discovery, isNull);
      });
    });
  });
}
