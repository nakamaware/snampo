import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/presentation/component/leave_room_pop_scope.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

class _FakeCoopSessionStore extends CoopSessionStore {
  bool left = false;

  @override
  Future<CoopSession?> build() async =>
      CoopSession(roomCode: RoomCode.tryParse('ABCD23')!, uid: 'me');

  @override
  void leave() => left = true;
}

void main() {
  group('LeaveRoomPopScope', () {
    late _FakeCoopSessionStore store;

    Future<void> pumpRoom(WidgetTester tester) async {
      store = _FakeCoopSessionStore();
      final router = GoRouter(
        initialLocation: '/room',
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: Text('ホーム')),
            routes: [
              GoRoute(
                path: 'room',
                builder:
                    (_, _) => LeaveRoomPopScope(
                      child: Scaffold(
                        appBar: AppBar(),
                        body: const Text('ルーム'),
                      ),
                    ),
              ),
            ],
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [coopSessionStoreProvider.overrideWith(() => store)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('戻ると、ルームを抜けるかを確認する。キャンセルならルームに残る', (tester) async {
      await pumpRoom(tester);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('ルームを抜けますか?'), findsOneWidget);

      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();
      expect(find.text('ルーム'), findsOneWidget);
      expect(store.left, isFalse);
    });

    testWidgets('抜けると、ルームを抜けてホームへ戻る', (tester) async {
      await pumpRoom(tester);

      final back = tester.state<NavigatorState>(find.byType(Navigator).last);
      await back.maybePop();
      await tester.pumpAndSettle();
      await tester.tap(find.text('抜ける'));
      await tester.pumpAndSettle();

      expect(store.left, isTrue);
      expect(find.text('ホーム'), findsOneWidget);
    });
  });
}
