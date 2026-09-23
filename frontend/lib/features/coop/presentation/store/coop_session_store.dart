import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';

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
  void enter(CoopSession session) {
    state = AsyncValue.data(session);
  }

  /// ルームを抜けた、または結果画面を閉じたので記録を消す
  void clear() {
    state = const AsyncValue.data(null);
  }
}
