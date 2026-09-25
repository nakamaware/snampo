import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/features/history/domain/entity/mission_history.dart';
import 'package:snampo/features/history/domain/entity/mission_history_spot.dart';
import 'package:snampo/features/history/domain/entity/mission_settings.dart';
import 'package:snampo/features/history/presentation/util/history_format_util.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/presentation/component/expand_photo_icon.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/component/photo_compare_viewer.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';

/// 1 スポットの結果 (見本と撮った写真、判定、ずれ)
class HistorySpotBlock extends StatelessWidget {
  /// [HistorySpotBlock] を作成する
  const HistorySpotBlock({
    required this.record,
    required this.spot,
    required this.index,
    required this.ownerLabel,
    required this.discovererName,
    super.key,
  });

  /// スポットを含む履歴
  final MissionHistory record;

  /// 出すスポット
  final MissionHistorySpot spot;

  /// スポットの番号 (0 から)
  final int index;

  /// 撮った人の名札 (ソロでは null)
  final String? ownerLabel;

  /// 発見者の表示名
  final String? discovererName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final title = spot.isDestination ? 'GOAL' : 'SPOT ${index + 1}';
    final name = formatHistorySpotTitle(spot: spot, index: index);
    final rank = spot.shownRank;
    final photoPath = spot.shownPhotoPath;
    final judgement = _judgement();
    final reference = FileImage(File(spot.streetViewImagePath));
    final photo = photoPath == null ? null : FileImage(File(photoPath));
    final canOpenResult =
        spot.isCleared &&
        (spot.userPhotoPath != null || spot.discovererUid != null);

    void openViewer() => PhotoCompareViewer.open(
      context,
      title: name,
      caption: '$title · ${formatCompletedDate(record.completedAt)}',
      reference: ComparePhoto(label: '見本', image: reference),
      photo:
          photo == null
              ? null
              : ComparePhoto(
                label: ownerLabel ?? 'あなた',
                image: photo,
                isMine: spot.userPhotoPath != null,
              ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      title,
                      if (record.coop != null && spot.isCleared)
                        if (discovererName case final d?) '発見: $d',
                    ].join(' · '),
                    style: muted,
                  ),
                  Text(name, style: theme.textTheme.titleMedium),
                ],
              ),
            ),
            if (rank != null)
              JudgeRankBadge(rank: rank)
            else if (!spot.isCleared)
              Text('未発見', style: muted),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _Photo(image: reference, label: '見本', onTap: openViewer),
            ),
            const SizedBox(width: 8),
            Expanded(
              child:
                  photo == null
                      // 協力プレイで、発見者のサムネがまだ届いていないこともある
                      ? _MissingPhoto(isCleared: spot.isCleared)
                      : _Photo(
                        image: photo,
                        label: ownerLabel ?? 'あなた',
                        isMine: spot.userPhotoPath != null,
                        onTap: openViewer,
                      ),
            ),
          ],
        ),
        if (canOpenResult)
          Row(
            children: [
              if (judgement case (final distance, final heading))
                Expanded(
                  child: Text(
                    [
                      'スポットまで ${distance.toStringAsFixed(1)} m',
                      if (heading != null)
                        '向き ${formatHeadingErrorText(heading)}',
                    ].join('　'),
                    style: muted,
                  ),
                )
              else
                const Spacer(),
              TextButton(
                onPressed: () => _openSpotResult(context),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Text('くわしく'), Icon(Icons.chevron_right)],
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// 出す距離と向き (自分が撮っていなければ、協力プレイの発見者のもの)
  (double, double?)? _judgement() {
    if (!spot.isCleared) return null;
    if (spot.distanceErrorMeters case final d? when spot.judgeRank != null) {
      return (d, spot.headingErrorDegrees);
    }
    final j = spot.discovererJudgement;
    return j == null ? null : (j.distanceErrorMeters, j.headingErrorDegrees);
  }

  void _openSpotResult(BuildContext context) {
    context.push(
      '/spot-result',
      extra: SpotResultPageArgs(
        spotIndex: index,
        totalCheckpointCount: record.spots.length,
        missionPoint: ImageCoordinate(
          coordinate: spot.coordinate,
          imageBase64: '',
          referenceHeading: spot.referenceHeading,
          name: spot.name,
          genre: spot.genre,
          googleMapsUrl: spot.googleMapsUrl,
        ),
        checkpoint: CheckpointProgress(
          guessPosition: spot.guessPosition,
          userPhotoPath: spot.userPhotoPath,
          capturedHeading: spot.capturedHeading,
          distanceErrorMeters: spot.distanceErrorMeters,
          headingErrorDegrees: spot.headingErrorDegrees,
          judgeRank: spot.judgeRank,
          zoomLevel: spot.zoomLevel,
          achievedAt: spot.achievedAt,
          discovererUid: spot.discovererUid,
          discovererNickname: spot.discovererNickname,
          discovererThumbPath: spot.discovererThumbPath,
          discovererJudgement: spot.discovererJudgement,
        ),
        fromSummary: true,
        isDestinationMode: record.settings is MissionSettingsDestination,
        discovererDisplayName: discovererName,
        referenceImagePath: spot.streetViewImagePath,
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({
    required this.image,
    required this.label,
    required this.onTap,
    this.isMine = false,
  });

  final ImageProvider image;
  final String label;
  final bool isMine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final placeholder = ColoredBox(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: colorScheme.outline,
        ),
      ),
    );
    return Semantics(
      button: true,
      label: '$labelを大きく見る',
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => placeholder,
                ),
                Positioned(
                  left: 6,
                  bottom: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color:
                          isMine
                              ? colorScheme.primary.withValues(alpha: 0.85)
                              : Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 1,
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
                const Positioned(right: 6, bottom: 6, child: ExpandPhotoIcon()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissingPhoto extends StatelessWidget {
  const _MissingPhoto({required this.isCleared});

  /// 発見済みなら、写真がないだけなので「未発見」とは出さない
  final bool isCleared;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isCleared) {
      return AspectRatio(
        aspectRatio: 1,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: theme.colorScheme.outline,
          ),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            '未発見',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
