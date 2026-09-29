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
      expect(find.text('me'), findsOneWidget);
      expect(find.text('あなた'), findsOneWidget);
      // ゲーム中は名前を変えられない
      expect(find.byTooltip('名前を変える'), findsNothing);
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

  group('RoomMembersCard', () {
    Widget card({required bool isAuto, VoidCallback? onEdit}) => MaterialApp(
      home: Scaffold(
        body: RoomMembersCard(
          members: [member('host'), member('me', joinedMinutes: 1)],
          hostId: 'host',
          myUid: 'me',
          isMyNicknameAuto: isAuto,
          onEditMyNickname: onEdit,
        ),
      ),
    );

    testWidgets('おまかせの名前なら、自分の行に変えられることを示す', (tester) async {
      var edits = 0;
      await tester.pumpWidget(card(isAuto: true, onEdit: () => edits++));

      expect(find.text('おまかせ'), findsOneWidget);
      expect(find.text('タップして変える'), findsOneWidget);

      await tester.tap(find.text('me'));
      await tester.tap(find.byTooltip('名前を変える'));
      expect(edits, 2);
    });

    testWidgets('自分で付けた名前なら、おまかせの表示を出さない', (tester) async {
      await tester.pumpWidget(card(isAuto: false, onEdit: () {}));

      expect(find.text('おまかせ'), findsNothing);
      expect(find.byTooltip('名前を変える'), findsOneWidget);
    });

    testWidgets('変えられないとき (開始後) は、おまかせでも表示しない', (tester) async {
      await tester.pumpWidget(card(isAuto: true));

      expect(find.text('おまかせ'), findsNothing);
      expect(find.byTooltip('名前を変える'), findsNothing);
    });
  });
  group('duplicateNicknameSnackBar', () {
    testWidgets('番号の付いた名前を知らせ、「変える」で名前を変えられる', (tester) async {
      var edits = 0;
      final snackBar = duplicateNicknameSnackBar(
        displayName: 'hanako(2)',
        onChange: () => edits++,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder:
                  (context) => TextButton(
                    onPressed:
                        () => ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(snackBar),
                    child: const Text('show'),
                  ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('show'));
      await tester.pumpAndSettle();

      expect(find.text('同じ名前の人がいるため「hanako(2)」と表示されます'), findsOneWidget);
      // 操作を止めないよう、ボタンがあっても時間が経てば消す
      expect(snackBar.persist, isFalse);

      await tester.tap(find.text('変える'));
      expect(edits, 1);
    });
  });
}
