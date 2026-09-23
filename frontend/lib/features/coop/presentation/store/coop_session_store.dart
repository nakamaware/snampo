import 'dart:developer';

import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
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

  /// ルームを抜ける (`leftAt` を記録し、端末の「ルームに戻る」を消す)
  ///
  /// 通信に失敗しても端末の記録は消す (抜けたルームの履歴の同期は続く)。
  Future<void> leave() async {
    final session = state.value;
    if (session == null) {
      return;
    }
    try {
      await ref.read(leaveRoomUseCaseProvider)(session.roomCode, session.uid);
    } on Object catch (e) {
      log('ルームを抜ける記録に失敗した: $e', name: 'CoopSession');
    }
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
