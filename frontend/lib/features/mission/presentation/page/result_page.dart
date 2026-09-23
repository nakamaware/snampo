import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/presentation/page/coop_result_ranking_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/mission_session_kind.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// プレイ全体の結果を表示するページ
///
/// 協力プレイでは、スポットごとの発見者とサムネ、未クリアのスポット、発見数ランキングも表示する。
class ResultPage extends ConsumerWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({this.kind = MissionSessionKind.solo, super.key});

  /// ミッションと進捗の保存枠
  final MissionSessionKind kind;

  bool get _isCoop => kind == MissionSessionKind.coop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(persistedMissionProvider(kind));
    final progressAsync = ref.watch(missionProgressStoreProvider(kind));
    final theme = Theme.of(context);

    return missionAsync.when(
      data: (mission) {
        return progressAsync.when(
          data: (progress) {
            if (mission == null || progress == null) {
              return const _ResultErrorScaffold(message: '結果データが見つかりませんでした。');
            }

            final points = [...mission.waypoints, mission.destination];
            final isDestinationMode = mission.radius == null;
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
                      if (_isCoop && progress.roomCode != null) ...[
                        CoopResultRanking(
                          roomCode: progress.roomCode!,
                          progress: progress,
                        ),
                        const SizedBox(height: 16),
                      ],
                      Expanded(
                        child: ListView.builder(
                          itemCount: points.length,
                          itemBuilder: (context, index) {
                            final checkpoint =
                                index < progress.checkpoints.length
                                    ? progress.checkpoints[index]
                                    : null;
                            final hasResultPhoto =
                                checkpoint?.userPhotoPath != null;
                            return _ResultCard(
                              title:
                                  index == points.length - 1
                                      ? 'GOAL'
                                      : 'Spot ${index + 1}',
                              point: points[index],
                              checkpoint: checkpoint,
                              isSelectedDestinationGoal:
                                  isDestinationMode &&
                                  index == points.length - 1,
                              isCoop: _isCoop,
                              onTap:
                                  !hasResultPhoto
                                      ? null
                                      : () => context.push(
                                        '/spot-result',
                                        extra: SpotResultPageArgs(
                                          spotIndex: index,
                                          totalCheckpointCount: points.length,
                                          missionPoint: points[index],
                                          checkpoint: checkpoint!,
                                          fromResultPage: true,
                                          isDestinationMode: isDestinationMode,
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
          error: (error, stackTrace) {
            log(
              '進捗データの読み込みに失敗しました',
              error: error,
              stackTrace: stackTrace,
              name: 'ResultPage',
            );
            return const _ResultErrorScaffold(message: '結果データの読み込みに失敗しました。');
          },
        );
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        log(
          'ミッションデータの読み込みに失敗しました',
          error: error,
          stackTrace: stackTrace,
          name: 'ResultPage',
        );
        return const _ResultErrorScaffold(message: '結果データの読み込みに失敗しました。');
      },
    );
  }

  /// 片付ける対象は、その種別の枠だけにする
  Future<void> _finishPlay(BuildContext context, WidgetRef ref) async {
    final progressStore = ref.read(missionProgressStoreProvider(kind).notifier);
    final persistedMission = ref.read(persistedMissionProvider(kind).notifier);

    try {
      // 協力プレイの写真は履歴にコピー済みなので、進捗の写真は消してよい
      await progressStore.clearProgress();
    } finally {
      persistedMission.clearMission();
      if (_isCoop) {
        ref.read(coopSessionStoreProvider.notifier).clear();
      }
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
    required this.isSelectedDestinationGoal,
    required this.onTap,
    this.isCoop = false,
  });

  final String title;
  final ImageCoordinate point;
  final CheckpointProgress? checkpoint;
  final bool isSelectedDestinationGoal;
  final VoidCallback? onTap;
  final bool isCoop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pointNameText =
        point.name ?? (isSelectedDestinationGoal ? '指定したゴール地点' : '取得できませんでした');
    final genreText =
        point.genre?.japaneseLabel ??
        (isSelectedDestinationGoal ? '目的地指定' : '取得できませんでした');

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
                  child: switch (checkpoint?.userPhotoPath ??
                      checkpoint?.discovererThumbPath) {
                    null => const ColoredBox(
                      color: Colors.black12,
                      child: SizedBox.expand(),
                    ),
                    final path => Image.file(File(path), fit: BoxFit.cover),
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    if (isCoop)
                      Text(
                        checkpoint?.discovererNickname == null
                            ? '未クリア'
                            : '発見: ${checkpoint!.discovererNickname}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color:
                              checkpoint?.discovererNickname == null
                                  ? theme.colorScheme.outline
                                  : theme.colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(pointNameText),
                    Text(genreText),
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
