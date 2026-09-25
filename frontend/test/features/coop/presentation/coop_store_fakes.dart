import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/storage/mission_photo_directory.dart';
import 'package:snampo/core/storage/photo_storage.dart';
import 'package:snampo/features/coop/application/usecase/get_coop_signed_in_uid_use_case.dart';
import 'package:snampo/features/coop/application/usecase/prepare_coop_mission_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

import '../application/coop_fakes.dart';
import '../domain/entity/coop_fixtures.dart';

ImageCoordinate _spotOf(String spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: spot(spotId),
);

/// スポット a, b, c, d のミッション
final fourSpotMission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  waypoints: [_spotOf('a'), _spotOf('b'), _spotOf('c')],
  destination: _spotOf('d'),
  overviewPolyline: 'p',
);

/// スポット a, b, c, d のルーム
Room fourSpotRoom({RoomStatus status = RoomStatus.playing}) =>
    room(status: status, spotIds: ['a', 'b', 'c', 'd']);

/// スポット a, b, c, d のミッション (用意済み)
class FourSpotMission extends PersistedMission {
  @override
  Future<MissionEntity?> build(MissionSessionKind kind) async =>
      fourSpotMission;
}

/// スポット a, b, c, d のミッションを用意したことにする
class FakePrepareFourSpots implements PrepareCoopMissionUseCase {
  @override
  Future<MissionEntity> call(
    Room room, {
    required String uid,
    MissionEntity? prepared,
  }) async => fourSpotMission;
}

/// 自分の uid は `me`
class FakeSignedInUid implements GetCoopSignedInUidUseCase {
  @override
  Future<String?> call() async => 'me';
}

/// [initial] から始まる進捗 (端末の DB を使わない)
class ProgressOf extends MissionProgressStoreNotifier {
  ProgressOf(this.initial);

  final MissionProgressEntity? initial;

  @override
  Future<MissionProgressEntity?> build(MissionSessionKind kind) async =>
      initial;
}

/// 消した写真を記録する
class FakePhotoStorage implements IPhotoStorage {
  final deleted = <String>[];

  @override
  Future<void> deletePhoto(String path) async => deleted.add(path);

  @override
  Future<String> savePhoto(
    String sourcePath,
    int checkpointIndex, {
    required MissionPhotoDirectory directory,
  }) => throw UnimplementedError();
}

/// [code] のルームのスポット a, b, c, d の協力プレイの履歴を「進行中」で作る
Future<void> seedFourSpotHistory(FakeHistoryRepository histories) =>
    histories.upsertCoopHistory(
      mission: fourSpotMission,
      startedAt: createdAt,
      coop: CoopHistoryInfo(
        roomCode: code,
        syncState: CoopSyncState.inProgress,
        isHost: false,
        members: const [],
        expiresAt: createdAt.add(Room.playableDuration),
        deleteAt: createdAt.add(Room.retentionDuration),
      ),
    );
