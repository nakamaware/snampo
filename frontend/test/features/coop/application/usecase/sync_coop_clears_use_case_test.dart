import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';
import '../coop_history_fixture.dart';

void main() {
  late FakeCoopStorage storage;
  late FakeHistoryRepository histories;
  late SyncCoopClearsUseCase syncClears;

  setUp(() async {
    storage = FakeCoopStorage();
    histories = FakeHistoryRepository();
    syncClears = SyncCoopClearsUseCase(storage: storage, histories: histories);
    await seedCoopHistory(histories);
  });

  test('発見者を反映し、不足しているサムネを取得する', () async {
    await syncClears(fx.code, [fx.clear('a', 'x'), fx.clear('b', 'y')]);

    final spots = histories.histories[fx.code]!.spots;
    expect(spots[0].discovererUid, 'x');
    expect(spots[0].discovererThumbPath, 'history:/tmp/download/1.jpg');
    expect(spots[1].discovererUid, 'y');
    expect(spots[1].discovererThumbPath, 'history:/tmp/download/2.jpg');
    expect(spots[2].isCleared, isFalse);
  });

  test('発見者の採点を履歴に反映し、反映済みの発見と一緒に返す', () async {
    const judgement = PhotoJudgement(
      rank: PhotoJudgeRank.excellent,
      distanceErrorMeters: 3,
    );

    final result = await syncClears(fx.code, [
      fx.clear('a', 'x', judgement: judgement),
    ]);

    expect(
      histories.histories[fx.code]!.spots[0].discovererJudgement,
      judgement,
    );
    expect(result.discoveries[fx.spot('a')]!.judgement, judgement);
  });

  test('反映済みの発見と、サムネがそろったかを返す', () async {
    final result = await syncClears(fx.code, [
      fx.clear('a', 'x'),
      fx.clear('b', 'y'),
    ]);

    expect(result.hasAllThumbs, isTrue);
    expect(result.discoveries.keys, [fx.spot('a'), fx.spot('b')]);
    expect(
      result.discoveries[fx.spot('a')]!.thumbPath,
      'history:/tmp/download/1.jpg',
    );
  });

  test('サムネを取得できなければ、発見者だけ反映してそろっていないと返す', () async {
    storage.thumbDownloadError = Exception('network');

    final result = await syncClears(fx.code, [fx.clear('a', 'x')]);

    expect(histories.histories[fx.code]!.spots[0].discovererUid, 'x');
    expect(result.hasAllThumbs, isFalse);
  });

  test('サムネの取得が時間内に終わらなければ、取得できなかった扱いにして先へ進む', () async {
    // 電波が弱く、サムネの取得が終わらない
    storage.thumbDownloadGate = Completer<void>();
    syncClears = SyncCoopClearsUseCase(
      storage: storage,
      histories: histories,
      thumbTimeout: const Duration(milliseconds: 10),
    );

    final result = await syncClears(fx.code, [
      fx.clear('a', 'x'),
      fx.clear('b', 'y'),
    ]).timeout(const Duration(seconds: 1));

    final spots = histories.histories[fx.code]!.spots;
    expect(spots[0].discovererUid, 'x');
    expect(spots[1].discovererUid, 'y');
    expect(spots[0].discovererThumbPath, isNull);
    expect(result.hasAllThumbs, isFalse);
  });

  test('途中経過として、サムネの取得を待たずに、発見者を反映した結果を先に流す', () async {
    // 電波が弱く、サムネの取得が終わらない
    storage.thumbDownloadGate = Completer<void>();

    final first = await syncClears
        .syncInSteps(fx.code, [fx.clear('a', 'x')])
        .first
        .timeout(const Duration(seconds: 1));

    expect(first.discoveries[fx.spot('a')]!.uid, 'x');
    expect(first.discoveries[fx.spot('a')]!.thumbPath, isNull);
    expect(first.hasAllThumbs, isFalse);
  });

  test('途中経過として、サムネを取得するごとに反映した結果を流し、最後に反映し終えた結果を流す', () async {
    final steps =
        await syncClears.syncInSteps(fx.code, [
          fx.clear('a', 'x'),
          fx.clear('b', 'y'),
        ]).toList();

    expect(
      [
        for (final step in steps)
          [
            for (final id in ['a', 'b'])
              step.discoveries[fx.spot(id)]?.thumbPath,
          ],
      ],
      [
        [null, null],
        ['history:/tmp/download/1.jpg', null],
        ['history:/tmp/download/1.jpg', 'history:/tmp/download/2.jpg'],
      ],
    );
    expect(steps.last.hasAllThumbs, isTrue);
  });

  test('途中経過として、サムネを取得できなくても (時間切れを含む)、そのスポットの取得を試し終えた時点の結果を流す', () async {
    // a のサムネは電波が弱く取得が終わらず、b は取得できる
    storage.thumbDownloadGates[fx.clear('a', 'x').thumbPath] =
        Completer<void>();
    syncClears = SyncCoopClearsUseCase(
      storage: storage,
      histories: histories,
      thumbTimeout: const Duration(milliseconds: 10),
    );

    final steps = await syncClears
        .syncInSteps(fx.code, [fx.clear('a', 'x'), fx.clear('b', 'y')])
        .toList()
        .timeout(const Duration(seconds: 1));

    expect(
      [
        for (final step in steps)
          (
            step.thumbAttemptedSpotId,
            step.discoveries[fx.spot('a')]?.thumbPath,
            step.discoveries[fx.spot('b')]?.thumbPath,
          ),
      ],
      [
        (null, null, null),
        (fx.spot('a'), null, null),
        (fx.spot('b'), null, 'history:/tmp/download/1.jpg'),
      ],
    );
  });

  test('取得済みのサムネは取り直さない', () async {
    final clears = [
      fx.clear('a', 'x', thumbPath: 'rooms/ABCD23/thumbs/a/x.jpg'),
    ];
    await syncClears(fx.code, clears);
    final result = await syncClears(fx.code, clears);

    expect(storage.downloadedThumbs, hasLength(1));
    expect(result.hasAllThumbs, isTrue);
  });

  test('履歴がなければ何もしない', () async {
    final result = await syncClears(RoomCode.tryParse('ZZZZ22')!, [
      fx.clear('a', 'x', thumbPath: 'p'),
    ]);

    expect(storage.downloadedThumbs, isEmpty);
    expect(result.hasAllThumbs, isFalse);
  });
}
