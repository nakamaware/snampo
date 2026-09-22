import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/coop_failure.dart';
import 'package:snampo/features/coop/application/usecase/join_coop_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/open_coop_room_use_case.dart';
import 'package:snampo/features/coop/application/usecase/share_spot_clear_use_case.dart';
import 'package:snampo/features/coop/application/usecase/sync_remote_clears_use_case.dart';
import 'package:snampo/features/coop/data/memory_coop_backend.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/coop/domain/value_object/spot_id.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

void main() {
  final now = DateTime.utc(2026, 9, 22, 12);

  MissionEntity sampleMission() {
    return MissionEntity(
      departure: Coordinate(latitude: 35, longitude: 139),
      waypoints: [
        ImageCoordinate(
          coordinate: Coordinate(latitude: 35.1, longitude: 139.1),
          imageBase64: base64Encode(Uint8List.fromList([1, 2, 3])),
          name: 'spot',
        ),
      ],
      destination: ImageCoordinate(
        coordinate: Coordinate(latitude: 35.2, longitude: 139.2),
        imageBase64: base64Encode(Uint8List.fromList([4, 5, 6])),
        name: 'goal',
      ),
      overviewPolyline: 'encoded',
      radius: Radius(meters: 500),
    );
  }

  test('ホストは 6 桁と 24 時間のルームを作ってから画像を置く', () async {
    final backend = MemoryCoopBackend(playerId: PlayerId('host'));
    final room = await const OpenCoopRoomUseCase().call(
      backend: backend,
      nickname: Nickname('ホスト'),
      mission: sampleMission(),
      now: now,
      random: _SeqRandom([42]),
    );

    expect(room.roomCode.value, '000042');
    expect(room.expiresAt, now.add(coopRoomLifetime));
    expect(room.spotCount, 2);
    expect(room.hostNickname.value, 'ホスト');

    final code = room.roomCode.value;
    final bundle = 'put:rooms/$code/mission/bundle.json';
    final firstImage = 'put:rooms/$code/mission/images/0.jpg';
    final roomOp = 'room:$code';
    expect(backend.operations, containsAll([roomOp, bundle, firstImage]));
    expect(
      backend.operations.indexOf(roomOp),
      lessThan(backend.operations.indexOf(bundle)),
    );
    expect(
      backend.operations.indexOf(bundle),
      lessThan(backend.operations.indexOf(firstImage)),
    );

    final stored = await backend.getBytes('rooms/$code/mission/bundle.json');
    expect(stored, isNotNull);
    expect(utf8.decode(stored!), contains('images/0.jpg'));
  });

  test('使われているコードは飛ばして次のコードで開く', () async {
    final backend = MemoryCoopBackend(playerId: PlayerId('host'));
    await backend.createRoom(
      CoopRoom.open(
        roomCode: RoomCode('000000'),
        hostId: PlayerId('other'),
        hostNickname: Nickname('先客'),
        createdAt: now,
        missionRef: 'rooms/000000/mission/bundle.json',
        spotCount: 1,
      ),
    );

    final room = await const OpenCoopRoomUseCase().call(
      backend: backend,
      nickname: Nickname('ホスト'),
      mission: sampleMission(),
      now: now,
      random: _SeqRandom([0, 7]),
    );

    expect(room.roomCode.value, '000007');
    expect(
      backend.operations.where((op) => op.contains('000000/mission')),
      isEmpty,
    );
  });

  test('5 回ともコードが埋まっていると CoopRoomCodeExhausted', () async {
    final backend = MemoryCoopBackend(playerId: PlayerId('host'));
    await backend.createRoom(
      CoopRoom.open(
        roomCode: RoomCode('000000'),
        hostId: PlayerId('other'),
        hostNickname: Nickname('先客'),
        createdAt: now,
        missionRef: 'rooms/000000/mission/bundle.json',
        spotCount: 1,
      ),
    );

    expect(
      () => const OpenCoopRoomUseCase().call(
        backend: backend,
        nickname: Nickname('ホスト'),
        mission: sampleMission(),
        now: now,
        random: _SeqRandom([0, 0, 0, 0, 0]),
      ),
      throwsA(isA<CoopRoomCodeExhausted>()),
    );
  });

  test('ゲストは bundle をミッションに戻して参加する', () async {
    final backend = MemoryCoopBackend(playerId: PlayerId('host'));
    final room = await const OpenCoopRoomUseCase().call(
      backend: backend,
      nickname: Nickname('ホスト'),
      mission: sampleMission(),
      now: now,
      random: _SeqRandom([42]),
    );
    backend.playerId = PlayerId('guest');

    final joined = await const JoinCoopRoomUseCase().call(
      backend: backend,
      roomCode: room.roomCode,
      nickname: Nickname('ゲスト'),
      now: now.add(const Duration(minutes: 5)),
    );

    expect(joined.member.playerId.value, 'guest');
    expect(joined.member.nickname.value, 'ゲスト');
    expect(joined.mission.waypoints.single.name, 'spot');
    expect(joined.mission.destination.name, 'goal');
    expect(base64Decode(joined.mission.waypoints.single.imageBase64), [
      1,
      2,
      3,
    ]);
  });

  test('無いコードは CoopRoomNotFound、期限切れは CoopRoomExpired', () async {
    final backend = MemoryCoopBackend(playerId: PlayerId('guest'));
    const join = JoinCoopRoomUseCase();

    expect(
      () => join.call(
        backend: backend,
        roomCode: RoomCode('123456'),
        nickname: Nickname('ゲスト'),
        now: now,
      ),
      throwsA(isA<CoopRoomNotFound>()),
    );

    await backend.createRoom(
      CoopRoom.open(
        roomCode: RoomCode('654321'),
        hostId: PlayerId('host'),
        hostNickname: Nickname('ホスト'),
        createdAt: now.subtract(coopRoomLifetime),
        missionRef: 'rooms/654321/mission/bundle.json',
        spotCount: 1,
      ),
    );

    expect(
      () => join.call(
        backend: backend,
        roomCode: RoomCode('654321'),
        nickname: Nickname('ゲスト'),
        now: now,
      ),
      throwsA(isA<CoopRoomExpired>()),
    );
  });

  test('クリア写真は Storage に置いてから clears を作り、空と先着負けは共有しない', () async {
    final backend = MemoryCoopBackend();
    const share = ShareSpotClearUseCase();
    final code = RoomCode('111111');
    final jpeg = Uint8List.fromList([9, 9, 9]);

    expect(
      () => share.call(
        backend: backend,
        roomCode: code,
        spotId: SpotId.fromIndex(0),
        clearedBy: PlayerId('host'),
        nickname: Nickname('ホスト'),
        clearedAt: now,
        jpeg: Uint8List(0),
      ),
      throwsA(isA<ArgumentError>()),
    );
    expect(backend.operations, isEmpty);

    final clear = await share.call(
      backend: backend,
      roomCode: code,
      spotId: SpotId.fromIndex(0),
      clearedBy: PlayerId('host'),
      nickname: Nickname('ホスト'),
      clearedAt: now,
      jpeg: jpeg,
    );
    expect(clear?.thumbPath, 'rooms/111111/thumbs/0.jpg');
    expect(backend.operations, ['put:rooms/111111/thumbs/0.jpg', 'clear:0']);

    final lost = await share.call(
      backend: backend,
      roomCode: code,
      spotId: SpotId.fromIndex(0),
      clearedBy: PlayerId('guest'),
      nickname: Nickname('ゲスト'),
      clearedAt: now,
      jpeg: jpeg,
    );
    expect(lost, isNull);
    expect(backend.operations.where((op) => op.startsWith('clear:')), [
      'clear:0',
    ]);
  });

  test('他端末の写真はローカルファイルにして、自分の写真は残す', () async {
    final backend = MemoryCoopBackend();
    final directory = await Directory.systemTemp.createTemp('coop_thumbs');
    addTearDown(() => directory.delete(recursive: true));

    const share = ShareSpotClearUseCase();
    final code = RoomCode('222222');
    final remote = await share.call(
      backend: backend,
      roomCode: code,
      spotId: SpotId.fromIndex(0),
      clearedBy: PlayerId('guest'),
      nickname: Nickname('ゲスト'),
      clearedAt: now,
      jpeg: Uint8List.fromList([7, 8]),
    );
    final localPhoto = await share.call(
      backend: backend,
      roomCode: code,
      spotId: SpotId.fromIndex(1),
      clearedBy: PlayerId('host'),
      nickname: Nickname('ホスト'),
      clearedAt: now,
      jpeg: Uint8List.fromList([1]),
    );

    final started = now.subtract(const Duration(minutes: 1));
    final local = MissionProgressEntity(
      startedAt: started,
      checkpoints: [
        null,
        CheckpointProgress(achievedAt: started, userPhotoPath: '/mine.jpg'),
      ],
    );

    final result = await const SyncRemoteClearsUseCase().call(
      backend: backend,
      local: local,
      clears: [remote!, localPhoto!],
      photoDirectory: directory,
    );

    expect(result.discoverers, {0: 'ゲスト', 1: 'ホスト'});
    expect(result.progress.checkpoints[0]?.userPhotoPath, endsWith('/0.jpg'));
    expect(result.progress.checkpoints[0]?.achievedAt, now);
    expect(result.progress.checkpoints[1]?.userPhotoPath, '/mine.jpg');
    final downloaded = File(result.progress.checkpoints[0]!.userPhotoPath!);
    expect(await downloaded.readAsBytes(), [7, 8]);
  });
}

class _SeqRandom implements Random {
  _SeqRandom(this.values);

  final List<int> values;
  int index = 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => values[index++];
}
