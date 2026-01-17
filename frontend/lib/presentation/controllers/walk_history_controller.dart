import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/models/walk_history.dart';
import 'package:snampo/repositories/walk_history_repository.dart';

part 'walk_history_controller.g.dart';

/// 散歩履歴リポジトリのプロバイダー
@riverpod
WalkHistoryRepository walkHistoryRepository(Ref ref) {
  return WalkHistoryRepository();
}

/// 散歩履歴を管理するコントローラー
@riverpod
class WalkHistoryController extends _$WalkHistoryController {
  @override
  Future<List<WalkHistory>> build() async {
    final repository = ref.read(walkHistoryRepositoryProvider);
    return repository.getAllHistories();
  }

  /// 履歴を追加する
  ///
  /// [history] は追加する履歴
  Future<void> addHistory(WalkHistory history) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(walkHistoryRepositoryProvider);
      await repository.saveHistory(history);
      // 状態を更新
      final histories = await repository.getAllHistories();
      state = AsyncValue.data(histories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 指定されたIDの履歴を取得する
  ///
  /// [id] は履歴のID
  Future<WalkHistory?> getHistoryById(String id) async {
    try {
      final repository = ref.read(walkHistoryRepositoryProvider);
      return repository.getHistoryById(id);
    } catch (e) {
      // エラーが発生した場合は再スロー
      // 呼び出し側でエラーハンドリングを行う
      rethrow;
    }
  }

  /// 指定されたIDの履歴を削除する
  ///
  /// [id] は削除する履歴のID
  Future<void> deleteHistory(String id) async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(walkHistoryRepositoryProvider);
      await repository.deleteHistory(id);
      // 状態を更新
      final histories = await repository.getAllHistories();
      state = AsyncValue.data(histories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// すべての履歴を削除する
  Future<void> clearAllHistories() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(walkHistoryRepositoryProvider);
      await repository.clearAllHistories();
      // 状態を更新
      final histories = await repository.getAllHistories();
      state = AsyncValue.data(histories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// 履歴リストを再読み込みする
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final repository = ref.read(walkHistoryRepositoryProvider);
      final histories = await repository.getAllHistories();
      state = AsyncValue.data(histories);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
