import 'package:flutter/material.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/heading_dial.dart';
import 'package:snampo/features/mission/presentation/component/judge_distance_bar.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';
import 'package:snampo/features/mission/presentation/util/mission_format_util.dart';

/// スポットまでの距離と、判定の区切りの上の印
///
/// ズームして撮ったときは、倍率で割った距離で判定したことを添える。
class JudgeDistanceSection extends StatelessWidget {
  /// [JudgeDistanceSection] を作成する
  const JudgeDistanceSection({
    required this.distanceErrorMeters,
    required this.zoomLevel,
    required this.rank,
    super.key,
  });

  /// 実際の距離 (m)
  final double distanceErrorMeters;

  /// 撮影したときのズームの倍率 (古いデータでは null)
  final double? zoomLevel;

  /// 判定
  final PhotoJudgeRank rank;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effective = effectiveDistanceMeters(distanceErrorMeters, zoomLevel);
    final zoom = zoomLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'スポットまで',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            Text(
              '${distanceErrorMeters.toStringAsFixed(1)} m',
              style: theme.textTheme.headlineSmall,
            ),
          ],
        ),
        if (zoom != null && zoom > 1)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_formatZoom(zoom)}x ズームなので '
              '${effective.toStringAsFixed(1)} m として判定',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: 10),
        JudgeDistanceBar(effectiveDistanceMeters: effective, rank: rank),
      ],
    );
  }

  static String _formatZoom(double zoom) =>
      zoom == zoom.roundToDouble()
          ? zoom.toStringAsFixed(0)
          : zoom.toStringAsFixed(1);
}

/// 向きのずれ (半円の針と文字)
class JudgeHeadingSection extends StatelessWidget {
  /// [JudgeHeadingSection] を作成する
  const JudgeHeadingSection({
    required this.headingErrorDegrees,
    required this.rank,
    required this.isOthersDiscovery,
    required this.discovererName,
    super.key,
  });

  /// 向きのずれ (度。正なら右、負なら左)
  final double headingErrorDegrees;

  /// 判定 (針の色)
  final PhotoJudgeRank rank;

  /// 他の人が見つけたスポットか (凡例を「〇〇の向き」にする)
  final bool isOthersDiscovery;

  /// 発見者の表示名
  final String? discovererName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final heading = headingErrorDegrees;
    final owner = isOthersDiscovery ? '${discovererName ?? '発見者'}の' : 'あなたの';
    final needleColor =
        heading.abs() > photoJudgeHeadingLimitDegrees
            ? PhotoJudgeRank.miss.color
            : rank.color;
    return Row(
      children: [
        HeadingDial(
          headingErrorDegrees: heading,
          color: rank.color,
          missColor: PhotoJudgeRank.miss.color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('向きのずれ', style: muted),
              Text(
                formatHeadingErrorText(heading),
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text('- - -  見本の向き', style: muted),
              Text('━  $owner向き', style: muted?.copyWith(color: needleColor)),
            ],
          ),
        ),
      ],
    );
  }
}
