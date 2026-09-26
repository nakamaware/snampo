import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';

/// 戻る (左上の戻るボタンと Android の戻る) で、ルームを抜けるかを確認する
///
/// 協力プレイのルームの画面 (ロビーと Mission 画面) を包む。戻っただけでルームに残ると、
/// 抜けたつもりの人がルームに残ってしまうため、戻るは「ルームを抜ける」と同じにする。
class LeaveRoomPopScope extends ConsumerWidget {
  /// [LeaveRoomPopScope] を作成する
  const LeaveRoomPopScope({required this.child, super.key});

  /// 包む画面
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        leaveRoomWithConfirm(context, ref);
      },
      child: child,
    );
  }
}
