import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_controller.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';

/// 協力プレイの Mission 画面で、ルームの変化に反応する (バナーと結果画面への遷移)
class CoopMissionEffects extends ConsumerWidget {
  /// [CoopMissionEffects] を作成する
  const CoopMissionEffects({
    required this.roomCode,
    required this.child,
    super.key,
  });

  /// ルームコード
  final String roomCode;

  /// 中身
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 「○○さんがスポット N を発見!」などのお知らせ
    ref
      ..listen(
        coopMissionControllerProvider(roomCode).select((s) => s.notice),
        (_, notice) {
          if (notice == null) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(notice.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
      )
      // finished になったら全員が結果画面へ自動で遷移する
      ..listen(coopRoomProvider(roomCode), (_, next) {
        if (next.value?.status == RoomStatus.finished) {
          context.go('/coop/result');
        }
      });
    final prepareError = ref.watch(
      coopMissionControllerProvider(roomCode).select((s) => s.prepareError),
    );
    if (prepareError != null) {
      return _PrepareErrorView(roomCode: roomCode);
    }
    return child;
  }
}

class _PrepareErrorView extends ConsumerWidget {
  const _PrepareErrorView({required this.roomCode});

  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('ミッションを受け取れませんでした。電波の良い場所で再試行してください。'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed:
                  () => ref.invalidate(coopMissionControllerProvider(roomCode)),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ホストだけに表示する「途中終了」ボタン (確認ダイアログあり)
class CoopHostEndButton extends ConsumerWidget {
  /// [CoopHostEndButton] を作成する
  const CoopHostEndButton({required this.roomCode, super.key});

  /// ルームコード
  final String roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    final room = ref.watch(coopRoomProvider(roomCode)).value;
    if (session == null ||
        room == null ||
        !room.isHost(session.uid) ||
        room.status != RoomStatus.playing) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: theme.colorScheme.onPrimary),
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('ミッションを終了しますか?'),
                content: const Text('全員のミッションが終了し、結果画面に移ります。'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('キャンセル'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('終了する'),
                  ),
                ],
              ),
        );
        if (confirmed != true) return;
        try {
          await ref
              .read(coopMissionControllerProvider(roomCode).notifier)
              .endByHost();
        } on Object {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('終了できませんでした。再度お試しください')),
            );
          }
        }
      },
      child: const Text('途中終了'),
    );
  }
}

/// スポットカードに表示する発見者とサムネ
class CoopDiscovererView extends ConsumerWidget {
  /// [CoopDiscovererView] を作成する
  const CoopDiscovererView({
    required this.roomCode,
    required this.spotId,
    required this.checkpoint,
    super.key,
  });

  /// ルームコード
  final String roomCode;

  /// スポット ID
  final String? spotId;

  /// このスポットの進捗
  final CheckpointProgress? checkpoint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSharing = ref.watch(
      coopMissionControllerProvider(
        roomCode,
      ).select((s) => spotId != null && s.sharingSpotIds.contains(spotId)),
    );
    final discoverer = checkpoint?.discovererNickname;
    final thumbPath = checkpoint?.discovererThumbPath;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (discoverer != null) ...[
          SizedBox(
            width: 64,
            height: 64,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  thumbPath == null
                      ? const ColoredBox(
                        color: Colors.black12,
                        child: Icon(Icons.image_outlined),
                      )
                      : Image.file(File(thumbPath), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 4),
          Text('発見: $discoverer', style: theme.textTheme.bodySmall),
        ],
        if (isSharing)
          Text(
            '発見を共有中…',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
