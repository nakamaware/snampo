import 'dart:typed_data';

import 'package:snampo/features/coop/domain/entity/coop_member.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

/// 協力プレイの読み書き。Firebase 実装とテスト用のメモリ実装がこれを満たす。
abstract class CoopBackend {
  /// 匿名サインインして `uid` を返す。
  Future<PlayerId> signIn();

  /// ルームを作成する。同じコードがあれば false。
  Future<bool> createRoom(CoopRoom room);

  /// 生きているルームを読む。無ければ null。
  Future<CoopRoom?> findRoom(RoomCode roomCode);

  /// 参加者を登録する。
  Future<void> joinRoom({
    required RoomCode roomCode,
    required CoopMember member,
  });

  /// [objectPath] にバイトを書く。
  Future<void> putBytes({required String objectPath, required Uint8List bytes});

  /// [objectPath] を読む。無ければ null。
  Future<Uint8List?> getBytes(String objectPath);

  /// 先着のクリアを作る。既にあれば false。
  Future<bool> createClear({
    required RoomCode roomCode,
    required SpotClear clear,
  });

  /// ルームのクリア一覧。
  Stream<List<SpotClear>> watchClears(RoomCode roomCode);
}
