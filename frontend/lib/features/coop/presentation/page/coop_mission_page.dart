import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/component/leave_room_pop_scope.dart';
import 'package:snampo/features/coop/presentation/component/room_info.dart';
import 'package:snampo/features/coop/presentation/page/lobby_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/photo_rejected_exception.dart';
import 'package:snampo/features/mission/presentation/page/mission_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

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
      _CoopMissionEffects(roomCode: roomCode, child: body);

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
    return isLast ? _finalSpotCloseLabel : null;
  }

  /// 全スポットのクリアかホストのゲーム終了で、全員が結果画面へ自動で遷移する
  @override
  bool get showsResultButton => false;
}

/// 最後のスポットの結果画面の、閉じるボタンの文言
const _finalSpotCloseLabel = '結果を見る';

/// 協力プレイの Mission 画面で、ルームの変化に反応する (バナーと結果画面への遷移)
class _CoopMissionEffects extends HookConsumerWidget {
  const _CoopMissionEffects({required this.roomCode, required this.child});

  /// ルームコード
  final RoomCode roomCode;

  /// 中身
  final Widget child;

  /// [index] 番目のスポットの結果画面の引数
  ///
  /// ミッションか、そのスポットの進捗がなければ null。
  static SpotResultPageArgs? _spotResultArgs(
    WidgetRef ref,
    int index, {
    required String? discovererDisplayName,
    bool Function(CheckpointProgress checkpoint)? where,
    String? closeLabel,
  }) {
    final mission =
        ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;
    final checkpoints =
        ref
            .read(missionProgressStoreProvider(MissionSessionKind.coop))
            .value
            ?.checkpoints;
    if (mission == null ||
        checkpoints == null ||
        index < 0 ||
        index >= mission.spots.length ||
        index >= checkpoints.length) {
      return null;
    }
    final checkpoint = checkpoints[index];
    if (checkpoint == null || !(where?.call(checkpoint) ?? true)) {
      return null;
    }
    return SpotResultPageArgs(
      spotIndex: index,
      totalCheckpointCount: mission.spots.length,
      missionPoint: mission.spots[index],
      checkpoint: checkpoint,
      isDestinationMode: mission.radius == null,
      kind: MissionSessionKind.coop,
      discovererDisplayName: discovererDisplayName,
      closeLabel: closeLabel,
    );
  }

  /// 他の人が発見したスポットの結果画面を開く
  ///
  /// Mission 画面が前面にあるときだけ開く (撮影中などは割り込まず、お知らせだけにする)。
  static void _openDiscoveredSpot(
    BuildContext context,
    WidgetRef ref,
    CoopDiscoveryEvent discovery,
  ) {
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final args = _spotResultArgs(
      ref,
      discovery.spotIndex,
      discovererDisplayName: discovery.discovererName,
    );
    if (args != null) {
      context.push('/spot-result', extra: args);
    }
  }

  /// ルームが終わったら、Mission 画面が前面に戻った時点で結果画面へ移る
  ///
  /// 全スポットのクリアで終わったときは、先に最後に発見されたスポットの結果画面を開き、
  /// それを閉じて戻ってきたら結果画面へ移る。自分で撮影した (結果を見た) スポットなら開かない。
  static Future<void> _onFinished(
    BuildContext context,
    WidgetRef ref,
    RoomCode roomCode,
    Room room,
    ObjectRef<bool> finalSpotShown,
  ) async {
    if (room.finishReason != FinishReason.allCleared || finalSpotShown.value) {
      context.go('/coop/result');
      return;
    }
    finalSpotShown.value = true;
    // 発見者とサムネを進捗に反映し終えてから開く
    await ref.read(coopMissionStoreProvider(roomCode).notifier).clearsSynced;
    if (!context.mounted) return;
    final clears =
        ref.read(coopClearsProvider(roomCode)).value?.clears ?? const [];
    final mission =
        ref.read(persistedMissionProvider(MissionSessionKind.coop)).value;
    if (clears.isEmpty || mission == null) {
      context.go('/coop/result');
      return;
    }
    final last = clears.reduce(
      (a, b) => a.clearedAt.isAfter(b.clearedAt) ? a : b,
    );
    final members = ref.read(coopMembersProvider(roomCode)).value ?? const [];
    final args = _spotResultArgs(
      ref,
      mission.spots.indexWhere((s) => s.spotId == last.spotId),
      discovererDisplayName:
          displayNicknames([
            for (final m in members) (uid: m.uid, nickname: m.nickname),
          ])[last.clearedBy] ??
          last.nickname,
      // 自分で撮影した (結果を見た) スポットなら開かない
      where: (checkpoint) => checkpoint.userPhotoPath == null,
      closeLabel: _finalSpotCloseLabel,
    );
    if (args == null) {
      context.go('/coop/result');
      return;
    }
    await context.push<void>('/spot-result', extra: args);
  }

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
      // 他の人が発見したら、全員でそのスポットの結果画面を見る
      ..listen(coopMissionStoreProvider(roomCode).select((s) => s.discovery), (
        _,
        discovery,
      ) {
        if (discovery != null) _openDiscoveredSpot(context, ref, discovery);
      });

    // finished になったら全員が結果画面へ移る。撮影中やスポットの結果画面を見ている間は
    // 割り込まず、Mission 画面が前面に戻った時点で移る
    final finishedRoom = ref.watch(
      coopRoomProvider(roomCode).select((room) {
        final value = room.value;
        return value?.status == RoomStatus.finished ? value : null;
      }),
    );
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final finalSpotShown = useRef(false);
    useEffect(() {
      if (finishedRoom == null || !isCurrent) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 撮影した人は、カメラを閉じた直後にスポットの結果画面を開く。その間に移らないよう、
        // 次のフレームでも前面にあるときだけ移る
        if (context.mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          unawaited(
            _onFinished(context, ref, roomCode, finishedRoom, finalSpotShown),
          );
        }
      });
      return null;
    }, [finishedRoom, isCurrent]);

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
