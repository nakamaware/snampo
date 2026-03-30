import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/photo_storage_provider.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/application/usecase/add_mission_history_use_case.dart';
import 'package:snampo/features/history/application/usecase/get_mission_histories_use_case.dart';
import 'package:snampo/features/history/application/usecase/remove_mission_history_use_case.dart';
import 'package:snampo/features/history/data/database/history_database.dart';
import 'package:snampo/features/history/data/repository/history_repository.dart';
import 'package:snampo/features/history/data/streetview_storage.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';

part 'history_provider.g.dart';

/// 履歴専用 Drift DB
@Riverpod(keepAlive: true)
HistoryDatabase historyDatabase(Ref ref) {
  final db = HistoryDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Street View 画像のファイル保存
@riverpod
StreetViewStorage streetViewStorage(Ref ref) {
  return StreetViewStorage();
}

/// 履歴リポジトリ
@riverpod
IHistoryRepository historyRepository(Ref ref) {
  return HistoryRepository(
    ref.watch(historyDatabaseProvider),
    ref.watch(streetViewStorageProvider),
    ref.watch(photoStorageProvider),
  );
}

/// 履歴一覧を取得するユースケース
@riverpod
GetMissionHistoriesUseCase getMissionHistoriesUseCase(Ref ref) {
  return GetMissionHistoriesUseCase(ref.read(historyRepositoryProvider));
}

/// 履歴を 1 件追加するユースケース
@riverpod
AddMissionHistoryUseCase addMissionHistoryUseCase(Ref ref) {
  return AddMissionHistoryUseCase(ref.read(historyRepositoryProvider));
}

/// 履歴を 1 件削除するユースケース
@riverpod
RemoveMissionHistoryUseCase removeMissionHistoryUseCase(Ref ref) {
  return RemoveMissionHistoryUseCase(ref.read(historyRepositoryProvider));
}

/// 履歴一覧 (完了日時の新しい順)。store は持たず DB を read-through する。
@riverpod
Future<List<MissionHistory>> missionHistories(Ref ref) async {
  return ref.read(getMissionHistoriesUseCaseProvider).call();
}

/// id で 1 件 (なければ null)
@riverpod
Future<MissionHistory?> missionHistoryById(Ref ref, String id) async {
  return ref.read(historyRepositoryProvider).getHistoryById(id);
}
