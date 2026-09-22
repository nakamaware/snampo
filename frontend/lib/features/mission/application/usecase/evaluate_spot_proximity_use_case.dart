import 'package:snampo/features/mission/domain/entity/spot_proximity_state.dart';

/// 評価結果として実行すべきアクション
enum ProximityAction {
  /// アクションなし
  none,

  /// 60秒タイマーを開始する
  startTimer,

  /// タイマーをキャンセル（リセット）する
  cancelTimer,

  /// 離脱通知を発行する
  triggerNotification,

  /// タイマーをキャンセルし、監視を完了する
  cancelTimerAndComplete,
}

/// スポット近接・離脱評価の結果
class ProximityEvaluationResult {
  /// [ProximityEvaluationResult] を作成する
  const ProximityEvaluationResult({
    required this.newStatus,
    required this.action,
    required this.minDistanceMeters,
    required this.recentDistances,
    required this.smoothedDistance,
    this.departedAt,
  });

  /// 遷移後のステータス
  final SpotProximityStatus newStatus;

  /// 実行すべきアクション
  final ProximityAction action;

  /// 最短記録距離（メートル）
  final double? minDistanceMeters;

  /// 更新された直近の距離履歴
  final List<double> recentDistances;

  /// 離脱が検知された日時
  final DateTime? departedAt;

  /// 平滑化された現在距離
  final double smoothedDistance;
}

/// カレントスポットに対する接近・離脱トレンドを評価するユースケース
class EvaluateSpotProximityUseCase {
  /// [EvaluateSpotProximityUseCase] を作成する
  const EvaluateSpotProximityUseCase({
    this.deadbandMeters = 6.0,
    this.departureDurationSeconds = 60,
    this.maxRecentSamples = 5,
  });

  /// GPSノイズ不感帯（メートル）
  final double deadbandMeters;

  /// 離脱継続秒数
  final int departureDurationSeconds;

  /// 移動平均に用いる最大サンプル数
  final int maxRecentSamples;

  /// 接近・離脱の評価を行う
  ProximityEvaluationResult call({
    required double currentDistance,
    required SpotProximityState currentState,
    required bool isPhotoTaken,
    required DateTime now,
  }) {
    // 1. 写真撮影が完了している場合
    if (isPhotoTaken) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.completed,
        action: ProximityAction.cancelTimerAndComplete,
        minDistanceMeters: currentState.minDistanceMeters,
        recentDistances: currentState.recentDistances,
        smoothedDistance: currentDistance,
      );
    }

    // 既に完了または通知済みの場合は状態を維持
    if (currentState.status == SpotProximityStatus.completed) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.completed,
        action: ProximityAction.none,
        minDistanceMeters: currentState.minDistanceMeters,
        recentDistances: currentState.recentDistances,
        smoothedDistance: currentDistance,
      );
    }

    // 2. 移動平均（平滑化距離）の算出
    final updatedRecent = List<double>.from(currentState.recentDistances)
      ..add(currentDistance);
    if (updatedRecent.length > maxRecentSamples) {
      updatedRecent.removeAt(0);
    }
    final smoothedDistance =
        updatedRecent.reduce((a, b) => a + b) / updatedRecent.length;

    final minDistance = currentState.minDistanceMeters;

    // 3. 初回計測時（最短距離が未記録）
    if (minDistance == null) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.approaching,
        action: ProximityAction.none,
        minDistanceMeters: smoothedDistance,
        recentDistances: updatedRecent,
        smoothedDistance: smoothedDistance,
      );
    }

    final prevSmoothedDistance = currentState.recentDistances.isNotEmpty
        ? currentState.recentDistances.reduce((a, b) => a + b) /
              currentState.recentDistances.length
        : currentDistance;

    // 4. 最短距離を更新した場合（接近フェーズ）
    if (smoothedDistance < minDistance) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.approaching,
        // 離脱中から再接近へ転じた場合はタイマーをキャンセル
        action: currentState.status == SpotProximityStatus.departing
            ? ProximityAction.cancelTimer
            : ProximityAction.none,
        minDistanceMeters: smoothedDistance,
        recentDistances: updatedRecent,
        smoothedDistance: smoothedDistance,
      );
    }

    // 4-b. 離脱中に引き返して距離が縮まり始めた場合（再接近による離脱中断）
    if (currentState.status == SpotProximityStatus.departing &&
        smoothedDistance < prevSmoothedDistance) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.approaching,
        action: ProximityAction.cancelTimer,
        minDistanceMeters: minDistance,
        recentDistances: updatedRecent,
        smoothedDistance: smoothedDistance,
      );
    }

    // 既に通知済みの場合は、最短距離を更新しない限り通知済み状態を維持
    if (currentState.status == SpotProximityStatus.notified) {
      return ProximityEvaluationResult(
        newStatus: SpotProximityStatus.notified,
        action: ProximityAction.none,
        minDistanceMeters: minDistance,
        recentDistances: updatedRecent,
        smoothedDistance: smoothedDistance,
      );
    }

    // 5. 最短距離から遠ざかり始めた場合（離脱判定）
    final isMovingAway =
        (smoothedDistance - minDistance) > deadbandMeters &&
        smoothedDistance > prevSmoothedDistance;

    if (isMovingAway) {
      if (currentState.status == SpotProximityStatus.approaching ||
          currentState.status == SpotProximityStatus.initial) {
        // 接近状態から初めてノイズ不感帯を超えて離脱に転じた -> タイマー開始
        return ProximityEvaluationResult(
          newStatus: SpotProximityStatus.departing,
          action: ProximityAction.startTimer,
          minDistanceMeters: minDistance,
          recentDistances: updatedRecent,
          departedAt: now,
          smoothedDistance: smoothedDistance,
        );
      }

      if (currentState.status == SpotProximityStatus.departing) {
        // 既に離脱中。60秒経過したかチェック
        final departedAt = currentState.departedAt ?? now;
        final elapsedSeconds = now.difference(departedAt).inSeconds;

        if (elapsedSeconds >= departureDurationSeconds) {
          // 60秒間離脱が継続 -> 通知発火
          return ProximityEvaluationResult(
            newStatus: SpotProximityStatus.notified,
            action: ProximityAction.triggerNotification,
            minDistanceMeters: minDistance,
            recentDistances: updatedRecent,
            departedAt: departedAt,
            smoothedDistance: smoothedDistance,
          );
        }

        // 離脱中継続（タイマー稼働中）
        return ProximityEvaluationResult(
          newStatus: SpotProximityStatus.departing,
          action: ProximityAction.none,
          minDistanceMeters: minDistance,
          recentDistances: updatedRecent,
          departedAt: departedAt,
          smoothedDistance: smoothedDistance,
        );
      }
    }

    // 6. デッドバンド内の微小な揺らぎ（現状維持）
    return ProximityEvaluationResult(
      newStatus: currentState.status,
      action: ProximityAction.none,
      minDistanceMeters: minDistance,
      recentDistances: updatedRecent,
      departedAt: currentState.departedAt,
      smoothedDistance: smoothedDistance,
    );
  }
}
