import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/page/lobby_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';

/// 協力プレイの Mission 画面 (端末で進行中のルーム)
///
/// 既存の Mission 画面に、協力プレイの部品を [MissionPageExtension] で差し込む。
class CoopMissionPage extends ConsumerWidget {
  /// [CoopMissionPage] を作成する
  const CoopMissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    if (session == null) {
      return const LobbyPage();
    }
    return MissionPage.resume(
      kind: MissionSessionKind.coop,
      extension: _CoopMissionPageExtension(session.roomCode),
    );
  }
}

class _CoopMissionPageExtension extends MissionPageExtension {
  const _CoopMissionPageExtension(this.roomCode);

  final RoomCode roomCode;

  @override
  Widget wrapBody(BuildContext context, Widget body) =>
      _CoopMissionEffects(roomCode: roomCode, child: body);

  @override
  List<Widget> appBarActions(BuildContext context) => [
    _CoopHostEndButton(roomCode: roomCode),
    const _CoopMissionMenu(),
  ];

  @override
  Widget? buildSpotExtra(
    BuildContext context, {
    required ImageCoordinate spot,
    required CheckpointProgress? checkpoint,
  }) => _CoopDiscovererView(
    roomCode: roomCode,
    spotId: spot.spotId,
    checkpoint: checkpoint,
  );

  /// 1 人のクリアで全員のクリアになり、クリア済みのスポットは誰も撮影できない
  @override
  bool canCapture(CheckpointProgress? checkpoint) =>
      checkpoint?.discovererUid == null;

  /// 発見の共有は裏で進める (共有中は「発見を共有中…」を表示する)
  @override
  void onCheckpointCompleted(
    WidgetRef ref, {
    required int index,
    required CheckpointProgress checkpoint,
  }) {
    unawaited(
      ref
          .read(coopMissionStoreProvider(roomCode).notifier)
          .clearSpot(spotIndex: index, checkpoint: checkpoint),
    );
  }

  /// 全スポットのクリアかホストの途中終了で、全員が結果画面へ自動で遷移する
  @override
  bool get showsResultButton => false;
}

/// 協力プレイの Mission 画面で、ルームの変化に反応する (バナーと結果画面への遷移)
class _CoopMissionEffects extends HookConsumerWidget {
  const _CoopMissionEffects({required this.roomCode, required this.child});

  /// ルームコード
  final RoomCode roomCode;

  /// 中身
  final Widget child;

  /// 期限切れを知らせて結果画面へ移る
  static void _goToResultAsExpired(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('このルームは期限切れです')));
    context.go('/coop/result');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ミッションの用意とクリアの同期は、協力プレイ中ずっと動かす
    ref
      ..watch(coopMissionStoreProvider(roomCode).select((_) => null))
      // 「○○さんがスポット N を発見!」などのお知らせ
      ..listen(coopMissionStoreProvider(roomCode).select((s) => s.notice), (
        _,
        notice,
      ) {
        if (notice == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(notice.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
      })
      // finished になったら全員が結果画面へ自動で遷移する
      ..listen(coopRoomProvider(roomCode), (_, next) {
        if (next.value?.status == RoomStatus.finished) {
          context.go('/coop/result');
        }
      });

    // 遊べる期限を過ぎると誰も finished にできないので、期限切れとして結果画面へ移る
    final expiresAt = ref.watch(
      coopRoomProvider(roomCode).select((room) => room.value?.expiresAt),
    );
    useEffect(() {
      if (expiresAt == null) return null;
      final remaining = expiresAt.difference(DateTime.now());
      if (remaining <= Duration.zero) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) _goToResultAsExpired(context);
        });
        return null;
      }
      final timer = Timer(remaining, () {
        if (context.mounted) _goToResultAsExpired(context);
      });
      return timer.cancel;
    }, [expiresAt]);

    final prepareError = ref.watch(
      coopMissionStoreProvider(roomCode).select((s) => s.prepareError),
    );
    if (prepareError != null) {
      return _PrepareErrorView(roomCode: roomCode);
    }
    return child;
  }
}

/// AppBar のメニュー (「ルームを抜ける」)
class _CoopMissionMenu extends ConsumerWidget {
  const _CoopMissionMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<void>(
      iconColor: Theme.of(context).colorScheme.onPrimary,
      itemBuilder:
          (context) => [
            PopupMenuItem(
              onTap: () => leaveRoomWithConfirm(context, ref),
              child: const Text('ルームを抜ける'),
            ),
          ],
    );
  }
}

class _PrepareErrorView extends ConsumerWidget {
  const _PrepareErrorView({required this.roomCode});

  final RoomCode roomCode;

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
                  () =>
                      ref
                          .read(coopMissionStoreProvider(roomCode).notifier)
                          .retryPrepare(),
              child: const Text('再試行'),
            ),
          ],
        ),
      ),
    );
  }
}

/// ホストだけに表示する「途中終了」ボタン (確認ダイアログあり)
class _CoopHostEndButton extends ConsumerWidget {
  const _CoopHostEndButton({required this.roomCode});

  /// ルームコード
  final RoomCode roomCode;

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
        final confirmed = await showConfirmDialog(
          context,
          title: 'ミッションを終了しますか?',
          content: '全員のミッションが終了し、結果画面に移ります。',
          confirmLabel: '終了する',
        );
        if (!confirmed) return;
        try {
          await ref
              .read(coopMissionStoreProvider(roomCode).notifier)
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
class _CoopDiscovererView extends ConsumerWidget {
  const _CoopDiscovererView({
    required this.roomCode,
    required this.spotId,
    required this.checkpoint,
  });

  /// ルームコード
  final RoomCode roomCode;

  /// スポット ID
  final SpotId? spotId;

  /// このスポットの進捗
  final CheckpointProgress? checkpoint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isSharing = ref.watch(
      coopMissionStoreProvider(
        roomCode,
      ).select((s) => spotId != null && s.sharingSpotIds.contains(spotId)),
    );
    final discovererUid = checkpoint?.discovererUid;
    // 重複した名前には、表示するときだけ入室順に番号を付ける
    final members = ref.watch(coopMembersProvider(roomCode)).value ?? const [];
    final discoverer =
        discovererUid == null
            ? null
            : displayNicknames([
                  for (final m in members) (uid: m.uid, nickname: m.nickname),
                ])[discovererUid] ??
                checkpoint?.discovererNickname;
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
          Text(discovererLabel(discoverer), style: theme.textTheme.bodySmall),
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
