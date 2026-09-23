import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/coop/application/usecase/start_coop_mission_use_case.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

import '../../domain/entity/coop_fixtures.dart' as fx;
import '../coop_fakes.dart';

ImageCoordinate _spot(String? spotId) => ImageCoordinate(
  coordinate: Coordinate(latitude: 35, longitude: 139),
  imageBase64: '',
  spotId: spotId == null ? null : fx.spot(spotId),
);

void main() {
  late FakeRoomRepository rooms;
  late FakeCoopStorage storage;
  late Room room;

  final mission = MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    waypoints: [_spot('a'), _spot('b')],
    destination: _spot('c'),
    overviewPolyline: 'p',
  );

  setUp(() {
    rooms = FakeRoomRepository();
    storage = FakeCoopStorage();
    room = fx.room(status: RoomStatus.waiting, spotIds: const []);
    rooms.rooms[room.code] = room;
  });

  StartCoopMissionUseCase useCase(
    Future<MissionEntity> Function(RoomSettings) createMission,
  ) => StartCoopMissionUseCase(
    rooms: rooms,
    storage: storage,
    createMission: createMission,
  );

  test('ミッションを生成してバンドルをアップロードし、playing にする', () async {
    final statuses = <RoomStatus>[];

    await useCase((settings) async {
      statuses.add(rooms.rooms[room.code]!.status);
      return mission;
    })(room);

    expect(statuses, [RoomStatus.generating]);
    final updated = rooms.rooms[room.code]!;
    expect(updated.status, RoomStatus.playing);
    expect(updated.missionRef, 'rooms/ABCD23/mission/bundle.json');
    expect(updated.spotIds, [fx.spot('a'), fx.spot('b'), fx.spot('c')]);
    expect(storage.uploadedMission, mission);
  });

  test('生成に失敗したら waiting に戻して理由を設定する', () async {
    await expectLater(
      useCase((_) async => throw Exception('API error'))(room),
      throwsException,
    );

    final updated = rooms.rooms[room.code]!;
    expect(updated.status, RoomStatus.waiting);
    expect(updated.generationError, isNotNull);
  });

  test('アップロードに失敗したら waiting に戻す', () async {
    storage.bundleUploadError = Exception('upload');

    await expectLater(useCase((_) async => mission)(room), throwsException);

    expect(rooms.rooms[room.code]!.status, RoomStatus.waiting);
  });

  test('スポット ID がないミッションは協力プレイに使えない', () async {
    final legacy = mission.copyWith(destination: _spot(null));

    await expectLater(useCase((_) async => legacy)(room), throwsStateError);

    expect(rooms.rooms[room.code]!.status, RoomStatus.waiting);
  });
}
