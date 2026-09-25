import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/home/presentation/page/home_page.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// 端末の DB を使わないソロのミッション (続きなし)
class _NoMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async => null;
}

/// 端末の DB を使わない協力プレイ (参加中のルームなし)
class _NoCoopSession extends CoopSessionStore {
  @override
  Future<CoopSession?> build() async => null;
}

/// ホームと、ホームから開く画面 (画面名だけを出す) のルーター
GoRouter _router() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomePage()),
    for (final path in ['/setup', '/coop', '/history', '/settings'])
      GoRoute(path: path, builder: (_, _) => Scaffold(body: Text('画面 $path'))),
  ],
);

Future<void> _pumpHome(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        persistedMissionProvider.overrideWith(_NoMission.new),
        coopSessionStoreProvider.overrideWith(_NoCoopSession.new),
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
  });
}
