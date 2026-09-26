import 'dart:developer';

import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/usecase/finalize_coop_history_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_coop_clears_use_case.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';

/// 未確定の協力プレイ履歴について、`clears` と `rooms` を 1 回だけサーバから取得して反映する
/// (監視はしない)
///
/// アプリの起動時と履歴画面を開いたときに呼ぶ。確定の条件は [FinalizeCoopHistoryUseCase] の
/// とおりで、確定したら以後は取りにいかない。サーバから取得できなければ (オフラインなど)、
/// 端末の古いキャッシュで確定しないよう、次の機会に回す。保持期限を過ぎていればサーバの
/// データは消えているので、取りにいかずに確定する (取得できなかった分はプレースホルダを表示する)。
class SyncCoopHistoryUseCase {
  /// [SyncCoopHistoryUseCase] を作成する
  SyncCoopHistoryUseCase({
    required IRoomRepository rooms,
    required IHistoryRepository histories,
    required SyncCoopClearsUseCase syncClears,
    required FinalizeCoopHistoryUseCase finalize,
    DateTime Function()? now,
  }) : _rooms = rooms,
       _histories = histories,
       _syncClears = syncClears,
       _finalize = finalize,
       _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final IHistoryRepository _histories;
  final SyncCoopClearsUseCase _syncClears;
  final FinalizeCoopHistoryUseCase _finalize;
  final DateTime Function() _now;

  /// 同期する
  Future<void> call() async {
    for (final history in await _histories.getInProgressCoopHistories()) {
      final coop = history.coop!;
      if (!_now().isBefore(coop.deleteAt)) {
        await _histories.finalizeCoopHistory(
          coop.roomCode,
          completedAt: coop.expiresAt,
        );
        continue;
      }
      try {
        final room = await _rooms.fetchRoom(coop.roomCode);
        final hasAllThumbs =
            room != null &&
            (await _syncClears(
              coop.roomCode,
              await _rooms.fetchClears(coop.roomCode),
            )).hasAllThumbs;
        await _finalize(
          roomCode: coop.roomCode,
          room: room,
          expiresAt: coop.expiresAt,
          hasAllThumbs: hasAllThumbs,
        );
      } on Object catch (e) {
        // オフラインなどは次の機会に回す
        log('協力プレイの履歴の同期に失敗した: $e', name: 'SyncCoopHistory');
      }
    }
  }
}
