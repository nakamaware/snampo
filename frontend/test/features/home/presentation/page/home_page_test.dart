import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../../../coop/domain/entity/coop_fixtures.dart' as fx;

/// 端末の DB を使わないソロのミッション (続きなし)
class _NoMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => null;
}

/// 端末の DB を使わないソロのミッション (続きあり)
class _SavedMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    destination: ImageCoordinate(
      coordinate: Coordinate(latitude: 35, longitude: 139),
      imageBase64: '',
    ),
    overviewPolyline: 'p',
  );
}

/// 端末の DB を使わない協力プレイ (参加中のルームなし)
class _NoCoopSession extends CoopSessionStore {
  @override
  Future<CoopSession?> build() async => null;
}

/// 端末の DB を使わない協力プレイ (ルーム [fx.code] に参加中)
class _InRoom extends CoopSessionStore {
  @override
  Future<CoopSession?> build() async =>
      CoopSession(roomCode: fx.code, uid: 'me');
}

/// まだ遊べるルーム
Room _playingRoom() =>
    fx.room().copyWith(expiresAt: DateTime.now().add(const Duration(hours: 1)));

/// ホームと、ホームから開く画面 (画面名だけを出す) のルーター
GoRouter _router() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomePage()),
    for (final path in [
      '/setup',
      '/coop',
      '/history',
      '/settings',
      '/mission',
      '/coop/lobby',
      '/coop/result',
    ])
      GoRoute(path: path, builder: (_, _) => Scaffold(body: Text('画面 $path'))),
  ],
);

Future<void> _pumpHome(
  WidgetTester tester, {
  bool hasSavedMission = false,
  Room? room,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        persistedMissionProvider.overrideWith(
          hasSavedMission ? _SavedMission.new : _NoMission.new,
        ),
        coopSessionStoreProvider.overrideWith(
          room != null ? _InRoom.new : _NoCoopSession.new,
        ),
        coopRoomProvider(fx.code).overrideWith((ref) => Stream.value(room)),
      ],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('HomePage', () {
    testWidgets('「ひとりで」「みんなで」「履歴を見る」を出す', (tester) async {
      await _pumpHome(tester);

      expect(find.text('ひとりで'), findsOneWidget);
      expect(find.text('みんなで'), findsOneWidget);
      expect(find.text('履歴を見る'), findsOneWidget);
    });

    testWidgets('「ひとりで」と「みんなで」は同じ大きさ', (tester) async {
      await _pumpHome(tester);

      final solo = tester.getSize(
        find.ancestor(
          of: find.text('ひとりで'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      final coop = tester.getSize(
        find.ancestor(
          of: find.text('みんなで'),
          matching: find.byWidgetPredicate((w) => w is FilledButton),
        ),
      );
      expect(solo, coop);
    });

    for (final (label, path) in [
      ('ひとりで', '/setup'),
      ('みんなで', '/coop'),
      ('履歴を見る', '/history'),
    ]) {
      testWidgets('「$label」で $path を開く', (tester) async {
        await _pumpHome(tester);

        await tester.tap(find.text(label));
        await tester.pumpAndSettle();

        expect(find.text('画面 $path'), findsOneWidget);
      });
    }

    testWidgets('右上の歯車で設定を開く', (tester) async {
      await _pumpHome(tester);

      await tester.tap(find.byTooltip('設定'));
      await tester.pumpAndSettle();

      expect(find.text('画面 /settings'), findsOneWidget);
    });

    testWidgets('続きがなければ、続きのカードを出さない', (tester) async {
      await _pumpHome(tester);

      expect(find.text('つづきがあります'), findsNothing);
    });

    testWidgets('ルームとソロの続きがあれば、1 枚のカードにまとめて出す', (tester) async {
      await _pumpHome(tester, hasSavedMission: true, room: _playingRoom());

      expect(find.text('つづきがあります'), findsOneWidget);
      expect(find.text('ルーム ABCD23 に戻る'), findsOneWidget);
      expect(find.text('ソロの続きをする'), findsOneWidget);
    });

    testWidgets('ルームに戻るで、ロビーを開く', (tester) async {
      await _pumpHome(tester, room: _playingRoom());

      await tester.tap(find.text('ルーム ABCD23 に戻る'));
      await tester.pumpAndSettle();

      expect(find.text('画面 /coop/lobby'), findsOneWidget);
    });

    testWidgets('ルームが終わっていれば、結果を見るで結果画面を開く', (tester) async {
      await _pumpHome(tester, room: fx.room(status: RoomStatus.finished));

      await tester.tap(find.text('ルーム ABCD23 の結果を見る'));
      await tester.pumpAndSettle();

      expect(find.text('画面 /coop/result'), findsOneWidget);
    });

    testWidgets('ソロの続きをするで、ミッションを開く', (tester) async {
      await _pumpHome(tester, hasSavedMission: true);

      await tester.tap(find.text('ソロの続きをする'));
      await tester.pumpAndSettle();

      expect(find.text('画面 /mission'), findsOneWidget);
    });
  });
}
