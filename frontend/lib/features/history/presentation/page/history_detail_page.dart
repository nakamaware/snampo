import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/discoverer_rank.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/component/history_route_map.dart';
import 'package:snampo/features/history/presentation/component/history_spot_block.dart';
import 'package:snampo/features/history/presentation/hook/use_history_detail.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';

/// 1 件の履歴の詳細
///
/// 上に歩いたルートの地図、その下にプレイ結果と同じまとめ、スポットごとに見本と撮った写真を並べる。
/// 削除すると、一覧に `true` を返して戻る。
class HistoryDetailPage extends HookConsumerWidget {
  /// [HistoryDetailPage] を作成する
  const HistoryDetailPage({required this.recordId, super.key});

  /// 履歴の id ( [MissionHistory.id] )
  final String recordId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = useHistoryDetail(ref, recordId);

    return detailAsync.when(
      data: (found) {
        if (found == null) {
          return const _MessageScaffold(message: 'この履歴は見つかりませんでした');
        }
        return _HistoryDetailBody(record: found);
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        log(
          'HistoryDetailPage load error',
          error: error,
          stackTrace: stackTrace,
        );
        return const _MessageScaffold(message: '読み込みに失敗しました');
      },
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [Center(child: Text(message)), const MapTopBar()]),
    );
  }
}

/// 履歴の詳細の本体
class _HistoryDetailBody extends ConsumerWidget {
  const _HistoryDetailBody({required this.record});

  final MissionHistory record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coop = record.coop;
    // 重複した名前には、表示するときだけ入室順に番号を付ける
    final displayNames =
        coop == null
            ? const <String, String>{}
            : displayNicknames([
              for (final m in coop.members) (uid: m.uid, nickname: m.nickname),
            ]);
    // 自分の uid は保存していないので、自分の写真で発見したスポットの発見者から分かる
    final myUid =
        record.spots
            .where((s) => s.userPhotoPath != null && s.discovererUid != null)
            .firstOrNull
            ?.discovererUid;

    return Scaffold(
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.paddingOf(context).bottom + 24,
            ),
            children: [
              SizedBox(
                height:
                    MediaQuery.paddingOf(context).top + MapTopBar.height + 170,
                child: HistoryRouteMap(record: record),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: MissionRecap(
                  caption: [
                    formatCompletedDate(record.completedAt),
                    if (coop == null) 'ひとりで' else 'みんなで',
                  ].join(' · '),
                  meta: [
                    formatMissionDuration(record.startedAt, record.completedAt),
                    _settingsLabel(),
                  ].join(' · '),
                  spots: [
                    for (final s in record.spots)
                      (found: s.isCleared, rank: s.shownRank),
                  ],
                  members:
                      coop == null
                          ? const []
                          : _members(
                            uids: [for (final m in coop.members) m.uid],
                            displayNames: displayNames,
                            myUid: myUid,
                          ),
                ),
              ),
              for (final (i, spot) in record.spots.indexed)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: HistorySpotBlock(
                    record: record,
                    spot: spot,
                    index: i,
                    ownerLabel: _ownerLabel(spot, displayNames, myUid),
                    discovererName:
                        displayNames[spot.discovererUid] ??
                        spot.discovererNickname,
                  ),
                ),
            ],
          ),
          MapTopBar(
            actions: [
              PopupMenuButton<void>(
                tooltip: 'メニュー',
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        onTap: () => _confirmRemove(context, ref),
                        child: const Text('この履歴を削除'),
                      ),
                    ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _settingsLabel() => switch (record.settings) {
    MissionSettingsRandom(:final radius) => 'ランダム 半径 ${radius.meters} m',
    MissionSettingsDestination() =>
      '目的地指定 · ${record.spots.lastOrNull?.name ?? '指定したゴール地点'}',
  };

  /// 見つけた数の多い順 (同数なら入室順)
  List<RecapMember> _members({
    required List<String> uids,
    required Map<String, String> displayNames,
    required String? myUid,
  }) {
    final discoveries = [
      for (final spot in record.spots)
        if (spot.discovererUid != null && spot.isCleared) spot,
    ];
    // 抜けたメンバーなどで名前がなければ、発見時点のニックネームで表示する
    final fallbackNames = {
      for (final spot in discoveries)
        spot.discovererUid!: spot.discovererNickname,
    };
    return [
      for (final rank in rankDiscoverers(
        discovererUids: [for (final s in discoveries) s.discovererUid!],
        uidsInJoinOrder: uids,
      ))
        (
          name: displayNames[rank.uid] ?? fallbackNames[rank.uid] ?? '???',
          count: rank.count,
          isMe: rank.uid == myUid,
        ),
    ];
  }

  /// 写真を撮った人の名札 (ソロは全部自分の写真なので付けない)
  String? _ownerLabel(
    MissionHistorySpot spot,
    Map<String, String> displayNames,
    String? myUid,
  ) {
    if (record.coop == null) return null;
    if (spot.userPhotoPath != null) return 'あなた';
    final uid = spot.discovererUid;
    if (uid == null) return null;
    return uid == myUid
        ? 'あなた'
        : displayNames[uid] ?? spot.discovererNickname ?? '発見者';
  }

  Future<void> _confirmRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('削除の確認'),
            content: const Text('この履歴を削除しますか？写真ファイルも削除されます。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('キャンセル'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('削除'),
              ),
            ],
          ),
    );
    if (confirmed != true || !context.mounted) return;
    try {
      await ref.read(removeMissionHistoryUseCaseProvider).call(record.id);
    } catch (error, stackTrace) {
      log('履歴の削除に失敗', error: error, stackTrace: stackTrace);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('履歴の削除に失敗しました')));
      }
      return;
    }
    if (context.mounted) context.pop(true);
  }
}
