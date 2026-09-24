import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';

final _spot = ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  name: 'テストの店',
);

Future<void> _pump(WidgetTester tester, SpotResultPageArgs args) =>
    tester.pumpWidget(MaterialApp(home: SpotResultPage(args: args)));

void main() {
  group('SpotResultPage', () {
    testWidgets('他の人が発見したスポットは、発見者を表示し、自分の採点は表示しない', (tester) async {
      await _pump(
        tester,
        SpotResultPageArgs(
          spotIndex: 0,
          totalCheckpointCount: 3,
          missionPoint: _spot,
          checkpoint: const CheckpointProgress(
            discovererUid: 'other',
            discovererNickname: 'たろう',
          ),
          discovererDisplayName: 'たろう (2)',
        ),
      );

      expect(find.text('発見: たろう (2)'), findsOneWidget);
      expect(find.text('テストの店'), findsOneWidget);
      expect(find.text('判定'), findsNothing);
      expect(find.text('スポットまで残り'), findsNothing);
      expect(find.text('採点結果を表示できませんでした。'), findsNothing);
    });

    testWidgets('発見者も自分の写真もなければ、表示できないと伝える', (tester) async {
      await _pump(
        tester,
        SpotResultPageArgs(
          spotIndex: 0,
          totalCheckpointCount: 3,
          missionPoint: _spot,
          checkpoint: const CheckpointProgress(),
        ),
      );

      expect(find.text('採点結果を表示できませんでした。'), findsOneWidget);
    });
  });
}
