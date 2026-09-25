import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/judge_distance_bar.dart';

Future<double> _markerFraction(WidgetTester tester, double meters) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            child: JudgeDistanceBar(
              effectiveDistanceMeters: meters,
              rank: PhotoJudgeRank.good,
            ),
          ),
        ),
      ),
    ),
  );
  final bar = tester.getRect(find.byType(JudgeDistanceBar));
  final marker = tester.getCenter(find.byKey(JudgeDistanceBar.markerKey));
  return (marker.dx - bar.left) / bar.width;
}

void main() {
  group('JudgeDistanceBar', () {
    testWidgets('距離に比例した位置に印を置く', (tester) async {
      expect(await _markerFraction(tester, 15), closeTo(15 / 60, 0.01));
    });

    testWidgets('目盛りより遠ければ右端に置く', (tester) async {
      expect(await _markerFraction(tester, 120), closeTo(1, 0.01));
    });

    testWidgets('判定の名前と区切りの距離を出す', (tester) async {
      await _markerFraction(tester, 15);

      for (final rank in PhotoJudgeRank.values) {
        expect(find.text(rank.label), findsOneWidget);
      }
      expect(find.text('12'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('50 m'), findsOneWidget);
    });
  });
}
