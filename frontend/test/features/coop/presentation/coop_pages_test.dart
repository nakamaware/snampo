import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';
import 'package:snampo/features/coop/presentation/page/coop_room_page.dart';
import 'package:snampo/features/coop/presentation/page/join_coop_page.dart';

void main() {
  testWidgets('参加画面はニックネームと 6 桁が無いと参加できない', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: JoinCoopPage())),
    );

    await tester.tap(find.text('参加する'));
    await tester.pump();

    expect(find.text('ニックネームと数字 6 桁のコードを入れてください'), findsOneWidget);
    expect(find.text('QR を読む'), findsOneWidget);
  });

  testWidgets('設定ファイルが無いと参加は Firebase を呼ばない', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: JoinCoopPage())),
    );
    await tester.enterText(find.byType(TextField).at(0), 'ゲスト');
    await tester.enterText(find.byType(TextField).at(1), '123456');
    await tester.tap(find.text('参加する'));
    await tester.pump();

    expect(find.text('Firebase の設定ファイルがまだありません'), findsOneWidget);
  });

  testWidgets('ルーム画面は 6 桁と QR を出す', (tester) async {
    final now = DateTime.utc(2026, 9, 22);
    final session = CoopSession(
      room: CoopRoom.open(
        roomCode: RoomCode('123456'),
        hostId: PlayerId('host'),
        hostNickname: Nickname('ホスト'),
        createdAt: now,
        missionRef: 'rooms/123456/mission/bundle.json',
        spotCount: 2,
      ),
      selfId: PlayerId('host'),
      nickname: Nickname('ホスト'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coopSessionProvider.overrideWith(() => _FixedSession(session)),
        ],
        child: const MaterialApp(home: CoopRoomPage()),
      ),
    );
    await tester.pump();

    expect(find.text('123456'), findsOneWidget);
    expect(find.text('コードをコピー'), findsOneWidget);
    expect(find.text('探索を始める'), findsOneWidget);
  });
}

class _FixedSession extends CoopSessionNotifier {
  _FixedSession(this.session);

  final CoopSession session;

  @override
  CoopSession? build() => session;
}
