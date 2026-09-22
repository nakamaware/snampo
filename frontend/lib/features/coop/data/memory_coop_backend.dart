import 'dart:async';
import 'dart:typed_data';

import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/domain/entity/coop_member.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// テストと、Firebase 設定が無いときの代わりには使わないメモリ実装。
class MemoryCoopBackend implements CoopBackend {
  /// [playerId] をこの端末の uid にする。
  MemoryCoopBackend({PlayerId? playerId})
    : playerId = playerId ?? PlayerId('memory-player');

  /// サインインで返す uid。
  PlayerId playerId;

  /// 呼び出し順。`room:` のあとに `put:`、そのあとに `clear:` が来る。
  final operations = <String>[];

  final Map<String, CoopRoom> _rooms = {};
  final Map<String, Map<String, CoopMember>> _members = {};
  final Map<String, Uint8List> _objects = {};
  final Map<String, Map<String, SpotClear>> _clears = {};
  final Map<String, StreamController<List<SpotClear>>> _clearStreams = {};

  @override
  Future<PlayerId> signIn() async => playerId;

  @override
  Future<bool> createRoom(CoopRoom room) async {
    final code = room.roomCode.value;
    if (_rooms.containsKey(code)) {
      return false;
    }
    operations.add('room:$code');
    _rooms[code] = room;
    return true;
  }

  @override
  Future<CoopRoom?> findRoom(RoomCode roomCode) async => _rooms[roomCode.value];

  @override
  Future<void> joinRoom({
    required RoomCode roomCode,
    required CoopMember member,
  }) async {
    final members = _members.putIfAbsent(roomCode.value, () => {});
    members[member.playerId.value] = member;
  }

  @override
  Future<void> putBytes({
    required String objectPath,
    required Uint8List bytes,
  }) async {
    operations.add('put:$objectPath');
    _objects[objectPath] = Uint8List.fromList(bytes);
  }

  @override
  Future<Uint8List?> getBytes(String objectPath) async {
    final bytes = _objects[objectPath];
    if (bytes == null) {
      return null;
    }
    return Uint8List.fromList(bytes);
  }

  @override
  Future<bool> createClear({
    required RoomCode roomCode,
    required SpotClear clear,
  }) async {
    final clears = _clears.putIfAbsent(roomCode.value, () => {});
    if (clears.containsKey(clear.spotId.value)) {
      return false;
    }
    operations.add('clear:${clear.spotId.value}');
    clears[clear.spotId.value] = clear;
    _emit(roomCode);
    return true;
  }

  @override
  Stream<List<SpotClear>> watchClears(RoomCode roomCode) {
    final controller = _clearStreams.putIfAbsent(roomCode.value, () {
      return StreamController<List<SpotClear>>.broadcast();
    });
    scheduleMicrotask(() => _emit(roomCode));
    return controller.stream;
  }

  void _emit(RoomCode roomCode) {
    final controller = _clearStreams[roomCode.value];
    if (controller == null || controller.isClosed) {
      return;
    }
    final clears = _clears[roomCode.value]?.values.toList() ?? <SpotClear>[];
    controller.add(clears);
  }
}
