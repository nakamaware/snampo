import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/mission/presentation/component/suspend_mission_pop_scope.dart';

void main() {
  /// ホーム → 前の画面 → ミッション画面 と開いた状態にする
  Future<void> openMission(
    WidgetTester tester, {
    required Widget Function(Widget mission) wrap,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('ホーム')),
        ),
        GoRoute(
          path: '/setup',
          builder: (_, _) => const Scaffold(body: Text('前の画面')),
        ),
        GoRoute(
          path: '/mission',
          builder: (_, _) => wrap(const Scaffold(body: Text('ミッション画面'))),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    unawaited(router.push('/setup'));
    await tester.pumpAndSettle();
    unawaited(router.push('/mission'));
    await tester.pumpAndSettle();
  }

  /// 左上の戻るボタンと同じく、戻れるかを確かめてから戻る
  Future<void> pressBack(WidgetTester tester) async {
    await tester.state<NavigatorState>(find.byType(Navigator).last).maybePop();
    await tester.pumpAndSettle();
  }

  Widget solo(Widget mission) =>
      SuspendMissionPopScope(kind: MissionSessionKind.solo, child: mission);

  testWidgets('ソロで戻ると、中断してもホームから再開できることを伝える', (tester) async {
    await openMission(tester, wrap: solo);

    await pressBack(tester);

    expect(find.text('ミッションを中断しますか?'), findsOneWidget);
    expect(find.text('ホームの『ソロの続きをする』から再開できます。'), findsOneWidget);
    expect(find.text('キャンセル'), findsOneWidget);
    expect(find.text('中断する'), findsOneWidget);
  });

  testWidgets('キャンセルすると、ミッション画面に残る', (tester) async {
    await openMission(tester, wrap: solo);

    await pressBack(tester);
    await tester.tap(find.text('キャンセル'));
    await tester.pumpAndSettle();

    expect(find.text('ミッションを中断しますか?'), findsNothing);
    expect(find.text('ミッション画面'), findsOneWidget);
  });

  testWidgets('中断すると、前の画面ではなくホームに戻る', (tester) async {
    await openMission(tester, wrap: solo);

    await pressBack(tester);
    await tester.tap(find.text('中断する'));
    await tester.pumpAndSettle();

    expect(find.text('ミッション画面'), findsNothing);
    expect(find.text('前の画面'), findsNothing);
    expect(find.text('ホーム'), findsOneWidget);
  });

  testWidgets('Android の戻るでも確認する', (tester) async {
    await openMission(tester, wrap: solo);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('ミッションを中断しますか?'), findsOneWidget);
    expect(find.text('ミッション画面'), findsOneWidget);
  });

  testWidgets('協力プレイでは確認せず、モードの画面の確認だけが出る', (tester) async {
    var leaveConfirmed = 0;
    await openMission(
      tester,
      // 協力プレイの画面と同じく、外側でルームを抜けるかを確認する
      wrap:
          (mission) => PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) leaveConfirmed++;
            },
            child: SuspendMissionPopScope(
              kind: MissionSessionKind.coop,
              child: mission,
            ),
          ),
    );

    await pressBack(tester);

    expect(leaveConfirmed, 1);
    expect(find.text('ミッションを中断しますか?'), findsNothing);
  });
}
