import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/di/photo_storage_provider.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/application/usecase/finish_if_all_cleared_use_case.dart';
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
      late FakeCoopStorage storage;
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
        storage = FakeCoopStorage();
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
            coopStorageProvider.overrideWithValue(storage),
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

      group('結果画面の「ホームへ戻る」で進捗を片付けてよいか', () {
        /// 他の人の発見が届いたが、電波が弱くサムネの取得が終わらない
        void receiveWithStuckThumb({required bool isUpToDate}) {
          storage.thumbDownloadGate = Completer<void>();
          clears.add((clears: [clear('a', 'other')], isUpToDate: isUpToDate));
        }

        test('撮影の扱いを決め終えていれば、クリアの反映を待たずに片付けてよいと返す', () async {
          await start();
          receiveWithStuckThumb(isUpToDate: true);
          await pumpEventQueue();

          final settled = await container
              .read(coopMissionStoreProvider(code).notifier)
              .settleUnsharedCaptures()
              .timeout(const Duration(seconds: 1));

          expect(settled, isTrue);
        });

        test('時間内に撮影の扱いを決められなければ、片付けないと返す', () async {
          rooms.offline = true;
          await start();
          receiveWithStuckThumb(isUpToDate: false);
          await pumpEventQueue();

          final settled = await container
              .read(coopMissionStoreProvider(code).notifier)
              .settleUnsharedCaptures(timeout: const Duration(milliseconds: 10))
              .timeout(const Duration(seconds: 1));

          expect(settled, isFalse);
          expect(checkpoints()[1]?.userPhotoPath, '/b.jpg');
          expect(checkpoints()[2]?.userPhotoPath, '/c.jpg');
        });
      });
    });

    group('全スポットのクリアでの終了', () {
      late StreamController<SpotClearsSnapshot> clears;
      late FakeRoomRepository rooms;
      late FakeCoopStorage storage;
      late FakeHistoryRepository histories;
      late ProviderContainer container;

      setUp(() async {
        clears = StreamController<SpotClearsSnapshot>();
        addTearDown(clears.close);
        rooms = FakeRoomRepository();
        storage = FakeCoopStorage();
        histories = FakeHistoryRepository();
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
            // 遊べる期限内にする
            finishIfAllClearedUseCaseProvider.overrideWithValue(
              FinishIfAllClearedUseCase(rooms, now: () => createdAt),
            ),
            coopStorageProvider.overrideWithValue(storage),
            historyRepositoryProvider.overrideWithValue(histories),
          ],
        );
        addTearDown(container.dispose);
        container.listen(coopMissionStoreProvider(code), (_, __) {});
        await pumpEventQueue();
        expect(container.read(coopMissionStoreProvider(code)).isReady, isTrue);
      });

      /// 全スポットのクリアを受け取り、反映し終えるまで待つ
      Future<void> receiveAllCleared() async {
        clears.add((
          clears: [
            clear('a', 'other'),
            clear('b', 'other'),
            clear('c', 'other'),
            clear('d', 'other'),
          ],
          isUpToDate: true,
        ));
        await pumpEventQueue();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced
            .timeout(const Duration(seconds: 1));
      }

      test('finished への更新がサーバに届くのを待たずに、反映を終える', () async {
        // オフラインや電波が弱いと、更新はサーバに届くまで終わらない
        final sent = Completer<void>();
        rooms.finishGate = sent;

        await receiveAllCleared();
        expect(rooms.rooms[code]!.status, RoomStatus.playing);

        sent.complete();
        await pumpEventQueue();
        expect(rooms.rooms[code]!.status, RoomStatus.finished);
      });

      test('サムネの取得を待たずに、finished にする', () async {
        await seedFourSpotHistory(histories);
        // 電波が弱く、サムネの取得が終わらない
        storage.thumbDownloadGate = Completer<void>();

        clears.add((
          clears: [
            clear('a', 'other'),
            clear('b', 'other'),
            clear('c', 'other'),
            clear('d', 'other'),
          ],
          isUpToDate: true,
        ));
        await pumpEventQueue();

        expect(rooms.rooms[code]!.status, RoomStatus.finished);
      });

      test('finished への更新が拒否されても、反映を終える', () async {
        rooms.rejectFinish = true;

        await receiveAllCleared();

        expect(rooms.rooms[code]!.status, RoomStatus.playing);
      });
    });

    group('他の人の発見のお知らせ', () {
      late StreamController<SpotClearsSnapshot> clears;
      late FakeCoopStorage storage;
      late FakeHistoryRepository histories;
      late ProviderContainer container;

      setUp(() async {
        clears = StreamController<SpotClearsSnapshot>();
        addTearDown(clears.close);
        storage = FakeCoopStorage();
        histories = FakeHistoryRepository();
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
            coopStorageProvider.overrideWithValue(storage),
            historyRepositoryProvider.overrideWithValue(histories),
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

      test('その場で届いた発見のスポットの結果画面は、サムネを取得し終えてから開く', () async {
        await seedFourSpotHistory(histories);
        await receive([clear('a', 'other')], isUpToDate: false);
        await receive([clear('a', 'other')], isUpToDate: true);

        final thumb = Completer<void>();
        storage.thumbDownloadGate = thumb;
        clears.add((
          clears: [clear('a', 'other'), clear('c', 'other')],
          isUpToDate: true,
        ));
        await pumpEventQueue();
        expect(state().notice?.message, 'otherさんがスポット 3を発見!');
        expect(state().discovery, isNull);

        thumb.complete();
        await container
            .read(coopMissionStoreProvider(code).notifier)
            .clearsSynced;

        expect(state().discovery?.spotIndex, 2);
        final opened =
            container
                .read(missionProgressStoreProvider(MissionSessionKind.coop))
                .value!
                .checkpoints[2];
        expect(opened?.discovererThumbPath, isNotNull);
      });

      test('その場で届いた発見のスポットの結果画面は、ほかのスポットのサムネの取り直しを待たずに開く', () async {
        await seedFourSpotHistory(histories);
        // a のサムネは取得できなかった (次の同期で取り直す)
        storage.thumbDownloadError = Exception('offline');
        await receive([clear('a', 'other')], isUpToDate: false);
        await receive([clear('a', 'other')], isUpToDate: true);
        storage.thumbDownloadError = null;

        // a のサムネの取り直しは、電波が弱く終わらない
        storage.thumbDownloadGates[clear('a', 'other').thumbPath] =
            Completer<void>();
        clears.add((
          clears: [clear('a', 'other'), clear('c', 'other')],
          isUpToDate: true,
        ));
        await pumpEventQueue();

        expect(state().discovery?.spotIndex, 2);
        final opened =
            container
                .read(missionProgressStoreProvider(MissionSessionKind.coop))
                .value!
                .checkpoints[2];
        expect(opened?.discovererThumbPath, isNotNull);
      });

      test(
        'その場で届いた発見のスポットのサムネを取得できなければ、ほかのスポットのサムネの取り直しを待たずに、プレースホルダで開く',
        () async {
          await seedFourSpotHistory(histories);
          // a のサムネは取得できなかった (次の同期で取り直す)
          storage.thumbDownloadError = Exception('offline');
          await receive([clear('a', 'other')], isUpToDate: false);
          await receive([clear('a', 'other')], isUpToDate: true);

          // c のサムネも取得できず、a のサムネの取り直しは電波が弱く終わらない
          storage.thumbDownloadGates[clear('a', 'other').thumbPath] =
              Completer<void>();
          clears.add((
            clears: [clear('a', 'other'), clear('c', 'other')],
            isUpToDate: true,
          ));
          await pumpEventQueue();

          expect(state().discovery?.spotIndex, 2);
          final opened =
              container
                  .read(missionProgressStoreProvider(MissionSessionKind.coop))
                  .value!
                  .checkpoints[2];
          expect(opened?.discovererUid, 'other');
          expect(opened?.discovererThumbPath, isNull);
        },
      );

      test('その場で届いた最後のスポットの発見は、ルームの終了に合わせて開く', () async {
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
        ], isUpToDate: false);
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
        ], isUpToDate: true);
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
          clear('d', 'other'),
        ], isUpToDate: true);

        expect(state().finalDiscovery?.spotIndex, 3);
        expect(state().discovery, isNull);
      });

      test('最後のスポットのサムネの取得が終わらなくても、発見者を進捗に反映して最後のスポットを開けるようにする', () async {
        await seedFourSpotHistory(histories);
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
        ], isUpToDate: false);
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
        ], isUpToDate: true);

        // 電波が弱く、最後のスポットのサムネの取得が終わらない
        storage.thumbDownloadGate = Completer<void>();
        clears.add((
          clears: [
            clear('a', 'other'),
            clear('b', 'other'),
            clear('c', 'other'),
            clear('d', 'other'),
          ],
          isUpToDate: true,
        ));
        await pumpEventQueue();

        // Mission 画面は反映を待ちきれず、ここまでに反映できた分で開く (サムネはプレースホルダ)
        expect(state().finalDiscovery?.spotIndex, 3);
        final last =
            container
                .read(missionProgressStoreProvider(MissionSessionKind.coop))
                .value!
                .checkpoints[3];
        expect(last?.discovererUid, 'other');
        expect(last?.discovererThumbPath, isNull);
      });

      test('ルームに戻ったときに追いついた最後のスポットの発見では、最後のスポットの結果画面を開かない', () async {
        // Home の「ルームに戻る」は、端末に残っていた (まだ終わっていない) ルームから開く
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
        ], isUpToDate: false);
        // 終了していた間に、最後のスポットが発見されていた
        await receive([
          clear('a', 'other'),
          clear('b', 'other'),
          clear('c', 'other'),
          clear('d', 'other'),
        ], isUpToDate: true);

        expect(state().finalDiscovery, isNull);
        expect(state().notice, isNull);
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
