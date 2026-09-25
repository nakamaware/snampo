import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';

Future<void> _pump(WidgetTester tester, {ComparePhoto? photo}) =>
    tester.pumpWidget(
      MaterialApp(
        home: PhotoCompareViewer(
          title: '谷中ぎんざ',
          caption: 'SPOT 2 / 5',
          reference: const ComparePhoto(label: '見本', image: null),
          photo: photo,
        ),
      ),
    );

List<InteractiveViewer> _viewers(WidgetTester tester) =>
    tester
        .widgetList<InteractiveViewer>(find.byType(InteractiveViewer))
        .toList();

void main() {
  group('PhotoCompareViewer', () {
    testWidgets('見本を上、撮った写真を下に、同じ大きさで並べる', (tester) async {
      await _pump(
        tester,
        photo: const ComparePhoto(label: 'あなた', image: null, isMine: true),
      );

      final reference = tester.getRect(find.text('見本'));
      final photo = tester.getRect(find.text('あなた'));
      expect(reference.top, lessThan(photo.top));
      expect(reference.left, photo.left);
      final frames = find.byType(InteractiveViewer);
      expect(tester.getSize(frames.first), tester.getSize(frames.last));
    });

    testWidgets('ダブルタップすると 2 枚とも同じ倍率で拡大し、もう一度で戻る', (tester) async {
      await _pump(tester, photo: const ComparePhoto(label: 'あなた', image: null));
      final bottom = find.byType(InteractiveViewer).last;

      await tester.tap(bottom);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(bottom);
      await tester.pumpAndSettle();

      for (final viewer in _viewers(tester)) {
        expect(
          viewer.transformationController!.value.getMaxScaleOnAxis(),
          PhotoCompareViewer.doubleTapScale,
        );
      }

      await tester.tap(bottom);
      await tester.pump(kDoubleTapMinTime);
      await tester.tap(bottom);
      await tester.pumpAndSettle();

      expect(
        _viewers(
          tester,
        ).first.transformationController!.value.getMaxScaleOnAxis(),
        1,
      );
    });

    testWidgets('撮った写真がなければ、見本だけを出す', (tester) async {
      await _pump(tester);

      expect(find.text('見本'), findsOneWidget);
      expect(_viewers(tester), hasLength(1));
    });
  });
}
