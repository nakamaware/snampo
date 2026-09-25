import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/core/domain/photo_judgement.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

void main() {
  group('CheckpointProgress.fromJson', () {
    test('旧形式の judgeRank: retry を miss として復元する', () {
      final progress = CheckpointProgress.fromJson(const {
        'judgeRank': 'retry',
      });

      expect(progress.judgeRank, PhotoJudgeRank.miss);
    });

    test('現行の judgeRank 値をそのまま復元する', () {
      final progress = CheckpointProgress.fromJson(const {
        'judgeRank': 'excellent',
      });

      expect(progress.judgeRank, PhotoJudgeRank.excellent);
    });

    test('ズームの倍率を保存して読み戻せる (古いデータにはない)', () {
      const progress = CheckpointProgress(zoomLevel: 2);

      expect(CheckpointProgress.fromJson(progress.toJson()).zoomLevel, 2);
      expect(CheckpointProgress.fromJson(const {}).zoomLevel, isNull);
    });

    test('judgeRank が null の場合は null のまま復元する', () {
      final progress = CheckpointProgress.fromJson(const {});

      expect(progress.judgeRank, isNull);
    });
  });

  group('MissionProgressEntity.fromJson', () {
    test('retry を含む永続化データを例外なく復元できる (再開時クラッシュの回帰)', () {
      final entity = MissionProgressEntity.fromJson({
        'startedAt': DateTime(2024).toIso8601String(),
        'checkpoints': [
          {'judgeRank': 'retry'},
          null,
        ],
      });

      expect(entity.checkpoints[0]?.judgeRank, PhotoJudgeRank.miss);
      expect(entity.checkpoints[1], isNull);
    });
  });

  group('MissionProgressEntity.withCoopDiscoveries', () {
    final roomA = RoomCode.tryParse('AAAA22')!;
    final roomB = RoomCode.tryParse('BBBB22')!;
    final clearedAt = DateTime.utc(2026, 9, 23);

    MissionProgressEntity progress(RoomCode? roomCode) => MissionProgressEntity(
      startedAt: clearedAt,
      roomCode: roomCode,
      checkpoints: const [null, null],
    );

    test('同じルームの発見を「発見者情報つき・自分の写真なし」で反映する', () {
      final updated = progress(roomA).withCoopDiscoveries(roomA, {
        1: (
          uid: 'x',
          nickname: 'はなこ',
          clearedAt: clearedAt,
          thumbPath: '/t.jpg',
          judgement: null,
        ),
      });

      expect(updated.checkpoints[0], isNull);
      final checkpoint = updated.checkpoints[1]!;
      expect(checkpoint.discovererUid, 'x');
      expect(checkpoint.discovererNickname, 'はなこ');
      expect(checkpoint.discovererThumbPath, '/t.jpg');
      expect(checkpoint.userPhotoPath, isNull);
    });

    test('発見者の採点も反映し、保存して読み戻せる', () {
      const judgement = PhotoJudgement(
        rank: PhotoJudgeRank.good,
        distanceErrorMeters: 18,
        headingErrorDegrees: 5,
      );

      final updated = progress(roomA).withCoopDiscoveries(roomA, {
        0: (
          uid: 'x',
          nickname: 'はなこ',
          clearedAt: clearedAt,
          thumbPath: null,
          judgement: judgement,
        ),
      });

      expect(updated.checkpoints[0]!.discovererJudgement, judgement);
      final restored = MissionProgressEntity.fromJson(
        jsonDecode(jsonEncode(updated.toJson())) as Map<String, dynamic>,
      );
      expect(restored.checkpoints[0]!.discovererJudgement, judgement);
    });

    test('別のルームの発見は反映しない (抜けた前のルームの通知が混ざらないように)', () {
      final current = progress(roomB);

      final updated = current.withCoopDiscoveries(roomA, {
        0: (
          uid: 'x',
          nickname: 'はなこ',
          clearedAt: clearedAt,
          thumbPath: null,
          judgement: null,
        ),
      });

      expect(updated, current);
    });

    test('ソロの進捗には反映しない', () {
      final current = progress(null);

      expect(
        current.withCoopDiscoveries(roomA, {
          0: (
            uid: 'x',
            nickname: 'はなこ',
            clearedAt: clearedAt,
            thumbPath: null,
            judgement: null,
          ),
        }),
        current,
      );
    });

    test('発見者が同じなら、新しいサムネがなくても取得済みのサムネを残す', () {
      final withThumb = progress(roomA).withCoopDiscoveries(roomA, {
        0: (
          uid: 'x',
          nickname: 'はなこ',
          clearedAt: clearedAt,
          thumbPath: '/t.jpg',
          judgement: null,
        ),
      });

      final updated = withThumb.withCoopDiscoveries(roomA, {
        0: (
          uid: 'x',
          nickname: 'はなこ',
          clearedAt: clearedAt,
          thumbPath: null,
          judgement: null,
        ),
      });

      expect(updated.checkpoints[0]!.discovererThumbPath, '/t.jpg');
    });
  });

  group('MissionProgressEntity.withCapture', () {
    final startedAt = DateTime(2024);
    final discoveredAt = DateTime(2024, 1, 2);
    final roomCode = RoomCode.tryParse('ABCD23')!;
    final capture = CheckpointProgress(
      userPhotoPath: '/mine.jpg',
      judgeRank: PhotoJudgeRank.good,
      distanceErrorMeters: 20,
      achievedAt: DateTime(2024, 1, 3),
    );

    test('未挑戦のスポットには、撮影の記録をそのまま入れる', () {
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        checkpoints: const [null, null],
      );

      expect(entity.withCapture(1, capture).checkpoints, [null, capture]);
    });

    test('発見者がいれば、発見者の情報 (採点を含む) と発見日時を残す', () {
      const judgement = PhotoJudgement(
        rank: PhotoJudgeRank.fair,
        distanceErrorMeters: 30,
        zoomLevel: 2,
      );
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        roomCode: roomCode,
        checkpoints: [
          CheckpointProgress(
            achievedAt: discoveredAt,
            discovererUid: 'other',
            discovererNickname: 'じろう',
            discovererThumbPath: '/thumb.jpg',
            discovererJudgement: judgement,
          ),
        ],
      );

      expect(
        entity.withCapture(0, capture).checkpoints.single,
        capture.copyWith(
          achievedAt: discoveredAt,
          discovererUid: 'other',
          discovererNickname: 'じろう',
          discovererThumbPath: '/thumb.jpg',
          discovererJudgement: judgement,
        ),
      );
    });

    test('範囲外のインデックスなら何も変えない', () {
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        checkpoints: const [null],
      );

      expect(entity.withCapture(1, capture), same(entity));
    });
  });

  group('MissionProgressEntity.withoutCapture', () {
    final startedAt = DateTime(2024);
    final roomCode = RoomCode.tryParse('ABCD23')!;

    test('撮影の記録を捨てて未挑戦 (null) に戻す', () {
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        roomCode: roomCode,
        checkpoints: [
          CheckpointProgress(
            userPhotoPath: '/mine.jpg',
            judgeRank: PhotoJudgeRank.good,
            achievedAt: startedAt,
          ),
          null,
        ],
      );

      expect(entity.withoutCapture(roomCode, 0).checkpoints, [null, null]);
    });

    test('別のルームの進捗なら何も変えない (進捗が次のルームに入れ替わったあと)', () {
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        roomCode: RoomCode.tryParse('WXYZ89'),
        checkpoints: [const CheckpointProgress(userPhotoPath: '/next.jpg')],
      );

      expect(entity.withoutCapture(roomCode, 0), same(entity));
    });

    test('発見者の情報があれば、それだけを残す', () {
      final entity = MissionProgressEntity(
        startedAt: startedAt,
        roomCode: roomCode,
        checkpoints: [
          CheckpointProgress(
            userPhotoPath: '/mine.jpg',
            judgeRank: PhotoJudgeRank.good,
            achievedAt: startedAt,
            discovererUid: 'other',
            discovererNickname: 'じろう',
            discovererThumbPath: '/thumb.jpg',
            discovererJudgement: const PhotoJudgement(
              rank: PhotoJudgeRank.fair,
              distanceErrorMeters: 30,
            ),
          ),
        ],
      );

      expect(
        entity.withoutCapture(roomCode, 0).checkpoints.single,
        CheckpointProgress(
          achievedAt: startedAt,
          discovererUid: 'other',
          discovererNickname: 'じろう',
          discovererThumbPath: '/thumb.jpg',
          discovererJudgement: const PhotoJudgement(
            rank: PhotoJudgeRank.fair,
            distanceErrorMeters: 30,
          ),
        ),
      );
    });
  });

  test(
    'MissionProgressEntity.unsharedCaptureIndexes: 写真はあるが発見者がいない撮影の番号を返す',
    () {
      final entity = MissionProgressEntity(
        startedAt: DateTime(2024),
        checkpoints: const [
          CheckpointProgress(userPhotoPath: '/unshared.jpg'),
          CheckpointProgress(userPhotoPath: '/mine.jpg', discovererUid: 'me'),
          CheckpointProgress(discovererUid: 'other'),
          null,
        ],
      );

      expect(entity.unsharedCaptureIndexes, [0]);
    },
  );

  group('PhotoJudgement', () {
    test('CheckpointProgress.judgement は、ズームの倍率も採点に含める', () {
      const checkpoint = CheckpointProgress(
        judgeRank: PhotoJudgeRank.good,
        distanceErrorMeters: 30,
        zoomLevel: 2,
      );
      final judgement = checkpoint.judgement;

      expect(judgement?.zoomLevel, 2);
      expect(PhotoJudgement.fromJson(judgement!.toJson()).zoomLevel, 2);
    });
  });
}
