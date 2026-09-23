import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/domain/value_object/genre_label.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// プレイ全体の結果を表示するページ
///
/// 協力プレイなどのモードは、[ResultPageExtension] で部品を差し込む。
class ResultPage extends ConsumerWidget {
  /// ResultPageのコンストラクタ
  const ResultPage({
    this.kind = MissionSessionKind.solo,
    this.extension,
    super.key,
  });

  /// ミッションと進捗の保存枠
  final MissionSessionKind kind;

  /// モード固有の部品 (ソロでは null)
  final ResultPageExtension? extension;

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
                      if (extension?.buildHeader(context, progress)
                          case final header?) ...[
                        header,
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
                              statusLabel: extension?.spotStatusLabel(
                                checkpoint,
                              ),
                              thumbnailPath:
                                  extension == null
                                      ? checkpoint?.userPhotoPath
                                      : extension!.spotThumbnailPath(
                                        checkpoint,
                                      ),
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
      await extension?.onFinish(ref);
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
    required this.thumbnailPath,
    this.statusLabel,
  });

  final String title;
  final ImageCoordinate point;
  final CheckpointProgress? checkpoint;
  final bool isSelectedDestinationGoal;
  final VoidCallback? onTap;

  /// モード固有の状態 (協力プレイの発見者など)
  final String? statusLabel;

  /// カードに表示する写真のパス (なければ null)
  final String? thumbnailPath;

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
                  child: switch (thumbnailPath) {
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
                    if (statusLabel != null)
                      Text(
                        statusLabel!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.primary,
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

/// 結果画面にモード (協力プレイなど) ごとの部品を差し込むための口
abstract class ResultPageExtension {
  /// [ResultPageExtension] を作成する
  const ResultPageExtension();

  /// スポット一覧の上に表示する部品 (なければ null)
  Widget? buildHeader(BuildContext context, MissionProgressEntity progress) =>
      null;

  /// スポットのカードに表示する状態 (なければ null)
  String? spotStatusLabel(CheckpointProgress? checkpoint) => null;

  /// スポットのカードに表示する写真のパス (既定は自分の写真)
  String? spotThumbnailPath(CheckpointProgress? checkpoint) =>
      checkpoint?.userPhotoPath;

  /// 「ホームへ戻る」で、その種別の枠を片付けたあとに呼ぶ
  Future<void> onFinish(WidgetRef ref) async {}
}
