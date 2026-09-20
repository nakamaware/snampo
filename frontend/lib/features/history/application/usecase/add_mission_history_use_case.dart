import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:uuid/uuid.dart';

/// 完了ミッションを履歴に 1 件追加する
class AddMissionHistoryUseCase {
  /// [AddMissionHistoryUseCase] を作成する
  AddMissionHistoryUseCase(this._repository, [Uuid? uuid])
    : _uuid = uuid ?? const Uuid();

  final IHistoryRepository _repository;
  final Uuid _uuid;

  /// 履歴を保存する (新しい id を採番して Drift に書き込む)
  Future<void> call({
    required MissionEntity mission,
    required MissionProgressEntity progress,
  }) async {
    final id = _uuid.v4();
    await _repository.insertHistory(
      id: id,
      mission: mission,
      progress: progress,
    );
  }
}
