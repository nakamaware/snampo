import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

/// 保存済みミッション履歴を id で 1 件取得する
class GetMissionHistoryUseCase {
  /// [GetMissionHistoryUseCase] を作成する
  GetMissionHistoryUseCase(this._repository);

  final IHistoryRepository _repository;

  /// [id] に一致する履歴。見つからない場合は null
  Future<MissionHistory?> call(String id) => _repository.getHistoryById(id);
}
