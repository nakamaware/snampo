import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

ImageCoordinate _spot(String name) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  name: name,
);

final _startedAt = DateTime(2026, 9, 20, 10);

class _Mission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    waypoints: [_spot('湯島天満宮'), _spot('旧岩崎邸庭園')],
    destination: _spot('鈴本演芸場'),
    overviewPolyline: 'p',
    radius: Radius(meters: 1000),
  );
}

class _DestinationMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    waypoints: [_spot('湯島天満宮'), _spot('旧岩崎邸庭園')],
    destination: _spot('上野駅 公園口'),
    overviewPolyline: 'p',
  );
}

/// 7 スポット (3 列になる)。最後の 2 つは未発見
class _ManySpotsMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    waypoints: [for (var i = 1; i <= 6; i++) _spot('スポット$i')],
    destination: _spot('ゴール'),
    overviewPolyline: 'p',
    radius: Radius(meters: 1000),
  );
}

class _Progress extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async =>
      MissionProgressEntity(
        startedAt: _startedAt,
        checkpoints: [
          CheckpointProgress(
            userPhotoPath: '/a.jpg',
            judgeRank: PhotoJudgeRank.good,
            distanceErrorMeters: 15,
            achievedAt: _startedAt.add(const Duration(minutes: 20)),
          ),
          CheckpointProgress(
            userPhotoPath: '/b.jpg',
            judgeRank: PhotoJudgeRank.miss,
            distanceErrorMeters: 80,
            achievedAt: _startedAt.add(
              const Duration(minutes: 58, seconds: 12),
            ),
          ),
          null,
        ],
      );
}

Future<void> _pump(
  WidgetTester tester, {
  PersistedMission Function() mission = _Mission.new,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const ResultPage()),
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
        persistedMissionProvider.overrideWith(mission),
        missionProgressStoreProvider.overrideWith(_Progress.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ResultPage', () {
    testWidgets('発見数・かかった時間・設定・判定の内訳をまとめて出す', (tester) async {
      await _pump(tester);

      expect(find.text('RESULT · ひとりで'), findsOneWidget);
      expect(find.textContaining('スポット発見'), findsOneWidget);
      expect(find.text('58分12秒 · 半径 1000 m'), findsOneWidget);
      expect(find.text('○ 未発見 1'), findsOneWidget);
    });

    testWidgets('スポットが 7 つ以上なら 3 列にし、未発見には札を重ねる', (tester) async {
      await _pump(tester, mission: _ManySpotsMission.new);

      // 進捗は 3 スポット分しかないので、4 番目からは未発見
      expect(find.text('未発見'), findsNWidgets(5));
      expect(find.text('スポット1'), findsNothing);
    });

    testWidgets('目的地指定では、設定に目的地の名前を出す', (tester) async {
      await _pump(tester, mission: _DestinationMission.new);

      expect(find.text('58分12秒 · 目的地指定 · 上野駅 公園口'), findsOneWidget);
    });

    testWidgets('スポットごとに、番号と名前を出す。ソロでは撮った人の名札を付けない', (tester) async {
      await _pump(tester);

      expect(find.text('SPOT 1'), findsOneWidget);
      expect(find.text('湯島天満宮'), findsOneWidget);
      expect(find.text('GOAL · 見本'), findsOneWidget);
      expect(find.text('未発見'), findsOneWidget);
      expect(find.textContaining('あなた'), findsNothing);
    });

    testWidgets('発見したスポットをタップすると、下のボタンのないスポット結果を開く', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('湯島天満宮'));
      await tester.pumpAndSettle();

      expect(find.byType(SpotResultPage), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'ミッションに戻る'), findsNothing);
    });

    testWidgets('未発見のスポットをタップすると、見本だけを大きく見られる', (tester) async {
      await _pump(tester);

      await tester.tap(find.text('鈴本演芸場'));
      await tester.pumpAndSettle();

      final viewer = tester.widget<PhotoCompareViewer>(
        find.byType(PhotoCompareViewer),
      );
      expect(viewer.photo, isNull);
      expect(viewer.caption, 'GOAL · 未発見');
    });
  });
}
