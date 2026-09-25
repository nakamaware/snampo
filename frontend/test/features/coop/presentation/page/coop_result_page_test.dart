import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/di/photo_storage_provider.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/presentation/page/coop_result_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../../application/coop_fakes.dart';
import '../../domain/entity/coop_fixtures.dart';
import '../coop_store_fakes.dart';

/// 端末で進行中のルーム ([code])
class _Session extends CoopSessionStore {
  @override
  Future<CoopSession?> build() async => CoopSession(roomCode: code, uid: 'me');
}

void main() {
  group('CoopResultPage', () {
    late FakeRoomRepository rooms;
    late FakeHistoryRepository histories;
    late FakePhotoStorage photos;
    late ProviderContainer container;

    setUp(() async {
      rooms = FakeRoomRepository();
      rooms.rooms[code] = fourSpotRoom(status: RoomStatus.finished);
      histories = FakeHistoryRepository();
      await seedFourSpotHistory(histories);
      photos = FakePhotoStorage();
    });

    /// ホームの「結果を見る」から、終了したルームの結果画面を開く
    ///
    /// 端末の進捗は [progress]、サーバの `clears` は [serverClears]
    /// ([online] が false ならサーバから読めない)。
    Future<void> openFromHome(
      WidgetTester tester, {
      required MissionProgressEntity progress,
      required List<SpotClear> serverClears,
      bool online = true,
    }) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      rooms
        ..clears[code] = {for (final c in serverClears) c.spotId: c}
        ..offline = !online;
      final router = GoRouter(
        initialLocation: '/coop/result',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const Text('home')),
          GoRoute(
            path: '/coop/result',
            builder: (_, _) => const CoopResultPage(),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coopSessionStoreProvider.overrideWith(_Session.new),
            coopRoomProvider(
              code,
            ).overrideWith((ref) => Stream.value(rooms.rooms[code])),
            coopClearsProvider(code).overrideWith(
              (ref) =>
                  online
                      ? Stream.value((clears: serverClears, isUpToDate: true))
                      : Stream.value((clears: const [], isUpToDate: false)),
            ),
            coopMembersProvider(code).overrideWith((ref) => Stream.value([])),
            missionProgressStoreProvider.overrideWith(
              () => ProgressOf(progress),
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
            photoStorageProvider.overrideWithValue(photos),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      container = ProviderScope.containerOf(
        tester.element(find.byType(CoopResultPage)),
      );
    }

    List<CheckpointProgress?> checkpoints() =>
        container
            .read(missionProgressStoreProvider(MissionSessionKind.coop))
            .value!
            .checkpoints;

    Future<void> goHome(WidgetTester tester) async {
      await tester.tap(find.text('ホームへ戻る'));
      await tester.pumpAndSettle();
    }

    testWidgets('アプリを終了していた間の、他の人の発見を反映する', (tester) async {
      await openFromHome(
        tester,
        progress: MissionProgressEntity(
          startedAt: createdAt,
          roomCode: code,
          checkpoints: const [null, null, null, null],
        ),
        serverClears: [clear('a', 'other')],
      );

      expect(checkpoints()[0]?.discovererUid, 'other');
    });

    testWidgets('共有の途中で終了した撮影がサーバに届いていたら、写真を履歴に残してから片付ける', (tester) async {
      await openFromHome(
        tester,
        progress: MissionProgressEntity(
          startedAt: createdAt,
          roomCode: code,
          checkpoints: const [
            null,
            CheckpointProgress(userPhotoPath: '/b.jpg'),
            null,
            null,
          ],
        ),
        serverClears: [clear('b', 'me')],
      );

      await goHome(tester);

      expect(histories.histories[code]!.spots[1].userPhotoPath, '/b.jpg');
      expect(find.text('home'), findsOneWidget);
      // 片付けたあとに、終わったルームの進捗を作り直さない
      expect(
        container
            .read(missionProgressStoreProvider(MissionSessionKind.coop))
            .value,
        isNull,
      );
    });

    testWidgets('共有の途中で終了した撮影を確かめられなければ、片付けずにホームへ戻る (写真を消さない)', (tester) async {
      await openFromHome(
        tester,
        progress: MissionProgressEntity(
          startedAt: createdAt,
          roomCode: code,
          checkpoints: const [
            null,
            CheckpointProgress(userPhotoPath: '/b.jpg'),
            null,
            null,
          ],
        ),
        serverClears: [clear('b', 'me')],
        online: false,
      );

      await goHome(tester);

      expect(photos.deleted, isNot(contains('/b.jpg')));
      expect(checkpoints()[1]?.userPhotoPath, '/b.jpg');
      expect(find.text('home'), findsOneWidget);
    });
  });
}
