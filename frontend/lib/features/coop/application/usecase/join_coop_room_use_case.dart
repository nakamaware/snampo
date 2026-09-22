import 'dart:convert';
import 'dart:typed_data';

import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/application/coop_failure.dart';
import 'package:snampo/features/coop/application/usecase/unpack_mission_bundle_use_case.dart';
import 'package:snampo/features/coop/domain/entity/coop_member.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/entity/packed_mission_bundle.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// 参加の結果。
class JoinedCoopRoom {
  /// [JoinedCoopRoom] を作成する。
  const JoinedCoopRoom({
    required this.room,
    required this.member,
    required this.mission,
  });

  /// 参加したルーム。
  final CoopRoom room;

  /// 自分のメンバー。
  final CoopMember member;

  /// 展開したミッション。
  final MissionEntity mission;
}

/// コードで入室し、bundle をミッションに戻す。
class JoinCoopRoomUseCase {
  /// [JoinCoopRoomUseCase] を作成する。
  const JoinCoopRoomUseCase({this.unpack = const UnpackMissionBundleUseCase()});

  /// bundle の展開。
  final UnpackMissionBundleUseCase unpack;

  /// [roomCode] のルームへ [nickname] で参加する。
  Future<JoinedCoopRoom> call({
    required CoopBackend backend,
    required RoomCode roomCode,
    required Nickname nickname,
    required DateTime now,
  }) async {
    final playerId = await backend.signIn();
    final room = await backend.findRoom(roomCode);
    if (room == null) {
      throw const CoopRoomNotFound();
    }
    if (!now.isBefore(room.expiresAt)) {
      throw const CoopRoomExpired();
    }
    final member = CoopMember(
      playerId: playerId,
      nickname: nickname,
      joinedAt: now,
    );
    await backend.joinRoom(roomCode: roomCode, member: member);

    final bundleBytes = await backend.getBytes(room.missionRef);
    if (bundleBytes == null) {
      throw ArgumentError('bundle.json がありません');
    }
    final bundleJson = utf8.decode(bundleBytes);
    final decoded = jsonDecode(bundleJson);
    if (decoded is! Map<String, dynamic>) {
      throw ArgumentError('bundle.json はオブジェクトです');
    }
    final images = await _images(backend, roomCode, decoded);
    final mission = unpack(
      PackedMissionBundle(bundleJson: bundleJson, images: images),
    );
    return JoinedCoopRoom(room: room, member: member, mission: mission);
  }

  Future<Map<String, Uint8List>> _images(
    CoopBackend backend,
    RoomCode roomCode,
    Map<String, dynamic> decoded,
  ) async {
    final paths = <String>{};
    final waypoints = decoded['waypoints'];
    if (waypoints is List) {
      for (final item in waypoints) {
        _collectPath(paths, item);
      }
    }
    _collectPath(paths, decoded['destination']);

    final images = <String, Uint8List>{};
    for (final path in paths) {
      final bytes = await backend.getBytes(
        'rooms/${roomCode.value}/mission/$path',
      );
      if (bytes == null) {
        throw ArgumentError.value(path, 'imagePath', '画像ファイルがありません');
      }
      images[path] = bytes;
    }
    return images;
  }

  void _collectPath(Set<String> paths, Object? raw) {
    if (raw is! Map) {
      return;
    }
    final path = raw['imagePath'];
    if (path is String && path.isNotEmpty) {
      paths.add(path);
    }
  }
}
