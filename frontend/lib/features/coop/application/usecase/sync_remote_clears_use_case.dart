import 'dart:io';

import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/application/usecase/merge_remote_clears_use_case.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// リモートクリアを進捗へ反映し、写真を端末へ保存する。
class SyncRemoteClearsUseCase {
  /// [SyncRemoteClearsUseCase] を作成する。
  const SyncRemoteClearsUseCase({
    this.merge = const MergeRemoteClearsUseCase(),
  });

  /// 空スロットへ `achievedAt` を入れる処理。
  final MergeRemoteClearsUseCase merge;

  /// [clears] を [local] に反映する。
  Future<SyncRemoteClearsResult> call({
    required CoopBackend backend,
    required MissionProgressEntity local,
    required List<SpotClear> clears,
    required Directory photoDirectory,
  }) async {
    final merged = merge(local: local, remoteClears: clears);
    final checkpoints = List<CheckpointProgress?>.from(merged.checkpoints);
    final discoverers = <int, String>{};

    for (final clear in clears) {
      final index = clear.spotId.index;
      if (index < 0 || index >= checkpoints.length) {
        continue;
      }
      discoverers[index] = clear.nickname.value;
      final slot = checkpoints[index];
      if (slot == null || slot.userPhotoPath != null) {
        continue;
      }
      final bytes = await backend.getBytes(clear.thumbPath);
      if (bytes == null || bytes.isEmpty) {
        continue;
      }
      final file = File('${photoDirectory.path}/${clear.spotId.value}.jpg');
      await file.writeAsBytes(bytes, flush: true);
      checkpoints[index] = slot.copyWith(userPhotoPath: file.path);
    }

    return SyncRemoteClearsResult(
      progress: merged.copyWith(checkpoints: checkpoints),
      discoverers: discoverers,
    );
  }
}

/// [SyncRemoteClearsUseCase] の結果。
class SyncRemoteClearsResult {
  /// [SyncRemoteClearsResult] を作成する。
  const SyncRemoteClearsResult({
    required this.progress,
    required this.discoverers,
  });

  /// 反映後の進捗。
  final MissionProgressEntity progress;

  /// 地点 index から発見者名。
  final Map<int, String> discoverers;
}
