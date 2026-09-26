import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';

void main() {
  group('showNicknameDialog', () {
    testWidgets('決定すると入力した値を返し、閉じるアニメーション中もエラーにならない', (tester) async {
      Future<String?>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed: () => result = showNicknameDialog(context),
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'たろう');
      await tester.tap(find.text('決定'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(await result, 'たろう');
    });

    testWidgets('キャンセルすると null を返す', (tester) async {
      Future<String?>? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () =>
                          result = showNicknameDialog(
                            context,
                            initialValue: 'はなこ',
                          ),
                  child: const Text('open'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('はなこ'), findsOneWidget);
      await tester.tap(find.text('キャンセル'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(await result, isNull);
    });
  });
}
