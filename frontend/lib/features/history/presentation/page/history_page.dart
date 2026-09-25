import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/coop_history_info.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/presentation/hook/use_histories.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';

/// 完了ミッション履歴の一覧
class HistoryPage extends HookConsumerWidget {
  /// [HistoryPage] を作成する
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = useHistories(ref);
    final removedIds = useState<Set<String>>({});

    return Scaffold(
      appBar: AppBar(
        title: Text('履歴', style: Theme.of(context).textTheme.headlineSmall),
        titleSpacing: 0,
        leading: IconButton(
          tooltip: '戻る',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: historyAsync.when(
        data: (data) {
          final records = data
              .where((h) => !removedIds.value.contains(h.id))
              .toList(growable: false);
          if (records.isEmpty) {
            return const _EmptyHistoryView();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              final month = formatHistoryMonth(record.completedAt);
              final isFirstOfMonth =
                  index == 0 ||
                  formatHistoryMonth(records[index - 1].completedAt) != month;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isFirstOfMonth) _MonthHeader(month),
                  _HistoryListTile(
                    record: record,
                    onTap: () => context.push('/history/${record.id}'),
                    onRemoved: (id) {
                      removedIds.value = {...removedIds.value, id};
                    },
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          log('HistoryPage load error', error: error, stackTrace: stackTrace);
          return const Center(child: Text('読み込みに失敗しました'));
        },
      ),
    );
  }
}

/// 履歴がない場合の表示
class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 240,
              child: Image.asset('images/snampo.png', fit: BoxFit.contain),
            ),
            const SizedBox(height: 24),
            Text(
              'まだ履歴がありません',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 履歴のリスト行
class _HistoryListTile extends ConsumerWidget {
  const _HistoryListTile({
    required this.record,
    required this.onTap,
    required this.onRemoved,
  });

  final MissionHistory record;
  final VoidCallback onTap;
  final void Function(String id) onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final found = record.spots.where((s) => s.isCleared).length;
    final duration = formatMissionDurationShort(
      record.startedAt,
      record.completedAt,
    );

    return Dismissible(
      key: ValueKey<String>(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final confirmed = await _showDeleteDialog(context);
        if (!confirmed) return false;
        if (!context.mounted) return false;
        return _executeRemove(context, ref, showRetryOnFailure: true);
      },
      background: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Icon(Icons.delete, color: theme.colorScheme.onError),
            ),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          elevation: 1,
          shadowColor: Colors.black26,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PhotoStrip(spots: record.spots),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatHistoryDate(record.completedAt),
                              style: theme.textTheme.titleMedium,
                            ),
                            Text(
                              '$found/${record.spots.length} 発見 · '
                              '$duration',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (record.coop case final coop?) ...[
                        _Chip(
                          label: 'みんなで',
                          background: theme.colorScheme.primaryContainer,
                          foreground: theme.colorScheme.onPrimaryContainer,
                        ),
                        // ほかの人の写真や採点を、まだ取りに行っている途中
                        if (coop.syncState == CoopSyncState.inProgress) ...[
                          const SizedBox(width: 6),
                          _Chip(
                            label: '同期中',
                            icon: Icons.sync,
                            background: theme.colorScheme.surfaceContainerHigh,
                            foreground: theme.colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 削除の確認ダイアログを表示する
  Future<bool> _showDeleteDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
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
        );
      },
    );
    return result ?? false;
  }

  /// 削除を実行する
  Future<bool> _executeRemove(
    BuildContext context,
    WidgetRef ref, {
    required bool showRetryOnFailure,
  }) async {
    try {
      await ref.read(removeMissionHistoryUseCaseProvider).call(record.id);
      onRemoved(record.id);
      return true;
    } catch (error, stackTrace) {
      log('履歴の削除に失敗', error: error, stackTrace: stackTrace);
      if (context.mounted && showRetryOnFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('履歴の削除に失敗しました'),
            action: SnackBarAction(
              label: '再試行',
              onPressed:
                  () => _executeRemove(context, ref, showRetryOnFailure: false),
            ),
          ),
        );
      }
      return false;
    }
  }
}

/// 月の見出し
class _MonthHeader extends StatelessWidget {
  const _MonthHeader(this.month);

  final String month;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
      child: Text(
        month,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

/// スポットの写真の帯 (最大 5 枚。多ければ 4 枚と「+N」)
class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({required this.spots});

  final List<MissionHistorySpot> spots;

  static const _slots = 5;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final overflow = spots.length > _slots;
    final shown = overflow ? spots.take(_slots - 1) : spots;
    return Row(
      children: [
        for (final (i, spot) in shown.indexed) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(child: _StripPhoto(spot: spot)),
        ],
        if (overflow) ...[
          const SizedBox(width: 4),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '+${spots.length - (_slots - 1)}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        for (var i = shown.length + (overflow ? 1 : 0); i < _slots; i++) ...[
          const SizedBox(width: 4),
          const Expanded(child: SizedBox()),
        ],
      ],
    );
  }
}

class _StripPhoto extends StatelessWidget {
  const _StripPhoto({required this.spot});

  final MissionHistorySpot spot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final path = spot.shownPhotoPath;
    final rank = spot.shownRank;
    final placeholder = ColoredBox(color: colorScheme.surfaceContainerHighest);
    if (!spot.isCleared) {
      // 見つからなかったスポットは、点線の空き枠にする
      return AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (path == null)
              placeholder
            else
              Image.file(
                File(path),
                fit: BoxFit.cover,
                cacheWidth: 160,
                errorBuilder: (_, _, _) => placeholder,
              ),
            if (rank != null)
              Positioned(
                right: 4,
                bottom: 4,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: rank.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const SizedBox.square(dimension: 9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon case final icon?) ...[
              Icon(icon, size: 12, color: foreground),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ],
        ),
      ),
    );
  }
}
