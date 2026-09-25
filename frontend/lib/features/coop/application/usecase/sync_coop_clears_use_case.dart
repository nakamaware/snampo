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

      /// この途中経過の直前に、サムネの取得を試したスポット
      ///
      /// 取得できなかった (時間切れを含む) 場合もそのスポットになる。発見者を反映した
      /// 時点の途中経過では null。
      SpotId? thumbAttemptedSpotId,
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
    this.thumbTimeout = defaultThumbTimeout,
  }) : _storage = storage,
       _histories = histories;

  /// [thumbTimeout] の既定値
  static const defaultThumbTimeout = Duration(seconds: 10);

  final ICoopStorage _storage;
  final IHistoryRepository _histories;

  /// サムネ 1 枚の取得を待つ時間
  ///
  /// 電波が弱いと Storage の取得は再試行を続けて終わらないことがある。反映は順番に行うので、
  /// 1 枚の取得で後の反映 (結果画面へ移る前の待ち合わせなど) を止め続けないため。
  final Duration thumbTimeout;

  /// 反映する (履歴がなければ何もしない)
  Future<CoopClearSyncResult> call(RoomCode roomCode, List<SpotClear> clears) =>
      syncInSteps(roomCode, clears).last;

  /// 反映し、途中経過を流す (履歴がなければ、何もせずに空の結果を 1 つだけ流す)
  ///
  /// 発見者を反映した時点と、サムネを 1 枚取得しようとするごと (取得できなかった場合や
  /// 時間切れを含む) に、その時点の結果を流す。最後に流すのが反映し終えた結果。
  /// サムネの取得を待たずに発見者を先に画面へ出し、あるスポットのサムネを待つ画面が、
  /// ほかのサムネの取得まで待たずに済むようにするため (電波が弱いとサムネの取得は
  /// [thumbTimeout] まで終わらない)。
  Stream<CoopClearSyncResult> syncInSteps(
    RoomCode roomCode,
    List<SpotClear> clears,
  ) async* {
    final history = await _histories.getCoopHistory(roomCode);
    if (history == null) {
      yield (
        hasAllThumbs: false,
        discoveries: <SpotId, CoopDiscovery>{},
        thumbAttemptedSpotId: null,
      );
      return;
    }
    final plan = planClearSync(clears: clears, local: _localStates(history));
    for (final clear in plan.discoverersToApply) {
      await _histories.applyCoopDiscoverer(
        roomCode: roomCode,
        spotId: clear.spotId,
        discovererUid: clear.clearedBy,
        discovererNickname: clear.nickname,
        clearedAt: clear.clearedAt,
        judgement: clear.judgement,
      );
    }
    yield await _result(roomCode, clears, fallback: history, attempted: null);
    for (final clear in plan.thumbsToFetch) {
      try {
        final downloaded = await _storage
            .downloadThumb(clear.thumbPath)
            .timeout(thumbTimeout);
        await _histories.saveCoopThumb(
          roomCode: roomCode,
          spotId: clear.spotId,
          sourcePath: downloaded,
        );
      } on Object catch (e) {
        // 時間切れも含め、次の同期で取り直す
        log('サムネの取得に失敗した: $e', name: 'SyncCoopClears');
      }
      yield await _result(
        roomCode,
        clears,
        fallback: history,
        attempted: clear.spotId,
      );
    }
  }

  /// 履歴に反映済みの結果
  Future<CoopClearSyncResult> _result(
    RoomCode roomCode,
    List<SpotClear> clears, {
    required MissionHistory fallback,
    required SpotId? attempted,
  }) async {
    final synced = await _histories.getCoopHistory(roomCode) ?? fallback;
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
              judgement: spot.discovererJudgement,
            ),
      },
      thumbAttemptedSpotId: attempted,
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
