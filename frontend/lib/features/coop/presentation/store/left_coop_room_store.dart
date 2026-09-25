import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/storage_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';

part 'left_coop_room_store.g.dart';

/// 最後に抜けたルーム (ルームが終わるまで、ホームから入り直せるように保存する)
///
/// 別のルームに入ると消す (`CoopSessionStore.enter`)。
@Riverpod(keepAlive: true)
@JsonPersist()
class LeftCoopRoomStore extends _$LeftCoopRoomStore {
  @override
  Future<CoopSession?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// 抜けたルームを記録する
  void record(CoopSession session) {
    state = AsyncValue.data(session);
  }

  /// 記録を消す
  void clear() {
    state = const AsyncValue.data(null);
  }
}
