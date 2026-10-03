import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/presentation/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

/// 別のルームへ入る前に、協力プレイ中のルームを抜けてよいかを確認する
///
/// 実際に抜けるのは、新しいルームへの入室や作成に成功したとき ([CoopSessionStore.enter])。
/// 抜けたルームは `leftAt` を記録し、履歴の同期は続ける。続けてよければ true を返す。
/// 今のルームがもう終わっていれば (結果を見る前のルーム)、確認せずに続ける。
Future<bool> confirmLeaveCurrentRoom(
  BuildContext context,
  WidgetRef ref, {
  RoomCode? nextCode,
}) async {
  final current = await ref.read(coopSessionStoreProvider.future);
  if (current == null || current.roomCode == nextCode) {
    return true;
  }
  final room = ref.read(coopRoomProvider(current.roomCode)).value;
  if (room != null && room.hasEnded(DateTime.now())) {
    return true;
  }
  if (!context.mounted) {
    return false;
  }
  return showConfirmDialog(
    context,
    title: '今のルームを抜けて参加しますか?',
    content: 'ルーム ${current.roomCode} を抜けます。そのルームの履歴は残ります。',
    confirmLabel: '抜けて参加する',
  );
}

/// 確認してからルームを抜け、ホームへ戻る (ロビーと Mission 画面で使う)
///
/// 抜けたあともルームが終わるまで履歴の同期は続き、ホームの続きのカードから入り直せる。
Future<void> leaveRoomWithConfirm(BuildContext context, WidgetRef ref) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'ルームを抜けますか?',
    content: 'ルームが終わるまでは、\nホームからまた入れます。',
    confirmLabel: '抜ける',
  );
  if (!confirmed) return;
  ref.read(coopSessionStoreProvider.notifier).leave();
  if (context.mounted) context.go('/');
}
