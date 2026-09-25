import 'package:flutter/material.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';
import 'package:snampo/features/mission/presentation/component/judge_rank_badge.dart';

/// 判定の区切り (12 / 25 / 50 m) の上に、スポットまでの距離の印を置くバー
///
/// 判定はズームの倍率で割った距離で決まるので、印もその距離に置く。
/// 目盛りより遠ければ右端に置く。
class JudgeDistanceBar extends StatelessWidget {
  /// [JudgeDistanceBar] を作成する
  const JudgeDistanceBar({
    required this.effectiveDistanceMeters,
    required this.rank,
    super.key,
  });

  /// ズームの倍率で割った距離 (m)
  final double effectiveDistanceMeters;

  /// 判定 (その範囲を濃く塗る)
  final PhotoJudgeRank rank;

  /// 目盛りの右端 (m)
  static const scaleMaxMeters = 60.0;

  /// 印のキー (テストで位置を確かめる)
  static const markerKey = ValueKey('judgeDistanceBarMarker');

  static const _barHeight = 22.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    final zones = <(PhotoJudgeRank, double, double)>[];
    var from = 0.0;
    for (final r in PhotoJudgeRank.values) {
      final to = r.distanceLimitMeters ?? scaleMaxMeters;
      zones.add((r, from, to));
      from = to;
    }
    final fraction = (effectiveDistanceMeters / scaleMaxMeters).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return SizedBox(
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  for (final (i, (r, a, b)) in zones.indexed) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(
                      flex: ((b - a) * 10).round(),
                      child: Container(
                        height: _barHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: r == rank ? r.color : r.containerColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          r.label,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10,
                            color: r == rank ? Colors.white : r.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Positioned(
                key: markerKey,
                left: width * fraction - 1.5,
                top: -4,
                child: Container(
                  width: 3,
                  height: _barHeight + 8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              for (final r in PhotoJudgeRank.values)
                if (r.distanceLimitMeters case final limit?)
                  Positioned(
                    left: width * limit / scaleMaxMeters - 20,
                    width: 40,
                    top: _barHeight + 6,
                    child: Text(
                      r == PhotoJudgeRank.fair
                          ? '${limit.round()} m'
                          : '${limit.round()}',
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: muted,
                      ),
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }
}
