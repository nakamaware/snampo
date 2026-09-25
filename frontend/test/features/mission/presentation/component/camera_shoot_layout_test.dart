import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/presentation/component/camera_shoot_layout.dart';

/// 1x1 の透明な PNG
final _png = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, //
  0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, //
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82, //
]);

const _viewfinderKey = Key('viewfinder');

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: CameraShootLayout(
          title: 'Spot 2',
          referenceImage: MemoryImage(_png),
          viewfinder: const ColoredBox(key: _viewfinderKey, color: Colors.grey),
          controls: const Text('シャッター'),
        ),
      ),
    ),
  );
}

Rect _reference(WidgetTester tester) =>
    tester.getRect(find.bySemanticsLabel('見本を拡大'));

void main() {
  group('CameraShootLayout', () {
    testWidgets('ファインダーは画面幅の正方形で、見本はその上に重ならずに出す', (tester) async {
      await _pump(tester, const Size(411, 843));

      final viewfinder = tester.getRect(find.byKey(_viewfinderKey));
      expect(viewfinder.size, const Size(411, 411));

      final reference = _reference(tester);
      expect(reference.width, reference.height);
      expect(
        reference.width,
        greaterThanOrEqualTo(CameraShootLayout.minReferenceSize),
      );
      expect(reference.bottom, lessThanOrEqualTo(viewfinder.top));
      expect(find.text('シャッター'), findsOneWidget);
    });

    testWidgets('画面が低いときは、見本をファインダーの左下に重ねる', (tester) async {
      await _pump(tester, const Size(360, 600));

      final viewfinder = tester.getRect(find.byKey(_viewfinderKey));
      expect(viewfinder.width, viewfinder.height);
      final reference = _reference(tester);
      expect(reference.left, greaterThan(viewfinder.left));
      expect(reference.bottom, lessThan(viewfinder.bottom));
      expect(reference.top, greaterThan(viewfinder.center.dy));
      expect(find.text('シャッター'), findsOneWidget);
    });

    testWidgets('見本をタップすると大きく出し、もう一度タップで閉じる', (tester) async {
      await _pump(tester, const Size(411, 843));
      expect(find.text('タップで閉じる'), findsNothing);

      await tester.tap(find.bySemanticsLabel('見本を拡大'));
      await tester.pump();
      expect(find.text('タップで閉じる'), findsOneWidget);

      await tester.tap(find.text('タップで閉じる'));
      await tester.pump();
      expect(find.text('タップで閉じる'), findsNothing);
    });

    testWidgets('戻るボタンで onBack を呼ぶ', (tester) async {
      var backCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CameraShootLayout(
              title: 'Spot 1',
              referenceImage: MemoryImage(_png),
              viewfinder: const SizedBox(),
              controls: const SizedBox(),
              onBack: () => backCount++,
            ),
          ),
        ),
      );

      await tester.tap(find.byTooltip('戻る'));
      expect(backCount, 1);
    });
  });
}
