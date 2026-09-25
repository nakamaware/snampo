import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/component/coop_mission_effects.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/component/leave_room_pop_scope.dart';
import 'package:snampo/features/coop/presentation/component/room_info.dart';
import 'package:snampo/features/coop/presentation/page/lobby_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/util/photo_rejected_exception.dart';

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
    return LeaveRoomPopScope(
      child: MissionPage.resume(
        kind: MissionSessionKind.coop,
        extension: _CoopMissionPageExtension(session.roomCode),
      ),
    );
  }
}

class _CoopMissionPageExtension extends MissionPageExtension {
  const _CoopMissionPageExtension(this.roomCode);

  final RoomCode roomCode;

  @override
  Widget wrapBody(BuildContext context, Widget body) =>
      CoopMissionEffects(roomCode: roomCode, child: body);

  @override
  List<Widget> topActions(BuildContext context) => [
    _CoopMissionMenu(roomCode: roomCode),
  ];

  /// 自分の発見は「あなた」、他の人は入室順に番号を付けた名前 (重複した名前を見分けるため)
  @override
  String? discovererName(
    WidgetRef ref, {
    required CheckpointProgress? checkpoint,
  }) {
    final uid = checkpoint?.discovererUid;
    if (uid == null) return null;
    if (uid == ref.watch(coopSessionStoreProvider).value?.uid) return 'あなた';
    final members = ref.watch(coopMembersProvider(roomCode)).value ?? const [];
    return displayNicknames([
          for (final m in members) (uid: m.uid, nickname: m.nickname),
        ])[uid] ??
        checkpoint?.discovererNickname;
  }

  /// 1 人のクリアで全員のクリアになり、クリア済みのスポットは誰も撮影できない。
  /// 共有中のスポットも撮影できない (同じ発見を並行して送らないため)
  @override
  bool canCapture(
    WidgetRef ref, {
    required ImageCoordinate spot,
    required CheckpointProgress? checkpoint,
  }) =>
      checkpoint?.discovererUid == null &&
      !ref.watch(
        coopMissionStoreProvider(
          roomCode,
        ).select((s) => s.sharingSpotIds.contains(spot.spotId)),
      );

  /// 発見の共有が終わるまで撮影画面のローディングを続け、共有できたら結果画面へ進む。
  /// 共有できなければ撮影を捨て、理由を表示する (結果画面へは進まず、撮り直せる)
  @override
  Future<void> onCheckpointCompleted(
    WidgetRef ref, {
    required int index,
    required CheckpointProgress checkpoint,
  }) async {
    final error = await ref
        .read(coopMissionStoreProvider(roomCode).notifier)
        .clearSpot(spotIndex: index, checkpoint: checkpoint);
    if (error != null) {
      throw PhotoRejectedException(error);
    }
  }

  @override
  String get captureLoadingMessage => '採点して、発見を共有しています...';

  /// 最後のスポットの結果画面は、閉じるとプレイ結果へ移る
  @override
  String? spotResultCloseLabel(WidgetRef ref, {required int index}) {
    final checkpoints =
        ref
            .read(missionProgressStoreProvider(MissionSessionKind.coop))
            .value
            ?.checkpoints ??
        const [];
    final isLast = checkpoints.indexed.every(
      (e) => e.$1 == index || (e.$2?.hasResult ?? false),
    );
    return isLast ? finalSpotCloseLabel : null;
  }

  /// 全スポットのクリアかホストのゲーム終了で、全員が結果画面へ自動で遷移する
  @override
  bool get showsResultButton => false;
}

/// 地図の右上のメニュー (全員に「ルーム情報」「ルームを抜ける」、ホストには「ゲーム終了」)
///
/// 「ゲーム終了」は全員のミッションを終える操作なので、押し間違えないようメニューに入れる。
class _CoopMissionMenu extends ConsumerWidget {
  const _CoopMissionMenu({required this.roomCode});

  /// ルームコード
  final RoomCode roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(coopSessionStoreProvider).value;
    final room = ref.watch(coopRoomProvider(roomCode)).value;
    final canEnd =
        session != null &&
        room != null &&
        room.isHost(session.uid) &&
        room.status == RoomStatus.playing;
    return PopupMenuButton<void>(
      tooltip: 'メニュー',
      itemBuilder:
          (_) => [
            PopupMenuItem(
              onTap: () => showRoomInfoSheet(context, roomCode),
              child: const _MenuItemLabel(icon: Icons.qr_code, label: 'ルーム情報'),
            ),
            PopupMenuItem(
              onTap: () => leaveRoomWithConfirm(context, ref),
              child: const _MenuItemLabel(icon: Icons.logout, label: 'ルームを抜ける'),
            ),
            if (canEnd)
              PopupMenuItem(
                onTap: () => _endByHostWithConfirm(context, ref, roomCode),
                child: const _MenuItemLabel(
                  icon: Icons.flag_outlined,
                  label: 'ゲーム終了',
                ),
              ),
          ],
    );
  }
}

/// メニューの項目 (アイコンと文言)
class _MenuItemLabel extends StatelessWidget {
  const _MenuItemLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(label)],
    );
  }
}

/// 確認してから、ホストとしてゲームを終了する
Future<void> _endByHostWithConfirm(
  BuildContext context,
  WidgetRef ref,
  RoomCode roomCode,
) async {
  final confirmed = await showConfirmDialog(
    context,
    title: 'ゲームを終了しますか?',
    content: '全員のゲームが終了し、結果画面に移ります。',
    confirmLabel: '終了する',
  );
  if (!confirmed) return;
  try {
    await ref.read(coopMissionStoreProvider(roomCode).notifier).endByHost();
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('終了できませんでした。再度お試しください')));
    }
  }
}
