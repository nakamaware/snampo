import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';

part 'coop_room_streams.g.dart';

/// ルームを監視する (消えたら null)
@riverpod
Stream<Room?> coopRoom(Ref ref, RoomCode roomCode) =>
    ref.watch(watchRoomUseCaseProvider).room(roomCode);

/// メンバーを監視する (入室順)
@riverpod
Stream<List<RoomMember>> coopMembers(Ref ref, RoomCode roomCode) =>
    ref.watch(watchRoomUseCaseProvider).members(roomCode);

/// クリアを監視する
@riverpod
Stream<List<SpotClear>> coopClears(Ref ref, RoomCode roomCode) =>
    ref.watch(watchRoomUseCaseProvider).clears(roomCode);
