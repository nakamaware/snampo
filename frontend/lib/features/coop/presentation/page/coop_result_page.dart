import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/domain/entity/spot_clear.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';
import 'package:snampo/features/mission/presentation/page/result_page.dart';

/// 協力プレイの結果画面
///
/// 既存の結果画面に、スポットごとの発見者と未クリアの表示、発見数ランキングを
/// [ResultPageExtension] で差し込む。
class CoopResultPage extends StatelessWidget {
  /// [CoopResultPage] を作成する
  const CoopResultPage({super.key});

  @override
  Widget build(BuildContext context) => const ResultPage(
    kind: MissionSessionKind.coop,
    extension: _CoopResultPageExtension(),
  );
}

class _CoopResultPageExtension extends ResultPageExtension {
  const _CoopResultPageExtension();

  @override
  Widget? buildHeader(BuildContext context, MissionProgressEntity progress) {
    final roomCode = progress.roomCode;
    return roomCode == null
        ? null
        : _CoopResultRanking(roomCode: roomCode, progress: progress);
  }

  @override
  String? spotStatusLabel(CheckpointProgress? checkpoint) {
    final discoverer = checkpoint?.discovererNickname;
    return discoverer == null ? '未クリア' : '発見: $discoverer';
  }

  /// 端末の「ルームに戻る」を消す (履歴の同期は続く)
  @override
  Future<void> onFinish(WidgetRef ref) async {
    ref.read(coopSessionStoreProvider.notifier).clear();
  }
}

/// 結果画面に表示する発見数ランキング (誰が何個見つけたか)
class _CoopResultRanking extends ConsumerWidget {
  const _CoopResultRanking({required this.roomCode, required this.progress});

  /// ルームコード
  final String roomCode;

  /// 協力プレイの進捗 (発見者つき)
  final MissionProgressEntity progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final members = ref.watch(coopMembersProvider(roomCode)).value ?? const [];
    final names = displayNicknames([
      for (final m in members) (uid: m.uid, nickname: m.nickname),
    ]);
    final discoveries = [
      for (final cp in progress.checkpoints)
        if (cp?.discovererUid != null) cp!,
    ];
    final ranking = rankDiscoverers(
      clears: [
        for (final cp in discoveries)
          SpotClear(
            spotId: '',
            clearedBy: cp.discovererUid!,
            nickname: cp.discovererNickname ?? '',
            clearedAt: cp.achievedAt ?? DateTime.now(),
          ),
      ],
      uidsInJoinOrder: [for (final m in members) m.uid],
    );
    // メンバーを読めない場合 (オフラインなど) は発見時点のニックネームで表示する
    final fallbackNames = {
      for (final cp in discoveries) cp.discovererUid!: cp.discovererNickname,
    };
    final cleared = discoveries.length;
    final total = progress.checkpoints.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'みんなで $cleared / $total スポットを発見',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final (i, rank) in ranking.indexed)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(width: 32, child: Text('${i + 1}.')),
                    Expanded(
                      child: Text(
                        names[rank.uid] ?? fallbackNames[rank.uid] ?? '???',
                      ),
                    ),
                    Text('${rank.count} 個'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
