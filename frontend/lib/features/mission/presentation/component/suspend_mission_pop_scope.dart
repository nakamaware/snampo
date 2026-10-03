import 'package:flutter/material.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/presentation/confirm_dialog.dart';

/// 戻る (左上の戻るボタンと Android の戻る) で、ソロのミッションを中断するかを確認する
///
/// 誤操作で画面を離れないようにするためのもの。進捗は保存されていて、ホームから再開できるので、
/// 中断しても進捗は消さない。iOS のスワイプで戻る操作は、`PopScope` が戻れない間は無効になる。
/// 協力プレイはモードの画面がルームを抜けるかを確認するので、ここでは何もしない。
class SuspendMissionPopScope extends StatelessWidget {
  /// [SuspendMissionPopScope] を作成する
  const SuspendMissionPopScope({
    required this.kind,
    required this.child,
    super.key,
  });

  /// ミッションの種類 (ソロのときだけ確認する)
  final MissionSessionKind kind;

  /// 包む画面
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (kind != MissionSessionKind.solo) return child;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final confirmed = await showConfirmDialog(
          context,
          title: 'ミッションを中断しますか?',
          content: 'ホームの『ソロの続きをする』から再開できます。',
          confirmLabel: '中断する',
        );
        if (confirmed && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
