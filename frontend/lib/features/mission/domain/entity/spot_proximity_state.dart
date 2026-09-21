import 'package:freezed_annotation/freezed_annotation.dart';

part 'spot_proximity_state.freezed.dart';

/// スポットの接近・離脱監視ステータス
enum SpotProximityStatus {
  /// 初期状態（未接近・初期距離計測中）
  initial,

  /// 接近中 (スポットに近づいており、最短距離を更新中)
  approaching,

  /// 離脱中 (最接近点を通過し、遠ざかり始めた。60秒タイマー作動中)
  departing,

  /// 60秒継続離脱により通知発行済み (同スポットでの重複抑止)
  notified,

  /// 写真撮影完了 (監視完了・除外)
  completed,
}

/// カレントスポットの接近・離脱監視状態
@freezed
abstract class SpotProximityState with _$SpotProximityState {
  /// [SpotProximityState] を作成する
  const factory SpotProximityState({
    /// 監視対象のスポットインデックス
    required int spotIndex,

    /// 監視ステータス
    required SpotProximityStatus status,

    /// これまでに記録した最短距離（メートル）
    double? minDistanceMeters,

    /// 直近の距離サンプル（移動平均計算用、最大5件）
    @Default([]) List<double> recentDistances,

    /// 離脱が開始された時刻
    DateTime? departedAt,
  }) = _SpotProximityState;
}
