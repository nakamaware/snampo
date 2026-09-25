import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/history/presentation/component/history_photo_thumbnail.dart';

void main() {
  group('HistoryPhotoThumbnail', () {
    // 撮った写真も見本も正方形なので、切らずに正方形の枠で見せる
    for (final path in ['/not/found.jpg', null]) {
      testWidgets('列の幅に合わせた正方形で表示する (path: $path)', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: 150,
                  child: HistoryPhotoThumbnail(path: path),
                ),
              ),
            ),
          ),
        );

        final size = tester.getSize(find.byType(HistoryPhotoThumbnail));
        expect(size, const Size(150, 150));
      });
    }
  });
}
