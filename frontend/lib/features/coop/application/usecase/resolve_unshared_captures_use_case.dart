import 'dart:developer';

import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 共有の途中でアプリが終了した撮影 (自分の写真はあるが発見者がいない) の扱いを決める
///
/// 共有の結果を待たずに終わっているので、共有できなかった扱いにして捨てる
/// (もう一度撮影できるようにする)。ただし、サーバにそのスポットのクリアがあれば
/// (共有は届いていて、同期の前に終了した。先着に負けた場合を含む) 捨てない。
///
/// クリアは監視のキャッシュではなく、サーバから読む (キャッシュが古いと、届いていた共有の
/// 撮影を捨ててしまうため)。サーバから読めなければ、判断できないので何も捨てない。
class ResolveUnsharedCapturesUseCase {
  /// [ResolveUnsharedCapturesUseCase] を作成する
  ResolveUnsharedCapturesUseCase({required IRoomRepository rooms})
    : _rooms = rooms;

  final IRoomRepository _rooms;

  /// [captures] (スポット ID ごとの撮影) のうち、捨てる撮影のスポット ID を返す
  Future<Set<SpotId>> call(
    RoomCode roomCode,
    Map<SpotId, CheckpointProgress> captures,
  ) async {
    if (captures.isEmpty) {
      return const {};
    }
    final Set<SpotId> clearedSpotIds;
    try {
      clearedSpotIds = {
        for (final clear in await _rooms.fetchClears(roomCode)) clear.spotId,
      };
    } on Object catch (e) {
      log('未共有の撮影を確かめられなかった: $e', name: 'ResolveUnsharedCaptures');
      return const {};
    }
    return {
      for (final spotId in captures.keys)
        if (!clearedSpotIds.contains(spotId)) spotId,
    };
  }
}
