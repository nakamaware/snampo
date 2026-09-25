import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/judge_distance_bar.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';

final _spot = ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  name: 'テストの店',
);

const _ownCapture = CheckpointProgress(
  userPhotoPath: '/not/found.jpg',
  judgeRank: PhotoJudgeRank.good,
  distanceErrorMeters: 18.6,
  headingErrorDegrees: -14,
);

Future<void> _pump(WidgetTester tester, SpotResultPageArgs args) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: SpotResultPage(args: args)));
}

SpotResultPageArgs _args(
  CheckpointProgress checkpoint, {
  bool fromSummary = false,
  String? closeLabel,
  String? discovererDisplayName,
  bool isCoop = false,
}) => SpotResultPageArgs(
  spotIndex: 1,
  totalCheckpointCount: 5,
  missionPoint: _spot,
  checkpoint: checkpoint,
  fromSummary: fromSummary,
  closeLabel: closeLabel,
  discovererDisplayName: discovererDisplayName,
  isCoop: isCoop,
);

void main() {
  group('SpotResultPage', () {
    testWidgets('自分の撮影は、判定・場所・距離・向きのずれを出す', (tester) async {
      await _pump(tester, _args(_ownCapture));

      expect(find.text('SPOT 2 / 5'), findsOneWidget);
      expect(find.text('Good'), findsWidgets);
      expect(find.text('テストの店'), findsOneWidget);
      expect(find.text('18.6 m'), findsOneWidget);
      expect(find.text('左に14.0度'), findsOneWidget);
      expect(find.byType(JudgeDistanceBar), findsOneWidget);
      // ソロでは写真に名札を付けない
      expect(find.text('あなた'), findsNothing);
    });

    testWidgets('協力プレイでは、共有が終わる前でも自分の写真に「あなた」と付ける', (tester) async {
      await _pump(tester, _args(_ownCapture, isCoop: true));

      expect(find.text('あなた'), findsOneWidget);
    });

    testWidgets('ズームして撮ったら、倍率で割った距離で判定したことを出す', (tester) async {
      await _pump(
        tester,
        _args(_ownCapture.copyWith(distanceErrorMeters: 30, zoomLevel: 2)),
      );

      expect(find.text('30.0 m'), findsOneWidget);
      expect(find.text('2x ズームなので 15.0 m として判定'), findsOneWidget);
    });

    testWidgets('プレイ中に開いたら、下のボタンで戻る', (tester) async {
      await _pump(tester, _args(_ownCapture));

      expect(find.widgetWithText(FilledButton, 'ミッションに戻る'), findsOneWidget);
    });

    testWidgets('協力プレイの最後のスポットでは、下のボタンの文言を変えられる', (tester) async {
      await _pump(tester, _args(_ownCapture, closeLabel: '結果を見る'));

      expect(find.widgetWithText(FilledButton, '結果を見る'), findsOneWidget);
    });

    testWidgets('プレイ結果や履歴から開いたら、下のボタンは出さない', (tester) async {
      await _pump(tester, _args(_ownCapture, fromSummary: true));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('向きを取れなかったら、向きのずれは出さない', (tester) async {
      await _pump(
        tester,
        _args(
          const CheckpointProgress(
            userPhotoPath: '/not/found.jpg',
            judgeRank: PhotoJudgeRank.good,
            distanceErrorMeters: 18.6,
          ),
        ),
      );

      expect(find.text('向きのずれ'), findsNothing);
      expect(find.textContaining('取得できませんでした'), findsNothing);
    });

    testWidgets('Miss には「発見済み」を添える', (tester) async {
      await _pump(
        tester,
        _args(_ownCapture.copyWith(judgeRank: PhotoJudgeRank.miss)),
      );

      expect(find.text('発見済み'), findsOneWidget);
    });

    testWidgets('他の人が発見したスポットで採点がなければ、発見者だけを出す', (tester) async {
      await _pump(
        tester,
        _args(
          const CheckpointProgress(
            discovererUid: 'other',
            discovererNickname: 'たろう',
          ),
          discovererDisplayName: 'たろう (2)',
        ),
      );

      expect(find.text('発見: たろう (2)'), findsOneWidget);
      expect(find.text('テストの店'), findsOneWidget);
      expect(find.text('スポットまで'), findsNothing);
      expect(find.text('採点結果を表示できませんでした。'), findsNothing);
    });

    testWidgets('他の人の発見に採点が共有されていれば、発見者の採点を出す', (tester) async {
      await _pump(
        tester,
        _args(
          const CheckpointProgress(
            discovererUid: 'other',
            discovererNickname: 'たろう',
            discovererJudgement: PhotoJudgement(
              rank: PhotoJudgeRank.good,
              distanceErrorMeters: 12.5,
              headingErrorDegrees: -30,
            ),
          ),
        ),
      );

      expect(find.text('たろうの採点'), findsOneWidget);
      expect(find.text('12.5 m'), findsOneWidget);
      expect(find.text('左に30.0度'), findsOneWidget);
    });

    testWidgets('発見者も自分の写真もなければ、表示できないと伝える', (tester) async {
      await _pump(tester, _args(const CheckpointProgress()));

      expect(find.text('採点結果を表示できませんでした。'), findsOneWidget);
    });
  });
}
