import 'dart:developer';

import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 共有の途中でアプリが終了した撮影 (自分の写真はあるが発見者がいない) の扱いを決める
///
/// 共有の結果を待たずに終わっているので、共有できなかった扱いにして捨てる
/// (もう一度撮影できるようにする)。ただし、サーバにそのスポットの自分のクリアがあれば
/// (共有は届いていて、同期の前に終了した) 捨てない。先に他の人のクリアがあれば (先着に
/// 負けた)、他の人が発見したスポットと同じ扱いにするため捨てる。
///
/// クリアは監視のキャッシュではなく、サーバから読む (キャッシュが古いと、届いていた共有の
/// 撮影を捨ててしまうため)。サーバから読めなければ (時間内に返事が来ない場合を含む)、
/// 判断できないので何も捨てない (呼び出し側は、サーバの最新の値が届いたときに決め直す)。
///
/// 捨てない撮影は、自分の写真と採点を履歴に残す (共有のあと、履歴に残す前に終了しているため)。
class ResolveUnsharedCapturesUseCase {
  /// [ResolveUnsharedCapturesUseCase] を作成する
  ResolveUnsharedCapturesUseCase({
    required IRoomRepository rooms,
    required IHistoryRepository histories,
    this.fetchTimeout = defaultFetchTimeout,
  }) : _rooms = rooms,
       _histories = histories;

  /// [fetchTimeout] の既定値
  static const defaultFetchTimeout = Duration(seconds: 10);

  final IRoomRepository _rooms;
  final IHistoryRepository _histories;

  /// サーバからクリアを読むのを待つ時間 (電波が弱いときに、待たせ続けないため)
  final Duration fetchTimeout;

  /// [captures] (スポット ID ごとの、[uid] の撮影) のうち、捨てる撮影のスポット ID を返す
  ///
  /// [upToDateClears] は、サーバの最新の値と確かめられた `clears` (監視で届いたもの)。
  /// あればサーバから読み直さない。判断できなければ (サーバから読めない、時間切れ) null を返す。
  Future<Set<SpotId>?> call(
    RoomCode roomCode,
    Map<SpotId, CheckpointProgress> captures, {
    required String uid,
    List<SpotClear>? upToDateClears,
  }) async {
    if (captures.isEmpty) {
      return const {};
    }
    final Set<SpotId> mySpotIds;
    try {
      mySpotIds = {
        for (final clear
            in upToDateClears ??
                await _rooms.fetchClears(roomCode).timeout(fetchTimeout))
          if (clear.clearedBy == uid) clear.spotId,
      };
    } on Object catch (e) {
      log('未共有の撮影を確かめられなかった: $e', name: 'ResolveUnsharedCaptures');
      return null;
    }
    final discard = <SpotId>{};
    for (final MapEntry(key: spotId, value: checkpoint) in captures.entries) {
      if (!mySpotIds.contains(spotId)) {
        discard.add(spotId);
        continue;
      }
      try {
        await _histories.saveCoopUserPhoto(
          roomCode: roomCode,
          spotId: spotId,
          checkpoint: checkpoint,
        );
      } on Object catch (e) {
        log('履歴への写真の保存に失敗した: $e', name: 'ResolveUnsharedCaptures');
      }
    }
    return discard;
  }
}
