import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/application/usecase/create_destination_mission_use_case.dart';
import 'package:snampo/features/mission/application/usecase/create_random_mission_use_case.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

import '../application/coop_fakes.dart';
import '../domain/entity/coop_fixtures.dart' as fx;

ImageCoordinate _spot(String spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: fx.spot(spotId),
);

final _mission = MissionEntity(
  departure: Coordinate(latitude: 35, longitude: 139),
  waypoints: [_spot('a'), _spot('b')],
  destination: _spot('c'),
  overviewPolyline: 'p',
);

class _FakeCreateRandomMission implements CreateRandomMissionUseCase {
  @override
  Future<MissionEntity> call(Radius radius) async => _mission;
}

class _FakeCreateDestinationMission implements CreateDestinationMissionUseCase {
  @override
  Future<MissionEntity> call(Coordinate destination) async => _mission;
}

void main() {
  group('startCoopMissionUseCaseProvider', () {
    test('ref.read で取り出したあとに Provider が破棄されても、ミッションを生成できる', () async {
      final rooms = FakeRoomRepository();
      final room = fx.room(status: RoomStatus.waiting, spotIds: const []);
      rooms.rooms[room.code] = room;
      final container = ProviderContainer.test(
        overrides: [
          roomRepositoryProvider.overrideWithValue(rooms),
          coopStorageProvider.overrideWithValue(FakeCoopStorage()),
          createRandomMissionUseCaseProvider.overrideWithValue(
            _FakeCreateRandomMission(),
          ),
          createDestinationMissionUseCaseProvider.overrideWithValue(
            _FakeCreateDestinationMission(),
          ),
        ],
      );

      // ロビーと同じく ref.read で取り出す。監視されていないので、次のフレームで破棄される
      final start = container.read(startCoopMissionUseCaseProvider);
      await container.pump();
      await start(room);

      final updated = rooms.rooms[room.code]!;
      expect(updated.generationError, isNull);
      expect(updated.status, RoomStatus.playing);
    });
  });
}
