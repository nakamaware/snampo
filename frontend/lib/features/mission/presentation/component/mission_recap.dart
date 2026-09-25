import 'package:flutter/material.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';

/// まとめに並べる 1 スポットの結果
typedef RecapSpot =
    ({
      /// 発見したか (協力プレイでは、誰かが発見したか)
      bool found,

      /// 判定 (未発見や、採点が共有されていない古いクリアでは null)
      PhotoJudgeRank? rank,
    });

/// まとめに並べる協力プレイのメンバー
typedef RecapMember =
    ({
      /// 表示名
      String name,

      /// 見つけた数
      int count,

      /// 自分か
      bool isMe,
    });

/// プレイのまとめ (発見数・時間・判定の内訳・メンバー)
///
/// プレイ結果 (RESULT) と履歴の詳細で同じものを出す。
class MissionRecap extends StatelessWidget {
  /// [MissionRecap] を作成する
  const MissionRecap({
    required this.caption,
    required this.meta,
    required this.spots,
    this.members = const [],
    super.key,
  });

  /// 上の小さな文字 (「RESULT · みんなで」など)
  final String caption;

  /// 発見数の下の文字 (時間や設定)
  final String meta;

  /// スポットごとの結果 (スポットの順)
  final List<RecapSpot> spots;

  /// 協力プレイのメンバー (見つけた数の多い順。ソロでは空)
  final List<RecapMember> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurfaceVariant,
    );
    final found = spots.where((s) => s.found).length;
    final counts = {
      for (final rank in PhotoJudgeRank.values)
        rank: spots.where((s) => s.found && s.rank == rank).length,
    };
    final unjudged = spots.where((s) => s.found && s.rank == null).length;
    final missing = spots.length - found;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          caption,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.3,
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '$found',
                style: theme.textTheme.displaySmall?.copyWith(fontSize: 40),
              ),
              TextSpan(
                text: ' / ${spots.length}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              TextSpan(text: ' スポット発見', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
        Text(meta, style: muted),
        const SizedBox(height: 12),
        _TallyBar(counts: counts, unjudged: unjudged, missing: missing),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 2,
          children: [
            for (final MapEntry(key: rank, value: count) in counts.entries)
              if (count > 0)
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: '● ', style: TextStyle(color: rank.color)),
                      TextSpan(text: '${rank.label} $count'),
                    ],
                  ),
                  style: muted,
                ),
            if (missing > 0) Text('○ 未発見 $missing', style: muted),
          ],
        ),
        if (members.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final m in members) _MemberChip(member: m)],
          ),
        ],
      ],
    );
  }
}

/// 判定の内訳を、スポット 1 つを 1 区切りとして色で並べる
class _TallyBar extends StatelessWidget {
  const _TallyBar({
    required this.counts,
    required this.unjudged,
    required this.missing,
  });

  final Map<PhotoJudgeRank, int> counts;
  final int unjudged;
  final int missing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final segments = <BoxDecoration>[
      for (final MapEntry(key: rank, value: count) in counts.entries)
        for (var i = 0; i < count; i++)
          BoxDecoration(
            color: rank.color,
            borderRadius: BorderRadius.circular(3),
          ),
      for (var i = 0; i < unjudged; i++)
        BoxDecoration(
          color: colorScheme.outline,
          borderRadius: BorderRadius.circular(3),
        ),
      for (var i = 0; i < missing; i++)
        BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          borderRadius: BorderRadius.circular(3),
        ),
    ];
    return SizedBox(
      height: 8,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, decoration) in segments.indexed) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(child: DecoratedBox(decoration: decoration)),
          ],
        ],
      ),
    );
  }
}

class _MemberChip extends StatelessWidget {
  const _MemberChip({required this.member});

  final RecapMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foreground =
        member.isMe ? colorScheme.onPrimaryContainer : colorScheme.onSurface;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            member.isMe
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Text(
          '${member.name}${member.isMe ? ' (あなた)' : ''}  ${member.count}',
          style: theme.textTheme.labelLarge?.copyWith(color: foreground),
        ),
      ),
    );
  }
}
