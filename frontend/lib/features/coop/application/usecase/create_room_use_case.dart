import 'dart:math';

import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/interface/room_repository.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';

/// ルームを作成し、ホストとして入室する
class CreateRoomUseCase {
  /// [CreateRoomUseCase] を作成する
  CreateRoomUseCase(this._rooms, {Random? random, DateTime Function()? now})
    : _random = random ?? Random.secure(),
      _now = now ?? DateTime.now;

  final IRoomRepository _rooms;
  final Random _random;
  final DateTime Function() _now;

  /// コードが衝突したときに作り直す回数の上限
  static const maxAttempts = 5;

  /// ルームを作成する
  ///
  /// 作成は create-only (存在しなければ作成)。衝突したら作り直して再試行する。
  Future<Room> call({
    required String uid,
    required Nickname nickname,
    required RoomSettings settings,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final createdAt = _now();
      final room = Room(
        code: RoomCode.generate(_random),
        hostId: uid,
        status: RoomStatus.waiting,
        settings: settings,
        createdAt: createdAt,
        expiresAt: createdAt.add(Room.playableDuration),
        deleteAt: createdAt.add(Room.retentionDuration),
      );
      if (await _rooms.createRoom(room)) {
        await _rooms.joinRoom(room, uid: uid, nickname: nickname);
        return room;
      }
    }
    throw StateError('ルームコードの衝突が続いたため、ルームを作成できませんでした');
  }
}
