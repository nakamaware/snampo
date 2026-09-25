import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/expand_photo_icon.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/mission_recap.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';

/// プレイ全体の結果を表示するページ
///
/// 上にまとめ (発見数・時間・判定の内訳)、その下にスポットの写真を並べる。
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

  /// モード固有の部品 (ソロでは何もしない既定のもの)
  ResultPageExtension get _extension =>
      extension ?? const _DefaultResultPageExtension();

  /// スポットが多いときは、写真を小さく 3 列に並べる
  static const compactGridThreshold = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(persistedMissionProvider(kind));
    final progressAsync = ref.watch(missionProgressStoreProvider(kind));

    return missionAsync.when(
      data: (mission) {
        return progressAsync.when(
          data: (progress) {
            if (mission == null || progress == null) {
              return const _ResultErrorScaffold(message: '結果データが見つかりませんでした。');
            }
            return _ResultBody(
              mission: mission,
              progress: progress,
              extension: _extension,
              onFinish: () => _finishPlay(context, ref),
              isCoop: kind == MissionSessionKind.coop,
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
      await _extension.onFinish(ref);
    }

    if (context.mounted) {
      context.go('/');
    }
  }
}

class _ResultBody extends StatelessWidget {
  const _ResultBody({
    required this.mission,
    required this.progress,
    required this.extension,
    required this.onFinish,
    required this.isCoop,
  });

  final MissionEntity mission;
  final bool isCoop;
  final MissionProgressEntity progress;
  final ResultPageExtension extension;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final points = mission.spots;
    final isDestinationMode = mission.radius == null;
    CheckpointProgress? checkpointAt(int index) =>
        index < progress.checkpoints.length
            ? progress.checkpoints[index]
            : null;
    final spots = [
      for (var i = 0; i < points.length; i++)
        _spotOf(
          index: i,
          point: points[i],
          checkpoint: checkpointAt(i),
          isSelectedDestinationGoal:
              isDestinationMode && i == points.length - 1,
        ),
    ];

    void openSpot(int index) {
      final spot = spots[index];
      final checkpoint = checkpointAt(index);
      if (spot.found && checkpoint != null) {
        context.push(
          '/spot-result',
          extra: SpotResultPageArgs(
            spotIndex: index,
            totalCheckpointCount: points.length,
            missionPoint: points[index],
            checkpoint: checkpoint,
            fromSummary: true,
            isDestinationMode: isDestinationMode,
            discovererDisplayName: extension.discovererName(checkpoint),
            isCoop: isCoop,
          ),
        );
        return;
      }
      // 未発見のスポットは、見本だけを大きく見られる
      PhotoCompareViewer.open(
        context,
        title: spot.name ?? spot.title,
        caption: '${spot.title} · 未発見',
        reference: ComparePhoto(label: '見本', image: spot.reference),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          children: [
            MissionRecap(
              caption: 'RESULT · ${extension.modeLabel}',
              meta: _meta(),
              spots: [for (final s in spots) (found: s.found, rank: s.rank)],
              members: extension.recapMembers(progress),
            ),
            const SizedBox(height: 22),
            if (spots.length > ResultPage.compactGridThreshold)
              _Grid(
                columns: 3,
                spacing: 8,
                children: [
                  for (final (i, spot) in spots.indexed)
                    _CompactSpotTile(spot: spot, onTap: () => openSpot(i)),
                ],
              )
            else
              _Grid(
                columns: 2,
                spacing: 10,
                runSpacing: 18,
                children: [
                  for (final (i, spot) in spots.indexed)
                    _SpotTile(spot: spot, onTap: () => openSpot(i)),
                ],
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            onPressed: onFinish,
            child: const Text('ホームへ戻る'),
          ),
        ),
      ),
    );
  }

  _ResultSpot _spotOf({
    required int index,
    required ImageCoordinate point,
    required CheckpointProgress? checkpoint,
    required bool isSelectedDestinationGoal,
  }) {
    // 協力プレイで他の人が発見したスポットも、発見者の結果を見られる
    final found =
        checkpoint?.userPhotoPath != null || checkpoint?.discovererUid != null;
    final isGoal = index == mission.spots.length - 1;
    return _ResultSpot(
      title: isGoal ? 'GOAL' : 'SPOT ${index + 1}',
      number: isGoal ? 'G' : '${index + 1}',
      name: point.name ?? (isSelectedDestinationGoal ? '指定したゴール地点' : null),
      found: found,
      // 自分が撮影していなければ、協力プレイの発見者の判定
      rank: checkpoint?.judgeRank ?? checkpoint?.discovererJudgement?.rank,
      ownerLabel: found ? extension.spotOwnerLabel(checkpoint) : null,
      thumbnailPath: extension.spotThumbnailPath(checkpoint),
      reference: _decodeReference(point.imageBase64),
    );
  }

  /// 発見数の下に出す、かかった時間とミッションの設定
  String _meta() {
    final achieved = [
      for (final cp in progress.checkpoints)
        if (cp?.achievedAt case final at?) at,
    ];
    final radius = mission.radius;
    return [
      if (achieved.isNotEmpty)
        formatMissionDuration(
          progress.startedAt,
          achieved.reduce((a, b) => a.isAfter(b) ? a : b),
        ),
      if (radius != null)
        '半径 ${radius.meters} m'
      else
        '目的地指定 · ${mission.destination.name ?? '指定したゴール地点'}',
    ].join(' · ');
  }

  static ImageProvider? _decodeReference(String base64) {
    if (base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } on FormatException {
      return null;
    }
  }
}

/// RESULT に並べる 1 スポット
class _ResultSpot {
  const _ResultSpot({
    required this.title,
    required this.number,
    required this.name,
    required this.found,
    required this.rank,
    required this.ownerLabel,
    required this.thumbnailPath,
    required this.reference,
  });

  /// 「SPOT 1」「GOAL」
  final String title;

  /// 3 列のときに写真に重ねる番号 (「1」「G」)
  final String number;

  final String? name;
  final bool found;
  final PhotoJudgeRank? rank;

  /// 写真を撮った人 (協力プレイだけ。「あなた」か発見者の名前)
  final String? ownerLabel;

  final String? thumbnailPath;
  final ImageProvider? reference;
}

/// [columns] 列に並べる (高さは中身に合わせる)
class _Grid extends StatelessWidget {
  const _Grid({
    required this.columns,
    required this.spacing,
    required this.children,
    this.runSpacing,
  });

  final int columns;
  final double spacing;
  final double? runSpacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

class _SpotTile extends StatelessWidget {
  const _SpotTile({required this.spot, required this.onTap});

  final _ResultSpot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rank = spot.rank;
    final caption = [spot.title, if (spot.ownerLabel case final o?) o];
    if (!spot.found) caption.add('見本');
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (spot.found)
                      _TileImage(path: spot.thumbnailPath)
                    else
                      _MissingSpotImage(reference: spot.reference),
                    if (spot.found && rank != null)
                      Positioned(
                        left: 6,
                        top: 6,
                        child: JudgeRankBadge(rank: rank, onPhoto: true),
                      ),
                    if (!spot.found) ...[
                      const Center(child: _MissingChip()),
                      const Positioned(
                        right: 6,
                        bottom: 6,
                        child: ExpandPhotoIcon(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              caption.join(' · '),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.3,
              ),
            ),
            if (spot.name case final name?)
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: spot.found ? null : theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// スポットが多いときの小さい写真 (番号と判定の点だけ)
class _CompactSpotTile extends StatelessWidget {
  const _CompactSpotTile({required this.spot, required this.onTap});

  final _ResultSpot spot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final rank = spot.rank;
    return Semantics(
      button: true,
      label: '${spot.title}${spot.found ? '' : ' 未発見'}',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (spot.found)
                  _TileImage(path: spot.thumbnailPath)
                else ...[
                  _MissingSpotImage(reference: spot.reference),
                  const Center(child: _MissingChip(compact: true)),
                ],
                Positioned(
                  left: 5,
                  top: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      child: Text(
                        spot.number,
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ),
                  ),
                ),
                if (spot.found && rank != null)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: rank.color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const SizedBox.square(dimension: 12),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    final path = this.path;
    if (path == null) return placeholder;
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// 未発見のスポットの見本 (白黒にして薄くする)
///
/// プレイが終わってからなので、答えの見本を見せてよい。
class _MissingSpotImage extends StatelessWidget {
  const _MissingSpotImage({required this.reference});

  final ImageProvider? reference;

  static const _grayscale = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0, //
  ]);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reference = this.reference;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (reference == null)
          ColoredBox(color: colorScheme.surfaceContainerHigh)
        else
          ColorFiltered(
            colorFilter: _grayscale,
            child: Image(
              image: reference,
              fit: BoxFit.cover,
              errorBuilder:
                  (_, _, _) =>
                      ColoredBox(color: colorScheme.surfaceContainerHigh),
            ),
          ),
        ColoredBox(color: colorScheme.surface.withValues(alpha: 0.6)),
      ],
    );
  }
}

class _MissingChip extends StatelessWidget {
  const _MissingChip({this.compact = false});

  /// 3 列の小さい写真に重ねるか (小さくする)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant, width: 1.5),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 10,
          vertical: compact ? 1 : 3,
        ),
        child: Text(
          '未発見',
          style: (compact
                  ? theme.textTheme.labelSmall
                  : theme.textTheme.labelMedium)
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
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
    return Scaffold(body: Center(child: Text(message)));
  }
}

/// 結果画面にモード (協力プレイなど) ごとの部品を差し込むための口
abstract class ResultPageExtension {
  /// [ResultPageExtension] を作成する
  const ResultPageExtension();

  /// まとめの小見出しに出すモード
  String get modeLabel => 'ひとりで';

  /// まとめに並べるメンバー (見つけた数の多い順。ソロでは空)
  List<RecapMember> recapMembers(MissionProgressEntity progress) => const [];

  /// スポットの写真に付ける、撮った人の名札 (ソロでは null)
  String? spotOwnerLabel(CheckpointProgress? checkpoint) => null;

  /// スポット結果に渡す発見者の表示名 (null なら発見時点のニックネーム)
  String? discovererName(CheckpointProgress? checkpoint) => null;

  /// スポットに表示する写真のパス (既定は自分の写真)
  String? spotThumbnailPath(CheckpointProgress? checkpoint) =>
      checkpoint?.userPhotoPath;

  /// 「ホームへ戻る」で、その種別の枠を片付けたあとに呼ぶ
  Future<void> onFinish(WidgetRef ref) async {}
}

/// ソロの結果画面 (差し込む部品がない) で使う既定の [ResultPageExtension]
class _DefaultResultPageExtension extends ResultPageExtension {
  const _DefaultResultPageExtension();
}
