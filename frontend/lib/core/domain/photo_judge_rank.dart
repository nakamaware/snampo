import 'package:freezed_annotation/freezed_annotation.dart';

/// 写真採点の4段階評価
enum PhotoJudgeRank {
  /// とてもよい
  excellent,

  /// よい
  good,

  /// ふつう
  fair,

  /// 基準外
  miss,
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
      case PhotoJudgeRank.miss:
        return 'Miss';
    }
  }
}

/// 向きのずれの上限 (度)。これを超えてずれると、距離によらず [PhotoJudgeRank.miss]
const photoJudgeHeadingLimitDegrees = 90.0;

/// 判定ごとの距離の上限
extension PhotoJudgeRankLimit on PhotoJudgeRank {
  /// この判定になる距離の上限 (m。ズームの倍率で割ったあとの距離と比べる)
  ///
  /// [PhotoJudgeRank.miss] には上限がないので null。
  double? get distanceLimitMeters => switch (this) {
    PhotoJudgeRank.excellent => 12,
    PhotoJudgeRank.good => 25,
    PhotoJudgeRank.fair => 50,
    PhotoJudgeRank.miss => null,
  };
}

/// ズームを考えに入れた距離 (m)
///
/// N 倍にズームすると被写体が N 倍近く見えるので、実際の距離を倍率で割る。
/// 倍率がない (古いデータ) か 1 倍未満なら、実際の距離のまま。
double effectiveDistanceMeters(double distanceMeters, double? zoomLevel) =>
    distanceMeters / (zoomLevel ?? 1).clamp(1.0, double.infinity);

/// PhotoJudgeRank? の JSON 変換
///
/// 旧バージョンで永続化された未知の値 `retry` は [PhotoJudgeRank.miss] として
/// 復元する (未知の enum 名で `$enumDecodeNullable` が例外を投げるのを防ぐ)。
class PhotoJudgeRankConverter
    implements JsonConverter<PhotoJudgeRank?, String?> {
  /// [PhotoJudgeRankConverter] を作成する
  const PhotoJudgeRankConverter();

  @override
  PhotoJudgeRank? fromJson(String? json) {
    if (json == null) {
      return null;
    }
    if (json == 'retry') {
      return PhotoJudgeRank.miss;
    }
    for (final rank in PhotoJudgeRank.values) {
      if (rank.name == json) {
        return rank;
      }
    }
    return null;
  }

  @override
  String? toJson(PhotoJudgeRank? object) => object?.name;
}
