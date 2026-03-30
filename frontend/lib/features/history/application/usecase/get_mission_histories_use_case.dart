import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 保存済みミッション履歴の一覧を取得する (完了日時の新しい順)
class GetMissionHistoriesUseCase {
  /// [GetMissionHistoriesUseCase] を作成する
  GetMissionHistoriesUseCase(this._repository);

  final IHistoryRepository _repository;

  /// 履歴一覧を返す
  Future<List<MissionHistory>> call({int? limit, int offset = 0}) {
    return _repository.getHistories(limit: limit, offset: offset);
  }
}
