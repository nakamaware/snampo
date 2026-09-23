import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/room_code.dart';

part 'coop_room_streams.g.dart';

/// ルームを監視する (消えたら null)
@riverpod
Stream<Room?> coopRoom(Ref ref, String roomCode) =>
    ref.watch(roomRepositoryProvider).watchRoom(RoomCode.tryParse(roomCode)!);

/// メンバーを監視する (入室順)
@riverpod
Stream<List<RoomMember>> coopMembers(Ref ref, String roomCode) => ref
    .watch(roomRepositoryProvider)
    .watchMembers(RoomCode.tryParse(roomCode)!);

/// クリアを監視する
@riverpod
Stream<List<SpotClear>> coopClears(Ref ref, String roomCode) =>
    ref.watch(roomRepositoryProvider).watchClears(RoomCode.tryParse(roomCode)!);
