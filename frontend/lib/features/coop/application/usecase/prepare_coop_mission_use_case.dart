import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/application/usecase/upsert_coop_history_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// playing になったルームのミッションを端末に用意する
///
/// 参加者は `bundle.json` を取得してから画像をそれぞれ取得し、[MissionEntity] を組み直す。
/// ミッション画像はこの時点ですべて端末に保存し、履歴を「進行中」として作る
/// (途中で抜けても履歴に残るように)。
class PrepareCoopMissionUseCase {
  /// [PrepareCoopMissionUseCase] を作成する
  PrepareCoopMissionUseCase({
    required ICoopStorage storage,
    required IRoomRepository rooms,
    required UpsertCoopHistoryUseCase upsertHistory,
  }) : _storage = storage,
       _rooms = rooms,
       _upsertHistory = upsertHistory;

  final ICoopStorage _storage;
  final IRoomRepository _rooms;
  final UpsertCoopHistoryUseCase _upsertHistory;

  /// 用意したミッションを返す
  ///
  /// [prepared] は端末に用意済みのミッション (ルームに戻った場合など)。あれば取得し直さない。
  Future<MissionEntity> call(
    Room room, {
    required String uid,
    MissionEntity? prepared,
  }) async {
    final mission =
        prepared ??
        await _storage.downloadMissionBundle(
          room.missionRef ?? (throw StateError('missionRef がありません')),
        );
    await _upsertHistory(
      room: room,
      mission: mission,
      members: await _rooms.fetchMembers(room.code),
      uid: uid,
    );
    return mission;
  }
}
