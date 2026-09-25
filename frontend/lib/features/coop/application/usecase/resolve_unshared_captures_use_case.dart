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
/// (もう一度撮影できるようにする)。ただし、サーバにそのスポットのクリアがあれば
/// (共有は届いていて、同期の前に終了した。先着に負けた場合を含む) 捨てない。
///
/// クリアは監視のキャッシュではなく、サーバから読む (キャッシュが古いと、届いていた共有の
/// 撮影を捨ててしまうため)。サーバから読めなければ、判断できないので何も捨てない
/// (呼び出し側は、サーバの最新の値が届いたときに決め直す)。
///
/// 捨てない撮影は、自分の写真と採点を履歴に残す (共有のあと、履歴に残す前に終了しているため)。
class ResolveUnsharedCapturesUseCase {
  /// [ResolveUnsharedCapturesUseCase] を作成する
  ResolveUnsharedCapturesUseCase({
    required IRoomRepository rooms,
    required IHistoryRepository histories,
  }) : _rooms = rooms,
       _histories = histories;

  final IRoomRepository _rooms;
  final IHistoryRepository _histories;

  /// [captures] (スポット ID ごとの撮影) のうち、捨てる撮影のスポット ID を返す
  ///
  /// [upToDateClears] は、サーバの最新の値と確かめられた `clears` (監視で届いたもの)。
  /// あればサーバから読み直さない。判断できなければ (サーバから読めない) null を返す。
  Future<Set<SpotId>?> call(
    RoomCode roomCode,
    Map<SpotId, CheckpointProgress> captures, {
    List<SpotClear>? upToDateClears,
  }) async {
    if (captures.isEmpty) {
      return const {};
    }
    final Set<SpotId> clearedSpotIds;
    try {
      clearedSpotIds = {
        for (final clear
            in upToDateClears ?? await _rooms.fetchClears(roomCode))
          clear.spotId,
      };
    } on Object catch (e) {
      log('未共有の撮影を確かめられなかった: $e', name: 'ResolveUnsharedCaptures');
      return null;
    }
    final discard = <SpotId>{};
    for (final MapEntry(key: spotId, value: checkpoint) in captures.entries) {
      if (!clearedSpotIds.contains(spotId)) {
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
