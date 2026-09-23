import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';

/// 確定の条件 ([shouldFinalizeHistory]) を満たしていれば、協力プレイの履歴を確定する
///
/// 確定したら以後は同期しない。
class FinalizeCoopHistoryUseCase {
  /// [FinalizeCoopHistoryUseCase] を作成する
  FinalizeCoopHistoryUseCase(this._histories, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final IHistoryRepository _histories;
  final DateTime Function() _now;

  /// 確定したら true を返す
  ///
  /// [room] はサーバから取得したルーム (消えていれば null)。
  /// [hasAllThumbs] はサーバから取得した `clears` と比べて、サムネがそろったか。
  Future<bool> call({
    required RoomCode roomCode,
    required Room? room,
    required DateTime expiresAt,
    required bool hasAllThumbs,
  }) async {
    final now = _now();
    if (!shouldFinalizeHistory(
      room: room,
      expiresAt: expiresAt,
      now: now,
      hasAllThumbs: hasAllThumbs,
    )) {
      return false;
    }
    await _histories.finalizeCoopHistory(
      roomCode,
      completedAt:
          room?.finishedAt ?? (now.isBefore(expiresAt) ? now : expiresAt),
    );
    return true;
  }
}
