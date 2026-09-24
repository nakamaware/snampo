import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/presentation/component/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

/// ニックネームの入力ダイアログを表示し、入力された値を返す (キャンセルなら null)
///
/// 空欄なら自動で命名する (例: 「プレイヤー1234」)。
Future<String?> showNicknameDialog(
  BuildContext context, {
  String initialValue = '',
}) => showDialog<String>(
  context: context,
  builder: (context) => _NicknameDialog(initialValue: initialValue),
);

// controller はダイアログと同じ寿命にする。showDialog の Future は pop した時点で完了するが、
// ダイアログは閉じるアニメーションの間も TextField を描画するため、呼び出し側で破棄すると
// 破棄済みの controller が使われてしまう
class _NicknameDialog extends HookWidget {
  const _NicknameDialog({required this.initialValue});

  final String initialValue;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: initialValue);
    return AlertDialog(
      title: const Text('ニックネーム'),
      content: TextField(
        controller: controller,
        autofocus: true,
        maxLength: Nickname.maxLength,
        decoration: const InputDecoration(hintText: '空欄なら自動で命名します'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('決定'),
        ),
      ],
    );
  }
}

/// 保存したニックネームを返す。未設定なら入力を促し、入力した値をアプリに保存する
///
/// キャンセルされたら null を返す。
Future<Nickname?> ensureNickname(BuildContext context, WidgetRef ref) async {
  final saved = await ref.read(nicknameStoreProvider.future);
  if (saved != null) {
    return saved;
  }
  if (!context.mounted) {
    return null;
  }
  final input = await showNicknameDialog(context);
  if (input == null) {
    return null;
  }
  return ref.read(nicknameStoreProvider.notifier).save(input);
}

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
/// 抜けた時点までの進捗は履歴に残り、履歴の同期も続く。
Future<void> leaveRoomWithConfirm(BuildContext context, WidgetRef ref) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'ルームを抜けますか?',
    content: '抜けた時点までの進捗は履歴に残ります。',
    confirmLabel: '抜ける',
  );
  if (!confirmed) return;
  ref.read(coopSessionStoreProvider.notifier).leave();
  if (context.mounted) context.go('/');
}
