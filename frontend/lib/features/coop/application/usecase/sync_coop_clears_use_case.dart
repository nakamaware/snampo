import 'dart:developer';

import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';

/// サーバの `clears` と履歴 (端末のキャッシュ) を比べ、不足分を取得して履歴に反映する
///
/// 基本方針は「サーバ (`clears`) が正で、端末は差分を取りにいく」。
/// `clears` の通知が届いたとき、ルームに戻ったとき、[SyncCoopHistoryUseCase] から呼ぶ。
class SyncCoopClearsUseCase {
  /// [SyncCoopClearsUseCase] を作成する
  SyncCoopClearsUseCase({
    required ICoopStorage storage,
    required IHistoryRepository histories,
  }) : _storage = storage,
       _histories = histories;

  final ICoopStorage _storage;
  final IHistoryRepository _histories;

  /// 反映する
  Future<void> call(String roomCode, List<SpotClear> clears) async {
    final history = await _histories.getCoopHistory(roomCode);
    if (history == null) {
      return;
    }
    final plan = planClearSync(
      clears: clears,
      local: {
        for (final spot in history.spots)
          if (spot.spotId != null)
            spot.spotId!: LocalClearState(
              discovererUid: spot.discovererUid,
              hasThumb: spot.discovererThumbPath != null,
            ),
      },
    );
    for (final clear in plan.discoverersToApply) {
      await _histories.applyCoopDiscoverer(
        roomCode: roomCode,
        spotId: clear.spotId,
        discovererUid: clear.clearedBy,
        discovererNickname: clear.nickname,
        clearedAt: clear.clearedAt,
      );
    }
    for (final clear in plan.thumbsToFetch) {
      try {
        final downloaded = await _storage.downloadThumb(clear.thumbPath!);
        await _histories.saveCoopThumb(
          roomCode: roomCode,
          spotId: clear.spotId,
          sourcePath: downloaded,
        );
      } on Object catch (e) {
        // 次の同期で取り直す
        log('サムネの取得に失敗した: $e', name: 'SyncCoopClears');
      }
    }
  }
}

/// 未確定の協力プレイ履歴について、`clears` と `rooms` を 1 回だけ取得して反映する (監視はしない)
///
/// アプリの起動時と履歴画面を開いたときに呼ぶ。ルームが finished か、遊べる期限を過ぎていれば
/// 「確定」にして、以後は取りにいかない。保持期限を過ぎていればサーバのデータは消えているので、
/// 取りにいかずに確定する (取得できなかった分はプレースホルダを表示する)。
class SyncCoopHistoryUseCase {
  /// [SyncCoopHistoryUseCase] を作成する
  SyncCoopHistoryUseCase({
    required IRoomRepository rooms,
    required IHistoryRepository histories,
    required SyncCoopClearsUseCase syncClears,
    DateTime Function()? now,
  }) : _rooms = rooms,
       _histories = histories,
       _syncClears = syncClears,
       _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final IHistoryRepository _histories;
  final SyncCoopClearsUseCase _syncClears;
  final DateTime Function() _now;

  /// 同期する
  Future<void> call() async {
    for (final history in await _histories.getInProgressCoopHistories()) {
      final coop = history.coop!;
      final now = _now();
      if (!now.isBefore(coop.deleteAt)) {
        await _histories.finalizeCoopHistory(
          coop.roomCode,
          completedAt: coop.expiresAt,
        );
        continue;
      }
      final code = RoomCode.tryParse(coop.roomCode);
      if (code == null) {
        continue;
      }
      try {
        final room = await _rooms.fetchRoom(code);
        if (room != null) {
          await _syncClears(coop.roomCode, await _rooms.fetchClears(code));
        }
        if (shouldFinalizeHistory(
          room: room,
          expiresAt: coop.expiresAt,
          now: now,
        )) {
          await _histories.finalizeCoopHistory(
            coop.roomCode,
            completedAt: room?.finishedAt ?? _earlier(now, coop.expiresAt),
          );
        }
      } on Object catch (e) {
        // オフラインなどは次の機会に回す
        log('協力プレイの履歴の同期に失敗した: $e', name: 'SyncCoopHistory');
      }
    }
  }

  static DateTime _earlier(DateTime a, DateTime b) => a.isBefore(b) ? a : b;
}
