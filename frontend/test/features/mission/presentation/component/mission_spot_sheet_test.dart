import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool tickerEnabled = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: TickerMode(
          enabled: tickerEnabled,
          child: MissionSpotSheet(
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
    ),
  );
  await tester.pumpAndSettle();
}

/// 端末の振動 (HapticFeedback) を記録する
List<String> _recordHaptics(WidgetTester tester) {
  final haptics = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return haptics;
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

    testWidgets('チップは押しやすい高さにする', (tester) async {
      for (final count in const [3, 20]) {
        await _pump(tester, spots: [for (var i = 0; i < count; i++) _todo]);
        expect(
          tester.getSize(find.bySemanticsLabel('Spot 1 未発見')).height,
          40,
          reason: '$count スポット',
        );
      }
    });

    testWidgets('発見したスポットは、番号の代わりに場所の名前を見出しにする', (tester) async {
      await _pump(
        tester,
        spots: const [
          MissionSheetSpot(
            referenceImageBase64: '',
            isCleared: true,
            canCapture: false,
            name: '千葉定吉道場跡',
            discovererName: 'たなか',
          ),
          MissionSheetSpot(
            referenceImageBase64: '',
            isCleared: false,
            canCapture: true,
            name: 'まだ秘密の場所',
          ),
        ],
        layout: MissionSheetLayout.list,
      );
      await _open(tester);

      expect(find.text('千葉定吉道場跡'), findsOneWidget);
      expect(find.text('Spot 1 · 発見: たなか'), findsOneWidget);
      // 見つける前は、答えになる名前を出さない
      expect(find.text('まだ秘密の場所'), findsNothing);
      expect(find.text('見本と同じ景色を探そう'), findsOneWidget);
    });

    testWidgets('スポットがクリアになると、チップに ✓ が現れて振動する', (tester) async {
      final haptics = _recordHaptics(tester);
      await _pump(tester, spots: const [_todo, _todo]);
      expect(find.byIcon(Icons.check), findsNothing);

      await _pump(tester, spots: const [_shot, _todo]);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(haptics, ['HapticFeedbackType.mediumImpact']);

      // もう一度作り直しても、同じスポットでは振動しない
      await _pump(tester, spots: const [_shot, _todo]);
      expect(haptics, hasLength(1));
    });

    testWidgets('画面の裏でクリアになったら、前に戻ったときに ✓ を出して振動する', (tester) async {
      final haptics = _recordHaptics(tester);
      await _pump(tester, spots: const [_todo], tickerEnabled: false);
      await _pump(tester, spots: const [_shot], tickerEnabled: false);
      expect(haptics, isEmpty);
      expect(find.byIcon(Icons.check), findsNothing);

      await _pump(tester, spots: const [_shot]);
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('最初からクリア済みのスポットでは振動しない', (tester) async {
      final haptics = _recordHaptics(tester);
      await _pump(tester, spots: const [_shot, _todo]);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(haptics, isEmpty);
    });

    testWidgets('カードをめくると、軽く振動する', (tester) async {
      await _pump(tester, spots: const [_todo, _todo]);
      await _open(tester);
      final haptics = _recordHaptics(tester);

      await tester.drag(find.byType(PageView), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(haptics, ['HapticFeedbackType.selectionClick']);
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
      expect(find.text('見本と同じ景色を探そう'), findsOneWidget);
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

    testWidgets('リスト表示でチップを押すと、その行が先頭に来る', (tester) async {
      await _pump(
        tester,
        spots: [for (var i = 0; i < 12; i++) _todo],
        layout: MissionSheetLayout.list,
      );

      await tester.tap(find.bySemanticsLabel('Spot 7 未発見'));
      await tester.pumpAndSettle();

      final row = find.text('Spot 7');
      expect(row, findsOneWidget);
      final chipsBottom =
          tester
              .getBottomLeft(
                find.bySemanticsLabel(RegExp(r'Spot \d+ 未発見')).first,
              )
              .dy;
      final rowTop = tester.getTopLeft(row).dy;
      // 見出しの下余白と、行の中で文字が中央にある分だけ、文字はチップより下に来る
      expect(rowTop, greaterThanOrEqualTo(chipsBottom - 1));
      expect(rowTop, lessThan(chipsBottom + 40));
      expect(find.text('Spot 1'), findsNothing);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Spot 7 未発見'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
    });

    testWidgets('リストの位置を保ったまま、見出しの上下スワイプでシートの大きさを変える', (tester) async {
      await _pump(
        tester,
        spots: [for (var i = 0; i < 12; i++) _todo],
        layout: MissionSheetLayout.list,
      );
      await _open(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final sheet = find.byType(CustomScrollView);
      final controller = tester.widget<CustomScrollView>(sheet).controller!;
      final parked = controller.offset;
      expect(parked, greaterThan(100));

      await tester.drag(find.text('ミッション'), const Offset(0, 400));
      await tester.pumpAndSettle();
      final collapsed = tester.getSize(sheet).height;
      expect(collapsed, lessThan(200));
      expect(controller.offset, parked);

      await tester.drag(find.text('ミッション'), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(tester.getSize(sheet).height, greaterThan(collapsed + 200));
      expect(controller.offset, parked);
    });

    testWidgets('チップの隙間をタップすると、近いスポットが選ばれシートは閉じない', (tester) async {
      for (final count in const [3, 20]) {
        // 同じテスト内で作り直すときは、前のシートの状態を残さない
        await tester.pumpWidget(const SizedBox.shrink());
        await _pump(tester, spots: [for (var i = 0; i < count; i++) _todo]);
        await _open(tester);
        final sheet = find.byType(CustomScrollView);
        final opened = tester.getSize(sheet).height;
        final left = tester.getRect(find.bySemanticsLabel('Spot 1 未発見'));
        final right = tester.getRect(find.bySemanticsLabel('Spot 2 未発見'));
        // 見た目の隙間の中点は境目なので、右のチップ側へ寄せる
        final boundary = (left.right + right.left) / 2;

        await tester.tapAt(Offset(boundary + 2, left.center.dy));
        await tester.pumpAndSettle();

        expect(tester.getSize(sheet).height, opened, reason: '$count スポット');
        expect(
          tester
              .getSemantics(find.bySemanticsLabel('Spot 2 未発見'))
              .flagsCollection
              .isSelected,
          Tristate.isTrue,
          reason: '$count スポット',
        );
      }
    });

    testWidgets('タイトルとチップの間をタップしても、シートも選択も変わらない', (tester) async {
      await _pump(tester, spots: const [_todo, _todo, _todo]);
      await _open(tester);
      final sheet = find.byType(CustomScrollView);
      final opened = tester.getSize(sheet).height;
      final chipsTop =
          tester.getTopLeft(find.bySemanticsLabel('Spot 1 未発見')).dy;

      await tester.tapAt(Offset(200, chipsTop - 4));
      await tester.pumpAndSettle();

      expect(tester.getSize(sheet).height, opened);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel('Spot 1 未発見'))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
    });

    testWidgets('チップを縦にドラッグしても、シートの大きさとリストの位置は変わらない', (tester) async {
      await _pump(
        tester,
        spots: [for (var i = 0; i < 12; i++) _todo],
        layout: MissionSheetLayout.list,
      );
      await _open(tester);
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      final sheet = find.byType(CustomScrollView);
      final controller = tester.widget<CustomScrollView>(sheet).controller!;
      final parked = controller.offset;
      final opened = tester.getSize(sheet).height;
      expect(parked, greaterThan(100));

      // リストをずらすと見ている番号が変わり、端のチップは画面の外へ寄る
      Offset? chipCenter;
      for (var i = 1; i <= 12; i++) {
        final center = tester.getCenter(find.bySemanticsLabel('Spot $i 未発見'));
        if (center.dx >= 8 && center.dx <= 385) {
          chipCenter = center;
          break;
        }
      }
      expect(chipCenter, isNotNull);
      await tester.dragFrom(chipCenter!, const Offset(0, 400));
      await tester.pumpAndSettle();

      expect(tester.getSize(sheet).height, opened);
      expect(controller.offset, parked);
    });

    testWidgets('リストをスクロールすると、先頭の行の番号が選ばれる', (tester) async {
      await _pump(
        tester,
        spots: [for (var i = 0; i < 12; i++) _todo],
        layout: MissionSheetLayout.list,
      );
      await _open(tester);

      await tester.timedDrag(
        find.byType(CustomScrollView),
        const Offset(0, -400),
        const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();

      final chipsBottom =
          tester
              .getBottomLeft(
                find.bySemanticsLabel(RegExp(r'Spot \d+ 未発見')).first,
              )
              .dy;
      String? topLabel;
      var topDy = double.infinity;
      for (var i = 1; i <= 12; i++) {
        final row = find.text('Spot $i');
        if (row.evaluate().isEmpty) continue;
        final dy = tester.getTopLeft(row).dy;
        if (dy < chipsBottom - 1 || dy >= topDy) continue;
        topDy = dy;
        topLabel = 'Spot $i 未発見';
      }
      expect(topLabel, isNotNull);
      expect(
        tester
            .getSemantics(find.bySemanticsLabel(topLabel!))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
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
