import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/storage_provider.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/left_coop_room_store.dart';

part 'coop_session_store.g.dart';

/// 端末で進行中の協力プレイ (アプリのキルや電波断のあとに「ルームに戻る」ため保存する)
@Riverpod(keepAlive: true)
@JsonPersist()
class CoopSessionStore extends _$CoopSessionStore {
  @override
  Future<CoopSession?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// 入室したルームを記録する
  ///
  /// 別のルームに参加中なら、そのルームを抜けてから記録する (入室に成功したあとに呼ぶ。
  /// 失敗したときに前のルームを抜けてしまわないように)。
  void enter(CoopSession session) {
    final current = state.value;
    if (current != null && current.roomCode != session.roomCode) {
      leave();
    }
    ref.read(leftCoopRoomStoreProvider.notifier).clear();
    state = AsyncValue.data(session);
  }

  /// ルームを抜ける (`leftAt` を記録し、端末の「ルームに戻る」を「また入る」に変える)
  ///
  /// 通信の結果を待たずに端末の記録を消す (抜けたルームの履歴の同期は続く)。
  /// 抜けたルームは [LeftCoopRoomStore] に残し、ホームから入り直せるようにする。
  void leave() {
    final session = state.value;
    if (session == null) {
      return;
    }
    ref.read(leaveRoomUseCaseProvider)(session.roomCode, session.uid);
    ref.read(leftCoopRoomStoreProvider.notifier).record(session);
    close();
  }

  /// 結果画面を閉じた、またはルームを抜けたので記録を消す
  ///
  /// ルームの監視も止める (抜けたルームの通知で、次のルームの進捗を変えないため)。
  void close() {
    final session = state.value;
    if (session != null) {
      ref.invalidate(coopMissionStoreProvider(session.roomCode));
    }
    state = const AsyncValue.data(null);
  }
}
