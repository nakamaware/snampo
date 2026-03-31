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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      child: Image.asset(
                        'images/snampo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'まだ履歴がありません',
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return _HistoryListTile(
                record: record,
                onTap: () {
                  context.push('/history/${record.id}');
                },
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
    final completed = record.completedAt;
    final durationText = formatMissionDuration(
      record.startedAt,
      record.completedAt,
    );
    final thumbPath = firstUserPhotoPath(record.spots);
    late final Widget thumbWidget;
    final thumbPathNonNull = thumbPath;
    if (thumbPathNonNull != null && File(thumbPathNonNull).existsSync()) {
      final path = thumbPathNonNull;
      thumbWidget = Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openHistoryFullscreenImageFromFile(context, path),
          child: Image.file(
            File(path),
            width: 72,
            height: 72,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      thumbWidget = Container(
        width: 72,
        height: 72,
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

    return Dismissible(
      key: ValueKey<String>(record.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
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
        if (!(confirmed ?? false)) {
          return false;
        }
        try {
          await ref.read(removeMissionHistoryUseCaseProvider).call(record.id);
          onRemoved(record.id);
          return true;
        } catch (error, stackTrace) {
          log('履歴の削除に失敗', error: error, stackTrace: stackTrace);
          return false;
        }
      },
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
                thumbWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${completed.year}/'
                        '${completed.month.toString().padLeft(2, '0')}/'
                        '${completed.day.toString().padLeft(2, '0')} '
                        '${completed.hour.toString().padLeft(2, '0')}:'
                        '${completed.minute.toString().padLeft(2, '0')}',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '所要時間: $durationText',
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
}
