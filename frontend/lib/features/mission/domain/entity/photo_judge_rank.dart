/// 写真採点の4段階評価
enum PhotoJudgeRank {
  /// とてもよい
  excellent,

  /// よい
  good,

  /// ふつう
  fair,

  /// 再挑戦
  retry,
}

/// 採点ランクの表示文言
extension PhotoJudgeRankLabel on PhotoJudgeRank {
  /// UI表示用のラベル
  String get label {
    switch (this) {
      case PhotoJudgeRank.excellent:
        return 'Excellent';
      case PhotoJudgeRank.good:
        return 'Good';
      case PhotoJudgeRank.fair:
        return 'Fair';
      case PhotoJudgeRank.retry:
        return 'Retry';
    }
  }
}
