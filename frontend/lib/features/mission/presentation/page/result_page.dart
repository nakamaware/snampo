import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/presentation/page/midpoint_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// プレイ全体の結果を表示するページ
class ResultPage extends ConsumerWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(persistedMissionProvider);
    final progressAsync = ref.watch(missionProgressStoreProvider);
    final theme = Theme.of(context);

    return missionAsync.when(
      data: (mission) {
        return progressAsync.when(
          data: (progress) {
            if (mission == null || progress == null) {
              return const _ResultErrorScaffold(message: '結果データが見つかりませんでした。');
            }

            final points = [...mission.waypoints, mission.destination];
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  'RESULT',
                  style: (theme.textTheme.displayMedium ??
                          theme.textTheme.headlineMedium ??
                          const TextStyle())
                      .copyWith(color: theme.colorScheme.onPrimary),
                ),
                centerTitle: true,
                backgroundColor: theme.colorScheme.primary,
              ),
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'プレイ結果',
                        style: theme.textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          itemCount: points.length,
                          itemBuilder: (context, index) {
                            final checkpoint =
                                index < progress.checkpoints.length
                                    ? progress.checkpoints[index]
                                    : null;
                            return _ResultCard(
                              title:
                                  index == points.length - 1
                                      ? 'GOAL'
                                      : 'MidPoint ${index + 1}',
                              point: points[index],
                              checkpoint: checkpoint,
                              onTap:
                                  checkpoint == null
                                      ? null
                                      : () => context.push(
                                        '/midpoint-result',
                                        extra: MidPointResultPageArgs(
                                          midPointIndex: index,
                                          totalCheckpointCount: points.length,
                                          missionPoint: points[index],
                                          checkpoint: checkpoint,
                                        ),
                                      ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => _finishPlay(context, ref),
                        child: const Text('ホームへ戻る'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          loading:
              () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
          error: (error, stackTrace) => _ResultErrorScaffold(message: '$error'),
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => _ResultErrorScaffold(message: '$error'),
    );
  }

  Future<void> _finishPlay(BuildContext context, WidgetRef ref) async {
    final progressStore = ref.read(missionProgressStoreProvider.notifier);
    final persistedMission = ref.read(persistedMissionProvider.notifier);

    try {
      await progressStore.clearProgress();
    } finally {
      persistedMission.clearMission();
    }

    if (context.mounted) {
      context.go('/');
    }
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.title,
    required this.point,
    required this.checkpoint,
    required this.onTap,
  });

  final String title;
  final ImageCoordinate point;
  final CheckpointProgress? checkpoint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                height: 88,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      checkpoint?.userPhotoPath == null
                          ? const ColoredBox(
                            color: Colors.black12,
                            child: SizedBox.expand(),
                          )
                          : Image.file(
                            File(checkpoint!.userPhotoPath!),
                            fit: BoxFit.cover,
                          ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(point.name ?? '名称未取得'),
                    Text(point.genre ?? 'ジャンル未取得'),
                    const SizedBox(height: 4),
                    Text('判定: ${checkpoint?.judgeRank?.label ?? '未採点'}'),
                    const SizedBox(height: 8),
                    Text(
                      onTap == null ? '未撮影' : 'タップして結果を見る',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            onTap == null
                                ? theme.colorScheme.outline
                                : theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultErrorScaffold extends StatelessWidget {
  const _ResultErrorScaffold({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RESULT')),
      body: Center(child: Text(message)),
    );
  }
}
