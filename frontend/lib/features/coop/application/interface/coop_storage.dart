import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// 協力プレイの Cloud Storage (ミッションバンドルとサムネ)
abstract class ICoopStorage {
  /// ミッションバンドル (`bundle.json` とスポット画像) をアップロードし、`missionRef` を返す
  ///
  /// 同じパスに上書きするため、途中で失敗しても再試行できる。
  Future<String> uploadMissionBundle(RoomCode code, MissionEntity mission);

  /// ミッションバンドルを取得して [MissionEntity] を組み直す
  Future<MissionEntity> downloadMissionBundle(String missionRef);

  /// サムネをアップロードし、Storage のパスを返す
  Future<String> uploadThumb({
    required RoomCode code,
    required SpotId spotId,
    required String uid,
    required String localPath,
  });

  /// サムネを取得して一時ファイルに保存し、そのパスを返す
  Future<String> downloadThumb(String thumbPath);
}
