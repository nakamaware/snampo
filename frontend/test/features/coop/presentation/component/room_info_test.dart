import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:snampo/features/coop/presentation/component/room_info.dart';

import '../../domain/entity/coop_fixtures.dart';

void main() {
  group('RoomInfoSheet', () {
    testWidgets('途中から入る人のために、ルームコードと QR コードとメンバーを表示する', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomInfoSheet(
              room: room(),
              members: [
                member('host'),
                member('me', joinedMinutes: 1),
                member('guest', joinedMinutes: 2, left: true),
              ],
              myUid: 'me',
            ),
          ),
        ),
      );

      expect(find.text('ルーム情報'), findsOneWidget);
      expect(find.text('ABCD23'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('メンバー 2 / 8 人'), findsOneWidget);
      expect(find.text('host'), findsOneWidget);
      expect(find.text('me (あなた)'), findsOneWidget);
      expect(find.text('guest (抜けました)'), findsOneWidget);
    });

    testWidgets('小さい画面でもはみ出さず、スクロールして全部見られる', (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RoomInfoSheet(
              room: room(),
              members: [
                for (var i = 0; i < 5; i++) member('m$i', joinedMinutes: i),
              ],
              myUid: 'm0',
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('m4'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('m4'), findsOneWidget);
    });
  });
}
