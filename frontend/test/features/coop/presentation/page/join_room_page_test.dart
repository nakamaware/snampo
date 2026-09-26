import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/presentation/page/join_room_page.dart';

void main() {
  group('JoinRoomPage', () {
    testWidgets('ルームコードの入力欄は、小文字を入力しても大文字にする', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: JoinRoomPage())),
      );

      await tester.enterText(find.byType(TextField), 'ab2cd3');
      await tester.pump();

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, 'AB2CD3');
    });
  });
}
