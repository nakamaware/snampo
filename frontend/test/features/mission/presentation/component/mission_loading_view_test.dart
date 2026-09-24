import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/mission_loading_view.dart';

void main() {
  testWidgets('ミッションを準備していることを日本語で伝える', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: MissionLoadingView()));
    // 読み込み中のアニメーションは止まらないので、pumpAndSettle は使わない
    await tester.pump();

    expect(find.text('ミッションを準備しています'), findsOneWidget);
    expect(find.text('ルートとスポットを探しています'), findsOneWidget);
    expect(find.text('NOW LOADING'), findsNothing);
  });
}
