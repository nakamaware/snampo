import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// リモートの先着クリアをローカル進捗へマージする。
///
/// 埋まっている slot は触らない。空の slot だけ `achievedAt` を入れる。
/// 写真パスは付けない。
class MergeRemoteClearsUseCase {
  /// [MergeRemoteClearsUseCase] を作成する。
  const MergeRemoteClearsUseCase();

  /// [local] に [remoteClears] を適用した新しい進捗を返す。
  MissionProgressEntity call({
    required MissionProgressEntity local,
    required Iterable<SpotClear> remoteClears,
  }) {
    final checkpoints = List<CheckpointProgress?>.from(local.checkpoints);
    for (final clear in remoteClears) {
      final index = clear.spotId.index;
      if (index >= checkpoints.length) {
        continue;
      }
      if (checkpoints[index] != null) {
        continue;
      }
      checkpoints[index] = CheckpointProgress(achievedAt: clear.clearedAt);
    }
    return local.copyWith(checkpoints: checkpoints);
  }
}
