import 'package:flutter/material.dart';
import 'package:snampo/core/domain/photo_judge_rank.dart';

/// 判定ごとの色 (テーマの緑に合わせた 4 色)
///
/// 協力プレイでは Miss でも発見になるので、Miss は失敗の赤ではなく灰色にする。
extension JudgeRankStyle on PhotoJudgeRank {
  /// 文字や点に使う色
  Color get color => switch (this) {
    PhotoJudgeRank.excellent => const Color(0xFF1E7A31),
    PhotoJudgeRank.good => const Color(0xFF27668F),
    PhotoJudgeRank.fair => const Color(0xFF8F6300),
    PhotoJudgeRank.miss => const Color(0xFF5F655C),
  };

  /// 背景に使う淡い色
  Color get containerColor => switch (this) {
    PhotoJudgeRank.excellent => const Color(0xFFDAF3D3),
    PhotoJudgeRank.good => const Color(0xFFDCEAF4),
    PhotoJudgeRank.fair => const Color(0xFFF7EACB),
    PhotoJudgeRank.miss => const Color(0xFFE6E8E2),
  };
}

/// 判定の札 (色の点と判定の名前)
class JudgeRankBadge extends StatelessWidget {
  /// [JudgeRankBadge] を作成する
  const JudgeRankBadge({required this.rank, this.onPhoto = false, super.key});

  /// 判定
  final PhotoJudgeRank rank;

  /// 写真の上に重ねるか (読みやすいよう背景を白にする)
  final bool onPhoto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onPhoto ? Colors.white : rank.containerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: rank.color,
                shape: BoxShape.circle,
              ),
              child: const SizedBox.square(dimension: 7),
            ),
            const SizedBox(width: 6),
            Text(
              rank.label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: rank.color),
            ),
          ],
        ),
      ),
    );
  }
}
