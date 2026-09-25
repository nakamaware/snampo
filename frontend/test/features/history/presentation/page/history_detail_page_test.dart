import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/application/usecase/get_mission_history_use_case.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/page/history_detail_page.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';

class _NoRepository implements IHistoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGetHistory extends GetMissionHistoryUseCase {
  _FakeGetHistory(this.history) : super(_NoRepository());

  final MissionHistory history;

  @override
  Future<MissionHistory?> call(String id) async => history;
}

final _at = DateTime(2026, 9, 23, 14, 5);

MissionHistory _history({CoopHistoryInfo? coop}) => MissionHistory(
  id: 'h',
  startedAt: _at,
  completedAt: _at.add(const Duration(hours: 1, minutes: 12, seconds: 40)),
  departure: Coordinate(latitude: 35, longitude: 139),
  overviewPolyline: '',
  settings: MissionSettings.random(radius: Radius(meters: 1000)),
  coop: coop,
  spots: [
    MissionHistorySpot(
      coordinate: Coordinate(latitude: 35, longitude: 139),
      sortOrder: 0,
      isDestination: false,
      streetViewImagePath: '/sv0.jpg',
      name: '根津神社',
      userPhotoPath: '/p0.jpg',
      judgeRank: PhotoJudgeRank.good,
      distanceErrorMeters: 18.6,
      headingErrorDegrees: -14,
      discovererUid: coop == null ? null : 'me',
      discovererNickname: coop == null ? null : 'ぽんず',
    ),
    MissionHistorySpot(
      coordinate: Coordinate(latitude: 35, longitude: 139),
      sortOrder: 1,
      isDestination: true,
      streetViewImagePath: '/sv1.jpg',
      name: '不忍池',
      isCleared: false,
    ),
  ],
);

Future<void> _pump(WidgetTester tester, MissionHistory history) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const HistoryDetailPage(recordId: 'h'),
      ),
      GoRoute(
        path: '/spot-result',
        builder:
            (_, state) =>
                SpotResultPage(args: state.extra! as SpotResultPageArgs),
      ),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getMissionHistoryUseCaseProvider.overrideWithValue(
          _FakeGetHistory(history),
        ),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HistoryDetailPage', () {
    testWidgets('プレイ結果と同じまとめと、スポットごとの結果を出す', (tester) async {
      await _pump(tester, _history());

      expect(find.text('2026/09/23 15:17 · ひとりで'), findsOneWidget);
      expect(find.text('1時間12分40秒 · ランダム 半径 1000 m'), findsOneWidget);
      expect(find.text('根津神社'), findsOneWidget);
      expect(find.text('スポットまで 18.6 m　向き 左に14.0度'), findsOneWidget);
      expect(find.text('未発見'), findsWidgets);
    });

    testWidgets('協力プレイでは、メンバーごとの発見数と撮った人を出す', (tester) async {
      await _pump(
        tester,
        _history(
          coop: CoopHistoryInfo(
            roomCode: RoomCode.tryParse('ABCD23')!,
            syncState: CoopSyncState.finalized,
            isHost: true,
            members: const [
              CoopHistoryMember(uid: 'other', nickname: 'みさき'),
              CoopHistoryMember(uid: 'me', nickname: 'ぽんず'),
            ],
            expiresAt: _at,
            deleteAt: _at,
          ),
        ),
      );

      expect(find.text('ぽんず (あなた)  1'), findsOneWidget);
      expect(find.text('みさき  0'), findsOneWidget);
      expect(find.text('SPOT 1 · 発見: ぽんず'), findsOneWidget);
    });

    testWidgets('写真をタップすると、見本と上下に並べた全画面を開く', (tester) async {
      await _pump(tester, _history());

      await tester.tap(find.text('見本').first);
      await tester.pumpAndSettle();

      final viewer = tester.widget<PhotoCompareViewer>(
        find.byType(PhotoCompareViewer),
      );
      expect(viewer.photo?.label, 'あなた');
    });

    testWidgets('「くわしく」で、下のボタンのないスポット結果を開く', (tester) async {
      await _pump(tester, _history());

      await tester.tap(find.text('くわしく'));
      await tester.pumpAndSettle();

      final page = tester.widget<SpotResultPage>(find.byType(SpotResultPage));
      expect(page.args.fromSummary, isTrue);
      expect(page.args.referenceImagePath, '/sv0.jpg');
      expect(find.byType(FilledButton), findsNothing);
    });
  });
}
