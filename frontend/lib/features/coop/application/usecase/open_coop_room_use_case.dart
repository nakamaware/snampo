import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/application/coop_failure.dart';
import 'package:snampo/features/coop/application/usecase/pack_mission_bundle_use_case.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// ホストがミッションを Storage に置き、ルームを作る。
class OpenCoopRoomUseCase {
  /// [OpenCoopRoomUseCase] を作成する。
  const OpenCoopRoomUseCase({this.pack = const PackMissionBundleUseCase()});

  /// bundle の組み立て。
  final PackMissionBundleUseCase pack;

  /// [mission] を配り、[nickname] のホストでルームを開く。
  Future<CoopRoom> call({
    required CoopBackend backend,
    required Nickname nickname,
    required MissionEntity mission,
    required DateTime now,
    Random? random,
  }) async {
    final playerId = await backend.signIn();
    final bundle = pack(mission);
    final generator = random ?? Random();

    for (var attempt = 0; attempt < 5; attempt++) {
      final roomCode = RoomCode.generate(generator);
      final missionRef = 'rooms/${roomCode.value}/mission/bundle.json';
      final room = CoopRoom.open(
        roomCode: roomCode,
        hostId: playerId,
        hostNickname: nickname,
        createdAt: now,
        missionRef: missionRef,
        spotCount: mission.waypoints.length + 1,
      );
      final created = await backend.createRoom(room);
      if (!created) {
        continue;
      }
      await _upload(backend, missionRef, bundle.bundleJson);
      for (final entry in bundle.images.entries) {
        await backend.putBytes(
          objectPath: 'rooms/${roomCode.value}/mission/${entry.key}',
          bytes: entry.value,
        );
      }
      return room;
    }
    throw const CoopRoomCodeExhausted();
  }

  Future<void> _upload(
    CoopBackend backend,
    String missionRef,
    String bundleJson,
  ) {
    return backend.putBytes(
      objectPath: missionRef,
      bytes: Uint8List.fromList(utf8.encode(bundleJson)),
    );
  }
}
