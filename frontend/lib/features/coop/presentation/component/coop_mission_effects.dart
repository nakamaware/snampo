import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// 最後のスポットの結果画面の、閉じるボタンの文言
const finalSpotCloseLabel = '結果を見る';

/// 最後のスポットの結果画面を開く前に、`clears` の反映を待つ時間
const _finalSpotSyncTimeout = Duration(seconds: 10);

/// 協力プレイの Mission 画面で、ルームの変化に反応する (バナーと結果画面への遷移)
///
/// ミッションの用意に失敗したら、[child] の代わりに再試行の案内を出す。
class CoopMissionEffects extends HookConsumerWidget {
  /// [CoopMissionEffects] を作成する
  const CoopMissionEffects({
    required this.roomCode,
    required this.child,
    super.key,
  });

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
    if (checkpoint == null) {
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

  /// スポットの結果画面を開き、閉じるまで待つ
  ///
  /// 開いている間は [showingSpot] を true にする。画面の切り替えは次のフレームなので、
  /// その間に届いた発見で結果画面を重ねて開かないようにするため。
  static Future<void> _showSpotResult(
    BuildContext context,
    SpotResultPageArgs args,
    ObjectRef<bool> showingSpot,
  ) async {
    showingSpot.value = true;
    try {
      await context.push<void>('/spot-result', extra: args);
    } finally {
      showingSpot.value = false;
    }
  }

  /// スポットの結果画面を開いてよいか
  ///
  /// Mission 画面が前面にあり、ほかのスポットの結果画面を開いていないときだけ開く
  /// (撮影中やスポットの結果画面を見ている間は割り込まず、重ねて開かない)。
  static bool _canShowSpotResult(
    BuildContext context,
    ObjectRef<bool> showingSpot,
  ) => !showingSpot.value && (ModalRoute.of(context)?.isCurrent ?? false);

  /// 他の人が発見したスポットの結果画面を開く
  ///
  /// Mission 画面が前面にあるときだけ開く (撮影中やほかのスポットの結果画面を見ている間は
  /// 割り込まず、お知らせだけにする)。
  static void _openDiscoveredSpot(
    BuildContext context,
    WidgetRef ref,
    CoopDiscoveryEvent discovery,
    ObjectRef<bool> showingSpot,
  ) {
    if (!_canShowSpotResult(context, showingSpot)) {
      return;
    }
    final args = _spotResultArgs(
      ref,
      discovery.spotIndex,
      discovererDisplayName: discovery.discovererName,
    );
    if (args != null) {
      unawaited(_showSpotResult(context, args, showingSpot));
    }
  }

  /// ルームが終わったら、Mission 画面が前面に戻った時点で結果画面へ移る
  ///
  /// 他の人がその場で最後のスポットを発見して終わったときは、先にそのスポットの結果画面を
  /// 開き、それを閉じて戻ってきたら結果画面へ移る。ルームに戻ったときに追いついた発見や、
  /// 自分で撮影した (結果を見た) スポットなら開かない。
  static Future<void> _onFinished(
    BuildContext context,
    WidgetRef ref,
    RoomCode roomCode,
    FinishReason? finishReason,
    ObjectRef<bool> finalSpotShown,
    ObjectRef<bool> showingSpot,
  ) async {
    if (showingSpot.value) return;
    if (finishReason != FinishReason.allCleared || finalSpotShown.value) {
      context.go('/coop/result');
      return;
    }
    finalSpotShown.value = true;
    // 発見者とサムネを進捗に反映し終えてから開く。反映が終わらなければ (電波が弱く、
    // サムネの取得が終わらないなど) 待ち続けず、反映できた分で開く
    final store = ref.read(coopMissionStoreProvider(roomCode).notifier);
    await store.clearsSynced.timeout(_finalSpotSyncTimeout, onTimeout: () {});
    if (!context.mounted) return;
    if (!_canShowSpotResult(context, showingSpot)) {
      // 待っている間に、ほかのスポットの結果画面が開いた (その前のスポットの反映が
      // 終わったなど) か、撮影を始めた。重ねて開かず、Mission 画面が前面に戻ったら開き直す
      finalSpotShown.value = false;
      return;
    }
    final discovery =
        ref.read(coopMissionStoreProvider(roomCode)).finalDiscovery;
    final args =
        discovery == null
            ? null
            : _spotResultArgs(
              ref,
              discovery.spotIndex,
              discovererDisplayName: discovery.discovererName,
              closeLabel: finalSpotCloseLabel,
            );
    // 自分で撮影した (結果を見た) スポットなら開かない
    if (args == null || args.checkpoint.userPhotoPath != null) {
      context.go('/coop/result');
      return;
    }
    await _showSpotResult(context, args, showingSpot);
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
    // スポットの結果画面を開いているか (重ねて開かないため)
    final showingSpot = useRef(false);
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
      // 他の人がその場で発見したら、全員でそのスポットの結果画面を見る
      ..listen(coopMissionStoreProvider(roomCode).select((s) => s.discovery), (
        _,
        discovery,
      ) {
        if (discovery != null) {
          _openDiscoveredSpot(context, ref, discovery, showingSpot);
        }
      });

    // finished になったら全員が結果画面へ移る。撮影中やスポットの結果画面を見ている間は
    // 割り込まず、Mission 画面が前面に戻った時点で移る。
    // 終了したことと理由だけを見る (finished を書いた端末には、あとからサーバで確定した
    // 終了日時が届く。それで反応し直すと、最後のスポットを開く前に結果画面へ移ってしまう)
    final finished = ref.watch(
      coopRoomProvider(roomCode).select((room) {
        final value = room.value;
        return value?.status == RoomStatus.finished
            ? (reason: value?.finishReason)
            : null;
      }),
    );
    final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
    final finalSpotShown = useRef(false);
    useEffect(() {
      if (finished == null || !isCurrent) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 撮影した人は、カメラを閉じた直後にスポットの結果画面を開く。その間に移らないよう、
        // 次のフレームでも前面にあるときだけ移る
        if (context.mounted && (ModalRoute.of(context)?.isCurrent ?? false)) {
          unawaited(
            _onFinished(
              context,
              ref,
              roomCode,
              finished.reason,
              finalSpotShown,
              showingSpot,
            ),
          );
        }
      });
      return null;
    }, [finished, isCurrent]);

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
