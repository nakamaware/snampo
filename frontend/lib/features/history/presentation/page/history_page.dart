import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/presentation/hook/use_histories.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/history/presentation/util/history_fullscreen_image.dart';

/// 完了ミッション履歴の一覧
class HistoryPage extends HookConsumerWidget {
  /// [HistoryPage] を作成する
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    final historyAsync = useHistories(ref);
    final removedIds = useState<Set<String>>({});

    return Scaffold(
      appBar: AppBar(
        title: Text('履歴', style: titleTextStyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        leading: IconButton(
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
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _HistoryListTile(
                record: record,
                onTap: () => context.push('/history/${record.id}'),
                onRemoved: (id) {
                  removedIds.value = {...removedIds.value, id};
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Text('読み込みに失敗しました\n$error', textAlign: TextAlign.center),
            ),
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

    return Dismissible(
      key: ValueKey<String>(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmAndRemove(context, ref),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete, color: theme.colorScheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                _HistoryThumbnail(path: firstUserPhotoPath(record.spots)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatCompletedDate(record.completedAt),
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '所要時間: ${formatMissionDuration(record.startedAt, record.completedAt)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmAndRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await _showDeleteDialog(context);
    if (!confirmed) return false;
    if (!context.mounted) return false;

    return _executeRemove(context, ref, showRetryOnFailure: true);
  }

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

/// 履歴のリスト行にあるサムネイル
class _HistoryThumbnail extends StatelessWidget {
  const _HistoryThumbnail({this.path});

  final String? path;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filePath = path;

    if (filePath == null) return _placeholder(theme);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openHistoryFullscreenImageFromFile(context, filePath),
        child: Image.file(
          File(filePath),
          width: _size,
          height: _size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(theme),
        ),
      ),
    );
  }

  static Widget _placeholder(ThemeData theme) {
    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.image_not_supported_outlined,
        color: theme.colorScheme.outline,
      ),
    );
  }
}
