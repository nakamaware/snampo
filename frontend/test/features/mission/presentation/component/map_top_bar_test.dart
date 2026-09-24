import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';

void main() {
  group('MapTopBar', () {
    testWidgets('戻れる画面では、戻るボタンで前の画面へ戻る', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder:
                (context) => TextButton(
                  onPressed:
                      () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder:
                              (_) => const Scaffold(
                                body: Stack(children: [MapTopBar()]),
                              ),
                        ),
                      ),
                  child: const Text('開く'),
                ),
          ),
        ),
      );
      await tester.tap(find.text('開く'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('戻る'));
      await tester.pumpAndSettle();
      expect(find.text('開く'), findsOneWidget);
    });

    testWidgets('最初の画面では戻るボタンを出さず、モードのボタンは右上に並べる', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                MapTopBar(
                  actions: [
                    IconButton(onPressed: null, icon: Icon(Icons.menu)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byTooltip('戻る'), findsNothing);
      expect(find.byIcon(Icons.menu), findsOneWidget);
    });
  });
}
