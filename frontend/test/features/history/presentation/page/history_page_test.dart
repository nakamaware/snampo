import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/application/usecase/get_mission_histories_use_case.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/page/history_page.dart';

class _NoRepository implements IHistoryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeGetHistories extends GetMissionHistoriesUseCase {
  _FakeGetHistories(this.histories) : super(_NoRepository());

  final List<MissionHistory> histories;

  @override
  Future<List<MissionHistory>> call({int? limit, int offset = 0}) async =>
      histories;
}

MissionHistorySpot _spot(int i, {bool isCleared = true}) => MissionHistorySpot(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  sortOrder: i,
  isDestination: false,
  streetViewImagePath: '/sv$i.jpg',
  userPhotoPath: isCleared ? '/p$i.jpg' : null,
  isCleared: isCleared,
);

MissionHistory _history({
  required String id,
  required DateTime startedAt,
  required Duration took,
  required List<MissionHistorySpot> spots,
  CoopHistoryInfo? coop,
}) => MissionHistory(
  id: id,
  startedAt: startedAt,
  completedAt: startedAt.add(took),
  departure: Coordinate(latitude: 35, longitude: 139),
  overviewPolyline: '',
  spots: spots,
  settings: MissionSettings.random(radius: Radius(meters: 1000)),
  coop: coop,
);

Future<void> _pump(WidgetTester tester, List<MissionHistory> histories) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        getMissionHistoriesUseCaseProvider.overrideWithValue(
          _FakeGetHistories(histories),
        ),
      ],
      child: const MaterialApp(home: HistoryPage()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  final at = DateTime(2026, 9, 23, 14, 5);

  group('HistoryPage', () {
    testWidgets('月ごとに見出しを付け、日付・発見数・かかった時間を出す', (tester) async {
      await _pump(tester, [
        _history(
          id: 'a',
          startedAt: at,
          took: const Duration(hours: 1, minutes: 12),
          spots: [_spot(0), _spot(1), _spot(2, isCleared: false)],
        ),
        _history(
          id: 'b',
          startedAt: DateTime(2026, 9, 20, 10, 32),
          took: const Duration(minutes: 48),
          spots: [_spot(0)],
        ),
        _history(
          id: 'c',
          startedAt: DateTime(2026, 8, 30, 9, 15),
          took: const Duration(minutes: 35),
          spots: [_spot(0)],
        ),
      ]);

      expect(find.text('2026年9月'), findsOneWidget);
      expect(find.text('2026年8月'), findsOneWidget);
      expect(find.text('9月23日 (水) 15:17'), findsOneWidget);
      expect(find.text('2/3 発見 · 1時間12分'), findsOneWidget);
    });

    testWidgets('協力プレイには「みんなで」、同期の途中なら「同期中」を出す', (tester) async {
      await _pump(tester, [
        _history(
          id: 'a',
          startedAt: at,
          took: const Duration(minutes: 30),
          spots: [_spot(0)],
          coop: CoopHistoryInfo(
            roomCode: RoomCode.tryParse('ABCD23')!,
            syncState: CoopSyncState.inProgress,
            isHost: true,
            members: const [],
            expiresAt: at,
            deleteAt: at,
          ),
        ),
      ]);

      expect(find.text('みんなで'), findsOneWidget);
      expect(find.text('同期中'), findsOneWidget);
    });

    testWidgets('スポットが 6 つ以上なら、写真は 4 枚と残りの数にする', (tester) async {
      await _pump(tester, [
        _history(
          id: 'a',
          startedAt: at,
          took: const Duration(minutes: 30),
          spots: [for (var i = 0; i < 12; i++) _spot(i)],
        ),
      ]);

      expect(find.text('+8'), findsOneWidget);
    });
  });
}
