import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';

void main() {
  testWidgets('判定の内訳を、スポット 1 つずつ高さのある区切りで並べる', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MissionRecap(
            caption: 'RESULT · ひとりで',
            meta: '58分12秒 · 半径 1000 m',
            spots: [
              (found: true, rank: PhotoJudgeRank.good),
              (found: true, rank: PhotoJudgeRank.miss),
              (found: false, rank: null),
            ],
          ),
        ),
      ),
    );

    final segments = find.byWidgetPredicate(
      (w) =>
          w is DecoratedBox &&
          w.decoration is BoxDecoration &&
          ((w.decoration as BoxDecoration).color == PhotoJudgeRank.good.color ||
              (w.decoration as BoxDecoration).color ==
                  PhotoJudgeRank.miss.color),
    );
    expect(segments, findsNWidgets(2));
    for (final element in segments.evaluate()) {
      expect(element.size!.height, 8);
    }
    expect(find.text('○ 未発見 1'), findsOneWidget);
  });
}
