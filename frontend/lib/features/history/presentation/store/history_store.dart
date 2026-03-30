import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/history/domain/entity/history_persisted_state.dart';
import 'package:snampo/features/history/domain/entity/mission_history_entity.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:uuid/uuid.dart';

part 'history_store.g.dart';

const _uuid = Uuid();

/// 完了ミッションの履歴を SQLite に永続化する
@Riverpod(keepAlive: true)
@JsonPersist()
class HistoryStoreNotifier extends _$HistoryStoreNotifier {
  @override
  Future<HistoryPersistedState> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value ?? const HistoryPersistedState();
  }

  /// 履歴に 1 件追加する (新しい順で先頭に追加)
  void addHistory(MissionEntity mission, MissionProgressEntity progress) {
    final current = state.value ?? const HistoryPersistedState();
    final record = MissionHistoryEntity(
      id: _uuid.v4(),
      completedAt: DateTime.now(),
      mission: mission,
      progress: progress,
    );
    state = AsyncValue.data(
      current.copyWith(records: [record, ...current.records]),
    );
  }

  /// 指定 id の履歴を削除し、紐づく写真ファイルも削除する
  ///
  /// 一覧の整合のため、まず SQLite 上の一覧から外してからファイル削除を行う。
  Future<void> removeHistory(String id) async {
    final current = state.value ?? const HistoryPersistedState();
    final matches = current.records.where((r) => r.id == id).toList();
    if (matches.isEmpty) {
      return;
    }
    final target = matches.first;
    state = AsyncValue.data(
      current.copyWith(
        records: current.records.where((r) => r.id != id).toList(),
      ),
    );
    final photoStorage = ref.read(photoStorageProvider);
    for (final cp in target.progress.checkpoints) {
      if (cp?.userPhotoPath != null) {
        try {
          await photoStorage.deletePhoto(cp!.userPhotoPath!);
        } on Object {
          // 1 件の削除失敗でループを止めない
        }
      }
    }
  }
}
