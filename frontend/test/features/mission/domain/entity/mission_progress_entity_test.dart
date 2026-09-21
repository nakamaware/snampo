import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

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
}
