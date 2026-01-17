import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/models/walk_history.dart';
import 'package:snampo/presentation/controllers/walk_history_controller.dart';

/// 履歴一覧を表示するページ
class HistoryListPage extends ConsumerWidget {
  /// HistoryListPageのコンストラクタ
  const HistoryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titleTextStyle = (theme.textTheme.displayMedium ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(
      color: theme.colorScheme.onPrimary,
    );

    final historiesAsync = ref.watch(walkHistoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '履歴',
          style: titleTextStyle,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: historiesAsync.when(
        data: (histories) {
          if (histories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '履歴がありません',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(walkHistoryControllerProvider.notifier).refresh();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: histories.length,
              itemBuilder: (context, index) {
                final history = histories[index];
                return HistoryCard(history: history);
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                'エラーが発生しました',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(walkHistoryControllerProvider);
                },
                child: const Text('再読み込み'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 履歴カードウィジェット
class HistoryCard extends StatelessWidget {
  /// HistoryCardのコンストラクタ
  const HistoryCard({
    required this.history,
    super.key,
  });

  /// 履歴データ
  final WalkHistory history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateText = _formatDate(history.completedAt);
    final distanceText = history.distanceKilometers >= 1
        ? '${history.distanceKilometers.toStringAsFixed(2)} km'
        : '${history.distanceMeters.toStringAsFixed(0)} m';

    // サムネイル画像を取得 (最初の写真、または目的地のストリートビュー画像)
    Widget? thumbnail;
    if (history.photoPaths.isNotEmpty && history.photoPaths[0] != null) {
      final file = File(history.photoPaths[0]!);
      if (file.existsSync()) {
        thumbnail = Image.file(
          file,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        );
      }
    } else if (history.destination?.imageUtf8 != null) {
      try {
        final imageBytes = base64Decode(history.destination!.imageUtf8!);
        thumbnail = Image.memory(
          imageBytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const SizedBox(),
        );
      } catch (_) {
        // 画像の読み込みに失敗した場合は何も表示しない
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          context.push('/history/${history.id}');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // サムネイル画像
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: thumbnail ??
                      Icon(
                        Icons.route,
                        size: 40,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              const SizedBox(width: 16),
              // 情報
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateText,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.straighten,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          distanceText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 日付をフォーマットする
  String _formatDate(DateTime date) {
    final year = date.year;
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$year年$month月$day日 $hour:$minute';
  }
}
