import 'package:snampo/features/coop/application/interface/coop_storage.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// ホストが開始を押したときに、ミッションを生成して全員に配る
///
/// 1. generating にする (全員の画面に「ミッション生成中」を表示する)
/// 2. ホストの端末が `/route` を呼ぶ
/// 3. 画像と `bundle.json` を Storage へアップロードする
/// 4. `missionRef` と `spotIds` を書いて playing にする
///
/// 失敗したら waiting に戻し、`generationError` を設定してから例外を投げ直す。
class StartCoopMissionUseCase {
  /// [StartCoopMissionUseCase] を作成する
  StartCoopMissionUseCase({
    required IRoomRepository rooms,
    required ICoopStorage storage,
    required Future<MissionEntity> Function(RoomSettings settings)
    createMission,
  }) : _rooms = rooms,
       _storage = storage,
       _createMission = createMission;

  final IRoomRepository _rooms;
  final ICoopStorage _storage;
  final Future<MissionEntity> Function(RoomSettings settings) _createMission;

  /// 開始する
  Future<void> call(Room room) async {
    await _rooms.markGenerating(room.code);
    try {
      final mission = await _createMission(room.settings);
      final spotIds = [
        for (final spot in [...mission.waypoints, mission.destination])
          spot.spotId ?? (throw StateError('スポット ID がないミッションは協力プレイに使えません')),
      ];
      final missionRef = await _storage.uploadMissionBundle(room.code, mission);
      await _rooms.markPlaying(
        room.code,
        missionRef: missionRef,
        spotIds: spotIds,
      );
    } on Object catch (e) {
      await _rooms.markGenerationFailed(room.code, '$e');
      rethrow;
    }
  }
}
