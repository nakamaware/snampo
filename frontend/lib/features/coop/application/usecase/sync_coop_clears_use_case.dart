import 'dart:developer';

import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// [SyncCoopClearsUseCase] の結果
typedef CoopClearSyncResult =
    ({
      /// 発見者のサムネが全部端末にそろったか
      bool hasAllThumbs,

      /// 端末に反映済みの発見 (スポット ID ごと)
      Map<SpotId, CoopDiscovery> discoveries,
    });

/// サーバの `clears` と履歴 (端末のキャッシュ) を比べ、不足分を取得して履歴に反映する
///
/// 基本方針は「サーバ (`clears`) が正で、端末は差分を取りにいく」。
/// `clears` の通知が届いたとき、ルームに戻ったとき、`SyncCoopHistoryUseCase` から呼ぶ。
class SyncCoopClearsUseCase {
  /// [SyncCoopClearsUseCase] を作成する
  SyncCoopClearsUseCase({
    required ICoopStorage storage,
    required IHistoryRepository histories,
  }) : _storage = storage,
       _histories = histories;

  final ICoopStorage _storage;
  final IHistoryRepository _histories;

  /// 反映する (履歴がなければ何もしない)
  Future<CoopClearSyncResult> call(
    RoomCode roomCode,
    List<SpotClear> clears,
  ) async {
    final history = await _histories.getCoopHistory(roomCode);
    if (history == null) {
      return (hasAllThumbs: false, discoveries: <SpotId, CoopDiscovery>{});
    }
    final plan = planClearSync(clears: clears, local: _localStates(history));
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
        final downloaded = await _storage.downloadThumb(clear.thumbPath);
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
    final synced = await _histories.getCoopHistory(roomCode) ?? history;
    return (
      hasAllThumbs: hasAllClearThumbs(
        clears: clears,
        local: _localStates(synced),
      ),
      discoveries: {
        for (final spot in synced.spots)
          if (spot.spotId != null && spot.discovererUid != null)
            spot.spotId!: (
              uid: spot.discovererUid!,
              nickname: spot.discovererNickname ?? '',
              clearedAt: spot.achievedAt ?? synced.startedAt,
              thumbPath: spot.discovererThumbPath,
            ),
      },
    );
  }

  static Map<SpotId, LocalClearState> _localStates(MissionHistory history) => {
    for (final spot in history.spots)
      if (spot.spotId != null)
        spot.spotId!: LocalClearState(
          discovererUid: spot.discovererUid,
          hasThumb: spot.discovererThumbPath != null,
        ),
  };
}
