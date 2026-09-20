import 'package:snampo/features/history/application/interface/history_repository.dart';

/// 履歴 1 件を削除し、紐づくユーザー写真・Street View ファイルも削除する
class RemoveMissionHistoryUseCase {
  /// [RemoveMissionHistoryUseCase] を作成する
  RemoveMissionHistoryUseCase(this._repository);

  final IHistoryRepository _repository;

  /// [id] に一致する履歴を削除する
  Future<void> call(String id) => _repository.deleteHistory(id);
}
