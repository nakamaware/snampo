import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';

import '../domain/entity/coop_fixtures.dart' as fx;
import 'coop_fakes.dart';

ImageCoordinate _spot(String spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: fx.spot(spotId),
);

/// スポット a, b, c のミッション
final coopMission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  waypoints: [_spot('a'), _spot('b')],
  destination: _spot('c'),
  overviewPolyline: 'p',
);

/// [fx.code] のルームの協力プレイの履歴を「進行中」で作る
Future<void> seedCoopHistory(FakeHistoryRepository histories) =>
    histories.upsertCoopHistory(
      mission: coopMission,
      startedAt: fx.createdAt,
      coop: CoopHistoryInfo(
        roomCode: fx.code,
        syncState: CoopSyncState.inProgress,
        isHost: false,
        members: const [],
        expiresAt: fx.createdAt.add(Room.playableDuration),
        deleteAt: fx.createdAt.add(Room.retentionDuration),
      ),
    );
