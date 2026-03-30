import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 完了ミッションを履歴に保存し、履歴一覧プロバイダーを無効化する
///
/// ミッション画面など mission 側からは本関数だけを呼ぶ。
Future<void> recordCompletedMission(
  WidgetRef ref, {
  required MissionEntity mission,
  required MissionProgressEntity progress,
}) async {
  await ref
      .read(addMissionHistoryUseCaseProvider)
      .call(mission: mission, progress: progress);
  ref.invalidate(missionHistoriesProvider);
}

/// 履歴を 1 件削除し、関連プロバイダーを無効化する
Future<void> removeCompletedMission(WidgetRef ref, String id) async {
  await ref.read(removeMissionHistoryUseCaseProvider).call(id);
  ref
    ..invalidate(missionHistoriesProvider)
    ..invalidate(missionHistoryByIdProvider(id));
}
