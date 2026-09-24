import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/mission_spot_sheet.dart';
import 'package:snampo/features/mission/presentation/store/mission_sheet_layout_store.dart';

const _todo = MissionSheetSpot(
  referenceImageBase64: '',
  isCleared: false,
  canCapture: true,
);

const _shot = MissionSheetSpot(
  referenceImageBase64: '',
  isCleared: true,
  canCapture: false,
);

Future<void> _pump(
  WidgetTester tester, {
  required List<MissionSheetSpot> spots,
  MissionSheetLayout layout = MissionSheetLayout.carousel,
  ValueChanged<MissionSheetLayout>? onLayoutChanged,
  ValueChanged<int>? onCapture,
  ValueChanged<int>? onShowResult,
  bool showPlayResultButton = false,
  VoidCallback? onShowPlayResult,
  Size size = const Size(393, 852),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MissionSpotSheet(
          spots: spots,
          layout: layout,
          onLayoutChanged: onLayoutChanged ?? (_) {},
          onCapture: onCapture ?? (_) {},
          onShowResult: onShowResult ?? (_) {},
          showPlayResultButton: showPlayResultButton,
          onShowPlayResult: onShowPlayResult,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// 見出しをタップしてシートを開く
Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('ミッション'));
  await tester.pumpAndSettle();
}

void main() {
  group('MissionSpotSheet', () {
    testWidgets('見出しに進み具合とスポットごとのチップを出す', (tester) async {
      await _pump(tester, spots: const [_shot, _todo, _todo]);

      expect(find.text('ミッション'), findsOneWidget);
      expect(find.text('1 / 3 クリア', findRichText: true), findsOneWidget);
      expect(find.bySemanticsLabel('Spot 1 クリア'), findsOneWidget);
      expect(find.bySemanticsLabel('Spot 2 未発見'), findsOneWidget);
    });

    testWidgets('カードの撮影ボタンと「結果を見る」は、そのスポットの番号を渡す', (tester) async {
      final captured = <int>[];
      final shown = <int>[];
      await _pump(
        tester,
        spots: const [_shot, _todo],
        onCapture: captured.add,
        onShowResult: shown.add,
      );
      await _open(tester);

      expect(find.text('撮影済み'), findsOneWidget);
      await tester.tap(find.text('結果を見る'));
      expect(shown, [0]);

      // 2 枚目のカードへめくる
      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('まだ見つけていません'), findsOneWidget);
      await tester.tap(find.text('撮影する'));
      expect(captured, [1]);
    });

    testWidgets('チップを押すと、そのスポットのカードへ移る', (tester) async {
      await _pump(tester, spots: const [_shot, _todo, _todo]);

      await tester.tap(find.bySemanticsLabel('Spot 3 未発見'));
      await tester.pumpAndSettle();

      expect(find.text('Spot 3'), findsWidgets);
      expect(find.text('撮影する'), findsWidgets);
    });

    testWidgets('協力プレイの発見者は「発見: 名前」と表示する', (tester) async {
      await _pump(
        tester,
        spots: const [
          MissionSheetSpot(
            referenceImageBase64: '',
            isCleared: true,
            canCapture: false,
            discovererName: 'たなか',
          ),
        ],
      );
      await _open(tester);

      expect(find.text('発見: たなか'), findsOneWidget);
    });

    testWidgets('撮影できないスポットには、撮影ボタンを出さない', (tester) async {
      await _pump(
        tester,
        spots: const [
          MissionSheetSpot(
            referenceImageBase64: '',
            isCleared: false,
            canCapture: false,
          ),
        ],
      );
      await _open(tester);

      expect(find.text('撮影する'), findsNothing);
    });

    testWidgets('切り替えボタンで、リスト表示を選べる', (tester) async {
      final layouts = <MissionSheetLayout>[];
      await _pump(
        tester,
        spots: const [_shot, _todo],
        onLayoutChanged: layouts.add,
      );

      await tester.tap(find.byTooltip('リストで表示'));
      expect(layouts, [MissionSheetLayout.list]);
    });

    testWidgets('リスト表示では、全スポットを行で並べる', (tester) async {
      final captured = <int>[];
      final shown = <int>[];
      await _pump(
        tester,
        spots: const [_shot, _todo, _todo],
        layout: MissionSheetLayout.list,
        onCapture: captured.add,
        onShowResult: shown.add,
      );
      await _open(tester);

      expect(find.byTooltip('カードで表示'), findsOneWidget);
      // 見出しのチップと行の 2 か所に出る
      expect(find.text('Spot 1'), findsNWidgets(2));
      expect(find.text('Spot 2'), findsNWidgets(2));
      expect(find.text('Spot 3'), findsNWidgets(2));
      expect(find.byTooltip('撮影する'), findsNWidgets(2));

      await tester.tap(find.byTooltip('撮影する').last);
      expect(captured, [2]);
      await tester.tap(find.text('結果'));
      expect(shown, [0]);
    });

    testWidgets('全スポットのクリア後は、見出しに「プレイ結果を見る」を出す', (tester) async {
      var pressed = 0;
      await _pump(
        tester,
        spots: const [_shot, _shot],
        showPlayResultButton: true,
        onShowPlayResult: () => pressed++,
      );

      expect(find.text('2 / 2 クリア', findRichText: true), findsNothing);
      await tester.tap(find.text('プレイ結果を見る'));
      expect(pressed, 1);
    });

    testWidgets('カードの見本をタップすると拡大し、タップで閉じる', (tester) async {
      await _pump(tester, spots: const [_todo]);
      await _open(tester);

      await tester.tap(find.bySemanticsLabel(RegExp('Spot 1 の見本を拡大')));
      await tester.pumpAndSettle();
      expect(find.text('Spot 1 の見本'), findsOneWidget);

      await tester.tap(find.byTooltip('閉じる'));
      await tester.pumpAndSettle();
      expect(find.text('Spot 1 の見本'), findsNothing);
    });

    testWidgets('リストの見本もタップで拡大する', (tester) async {
      await _pump(
        tester,
        spots: const [_todo, _todo],
        layout: MissionSheetLayout.list,
      );
      await _open(tester);

      await tester.tap(find.bySemanticsLabel(RegExp('Spot 2 の見本を拡大')));
      await tester.pumpAndSettle();
      expect(find.text('Spot 2 の見本'), findsOneWidget);
    });

    for (final layout in MissionSheetLayout.values) {
      for (final size in const [Size(320, 667), Size(430, 932)]) {
        for (final count in const [1, 4, 20]) {
          testWidgets('${layout.name} ${size.width.toInt()}x'
              '${size.height.toInt()} で $count スポットでも、はみ出さない', (tester) async {
            await _pump(
              tester,
              spots: [for (var i = 0; i < count; i++) i.isEven ? _shot : _todo],
              layout: layout,
              size: size,
            );
            await _open(tester);
            expect(tester.takeException(), isNull);
          });
        }
      }
    }
  });
}
