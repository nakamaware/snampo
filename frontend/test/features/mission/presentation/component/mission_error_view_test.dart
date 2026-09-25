import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/mission_error_view.dart';

void main() {
  testWidgets('AppBar を出さずに、やり直せることを日本語で伝える', (tester) async {
    var retried = 0;
    await tester.pumpWidget(
      MaterialApp(home: MissionErrorView(onRetry: () => retried++)),
    );

    expect(find.byType(AppBar), findsNothing);
    expect(find.text('On MISSION'), findsNothing);
    expect(find.text('ミッションを始められませんでした'), findsOneWidget);

    await tester.tap(find.text('もう一度試す'));
    expect(retried, 1);
  });

  testWidgets('詳細は渡したときだけ出す', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MissionErrorView(onRetry: () {}, detail: 'DioException'),
      ),
    );
    expect(find.text('DioException'), findsOneWidget);

    await tester.pumpWidget(
      MaterialApp(home: MissionErrorView(onRetry: () {})),
    );
    expect(find.text('DioException'), findsNothing);
  });

  testWidgets('現在地を取得できなかったときは、位置情報をオンにするよう案内する', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MissionErrorView(onRetry: () {}, locationUnavailable: true),
      ),
    );

    expect(find.text('端末の位置情報をオンにして、\nもう一度お試しください'), findsOneWidget);
    expect(find.text('電波の良い場所で、もう一度お試しください'), findsNothing);
  });
}
