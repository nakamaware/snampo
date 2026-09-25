import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/coop_mission_effects.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../../domain/entity/coop_fixtures.dart';
import '../coop_store_fakes.dart';

/// 他の人がその場で最後のスポット (GOAL) を発見した状態のストア
///
/// `clears` の反映は [synced] が終わるまで終わらない。
class _FinalDiscoveryStore extends CoopMissionStore {
  _FinalDiscoveryStore(this.synced);

  final Completer<void> synced;

  @override
  CoopMissionState build(RoomCode roomCode) => const CoopMissionState(
    isReady: true,
    finalDiscovery: CoopDiscoveryEvent(
      id: 1,
      spotIndex: 3,
      discovererName: 'other',
    ),
  );

  @override
  Future<void> get clearsSynced => synced.future;
}

void main() {
  group('CoopMissionEffects', () {
    late StreamController<Room> roomUpdates;
    late Completer<void> synced;

    /// 全スポットのクリアで終わったルーム
    Room finishedRoom({DateTime? finishedAt}) =>
        fourSpotRoom(status: RoomStatus.finished).copyWith(
          // 期限切れで結果画面へ移らないよう、遊べる期限内にする
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
          finishReason: FinishReason.allCleared,
          finishedAt: finishedAt,
        );

    /// Mission 画面を開く ([roomUpdates] でルームを、[synced] で `clears` の反映を進める)
    Future<void> openMission(WidgetTester tester) async {
      // 待ち合わせはテストの中で作る (テストの時計で進めるため)
      roomUpdates = StreamController<Room>();
      addTearDown(roomUpdates.close);
      synced = Completer<void>();
      final router = GoRouter(
        initialLocation: '/mission',
        routes: [
          GoRoute(
            path: '/mission',
            builder:
                (_, _) => CoopMissionEffects(
                  roomCode: code,
                  // Mission 画面のように、ミッションと進捗を読んでおく
                  child: Consumer(
                    builder: (context, ref, _) {
                      ref
                        ..watch(
                          persistedMissionProvider(MissionSessionKind.coop),
                        )
                        ..watch(
                          missionProgressStoreProvider(MissionSessionKind.coop),
                        );
                      return const Scaffold(body: Text('mission'));
                    },
                  ),
                ),
          ),
          GoRoute(
            path: '/spot-result',
            builder: (context, state) {
              final args = state.extra! as SpotResultPageArgs;
              return Scaffold(
                body: TextButton(
                  onPressed: () => context.pop(),
                  child: Text('spot ${args.spotIndex} · ${args.closeLabel}'),
                ),
              );
            },
          ),
          GoRoute(
            path: '/coop/result',
            builder: (_, _) => const Scaffold(body: Text('result')),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coopRoomProvider(code).overrideWith((ref) => roomUpdates.stream),
            coopMembersProvider(code).overrideWith((ref) => Stream.value([])),
            coopMissionStoreProvider.overrideWith(
              () => _FinalDiscoveryStore(synced),
            ),
            missionProgressStoreProvider.overrideWith(
              () => ProgressOf(
                MissionProgressEntity(
                  startedAt: createdAt,
                  roomCode: code,
                  checkpoints: const [
                    null,
                    null,
                    null,
                    CheckpointProgress(
                      discovererUid: 'other',
                      discovererNickname: 'other',
                    ),
                  ],
                ),
              ),
            ),
            persistedMissionProvider.overrideWith(FourSpotMission.new),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('終了の確定 (finishedAt) が遅れて届いても、最後のスポットを開いてから結果画面へ移る', (
      tester,
    ) async {
      await openMission(tester);

      // この端末が finished を書いた (まだ終了日時がない) あと、サーバで確定した値が届く
      roomUpdates.add(finishedRoom());
      await tester.pumpAndSettle();
      roomUpdates.add(finishedRoom(finishedAt: DateTime.now()));
      await tester.pumpAndSettle();
      synced.complete();
      await tester.pumpAndSettle();

      expect(find.text('spot 3 · 結果を見る'), findsOneWidget);

      await tester.tap(find.text('spot 3 · 結果を見る'));
      await tester.pumpAndSettle();

      expect(find.text('result'), findsOneWidget);
    });

    testWidgets('clears の反映が終わらなくても (サムネの取得中など)、待ち続けずに最後のスポットを開く', (
      tester,
    ) async {
      await openMission(tester);

      roomUpdates.add(finishedRoom(finishedAt: DateTime.now()));
      await tester.pumpAndSettle();
      expect(find.text('spot 3 · 結果を見る'), findsNothing);

      // 反映は終わらないまま、時間が経つ
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();

      expect(find.text('spot 3 · 結果を見る'), findsOneWidget);
    });
  });
}
