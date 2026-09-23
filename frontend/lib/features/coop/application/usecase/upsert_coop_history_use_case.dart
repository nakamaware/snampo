import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/history/application/interface/history_repository.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// 協力プレイの履歴を「進行中」として作成する。既にあればメンバー一覧を更新する
class UpsertCoopHistoryUseCase {
  /// [UpsertCoopHistoryUseCase] を作成する
  UpsertCoopHistoryUseCase(this._histories);

  final IHistoryRepository _histories;

  /// 作成または更新する
  Future<void> call({
    required Room room,
    required MissionEntity mission,
    required List<RoomMember> members,
    required String uid,
  }) => _histories.upsertCoopHistory(
    mission: mission,
    startedAt: room.startedAt ?? room.createdAt,
    coop: CoopHistoryInfo(
      roomCode: room.code,
      syncState: CoopSyncState.inProgress,
      isHost: room.isHost(uid),
      members: [
        for (final m in members)
          CoopHistoryMember(uid: m.uid, nickname: m.nickname),
      ],
      expiresAt: room.expiresAt,
      deleteAt: room.deleteAt,
    ),
  );
}
