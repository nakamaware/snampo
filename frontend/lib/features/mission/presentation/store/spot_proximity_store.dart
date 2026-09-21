import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/features/mission/application/usecase/evaluate_spot_proximity_use_case.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/spot_proximity_state.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';

part 'spot_proximity_store.g.dart';

/// スポット離脱通知イベント
class SpotDepartureAlertEvent {
  /// [SpotDepartureAlertEvent] を作成する
  const SpotDepartureAlertEvent({
    required this.spotIndex,
    required this.spotName,
  });

  /// 対象スポットのインデックス
  final int spotIndex;

  /// 対象スポットの表示名 (例: Spot 1, 目的地)
  final String spotName;
}

/// スポット離脱監視と通知制御を行うストア
@Riverpod(keepAlive: true)
class SpotProximityStoreNotifier extends _$SpotProximityStoreNotifier {
  StreamSubscription<Coordinate>? _positionSubscription;
  Timer? _departureTimer;
  MissionEntity? _currentMission;

  /// アプリ内通知をUIに通知するためのStreamController
  final _alertEventController =
      StreamController<SpotDepartureAlertEvent>.broadcast();

  /// 撮り忘れアラートイベントのストリーム
  Stream<SpotDepartureAlertEvent> get alertEvents =>
      _alertEventController.stream;

  @override
  SpotProximityState? build() {
    ref.onDispose(_cleanup);
    return null;
  }

  /// 監視を開始する
  void startMonitoring(MissionEntity mission) {
    _currentMission = mission;
    _positionSubscription?.cancel();
    _departureTimer?.cancel();
    state = null;

    final locationService = ref.read(locationServiceProvider);
    _positionSubscription = locationService
        .getPositionStream()
        .listen(_onPositionUpdate);
  }

  /// 監視を停止する
  void stopMonitoring() {
    _cleanup();
    state = null;
  }

  /// カレントスポット（最初の未撮影地点）のインデックスを特定する
  int? _resolveCurrentTargetIndex(
    MissionProgressEntity? progress,
    int totalCount,
  ) {
    if (progress == null) return 0;
    for (var i = 0; i < totalCount; i++) {
      if (i >= progress.checkpoints.length || progress.checkpoints[i] == null) {
        return i;
      }
    }
    return null; // 全スポット撮影完了
  }

  /// 位置情報更新ハンドラ
  void _onPositionUpdate(Coordinate position) {
    final mission = _currentMission;
    if (mission == null) return;

    final spots = [...mission.waypoints, mission.destination];
    final progress = ref.read(missionProgressStoreProvider).value;
    final targetIndex = _resolveCurrentTargetIndex(progress, spots.length);

    if (targetIndex == null) {
      // 全スポット完了
      stopMonitoring();
      return;
    }

    // 監視対象スポットが切り替わった場合（例: Spot 1完了 -> Spot 2へ）、状態を再初期化
    if (state == null || state!.spotIndex != targetIndex) {
      _departureTimer?.cancel();
      _departureTimer = null;
      state = SpotProximityState(
        spotIndex: targetIndex,
        status: SpotProximityStatus.initial,
      );
    }

    final targetSpot = spots[targetIndex];
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetSpot.coordinate.latitude,
      targetSpot.coordinate.longitude,
    );

    final useCase = ref.read(evaluateSpotProximityUseCaseProvider);
    final isPhotoTaken =
        progress != null &&
        targetIndex < progress.checkpoints.length &&
        progress.checkpoints[targetIndex] != null;

    final result = useCase.call(
      currentDistance: distance,
      currentState: state!,
      isPhotoTaken: isPhotoTaken,
      now: DateTime.now(),
    );

    _applyEvaluationResult(result, targetIndex, spots);
  }

  /// 判定結果を適用し、タイマーや通知を操作する
  void _applyEvaluationResult(
    ProximityEvaluationResult result,
    int targetIndex,
    List<ImageCoordinate> spots,
  ) {
    switch (result.action) {
      case ProximityAction.startTimer:
        _departureTimer?.cancel();
        _departureTimer = Timer(
          Duration(
            seconds:
                ref
                    .read(evaluateSpotProximityUseCaseProvider)
                    .departureDurationSeconds,
          ),
          () => _onTimerExpired(targetIndex, spots),
        );
      case ProximityAction.cancelTimer:
        _departureTimer?.cancel();
        _departureTimer = null;
      case ProximityAction.cancelTimerAndComplete:
        _departureTimer?.cancel();
        _departureTimer = null;
      case ProximityAction.triggerNotification:
        _triggerNotification(targetIndex, spots);
      case ProximityAction.none:
        break;
    }

    state = state?.copyWith(
      status: result.newStatus,
      minDistanceMeters: result.minDistanceMeters,
      recentDistances: result.recentDistances,
      departedAt: result.departedAt ?? state?.departedAt,
    );
  }

  /// 60秒タイマー満了コールバック
  void _onTimerExpired(int targetIndex, List<ImageCoordinate> spots) {
    if (state == null || state!.spotIndex != targetIndex) return;
    if (state!.status != SpotProximityStatus.departing) return;

    _triggerNotification(targetIndex, spots);

    state = state?.copyWith(status: SpotProximityStatus.notified);
  }

  /// 通知を発火する
  void _triggerNotification(int targetIndex, List<ImageCoordinate> spots) {
    final spot = spots[targetIndex];
    final spotName =
        targetIndex < spots.length - 1
            ? (spot.name != null && spot.name!.isNotEmpty
                ? 'Spot ${targetIndex + 1} (${spot.name})'
                : 'Spot ${targetIndex + 1}')
            : (spot.name != null && spot.name!.isNotEmpty
                ? '目的地 (${spot.name})'
                : '目的地');

    _alertEventController.add(
      SpotDepartureAlertEvent(
        spotIndex: targetIndex,
        spotName: spotName,
      ),
    );

    // OSローカルプッシュ通知も発火
    unawaited(
      ref.read(notificationServiceProvider).showDepartureAlert(
        id: targetIndex,
        title: '写真の撮り忘れはありませんか？',
        body: '$spotName から離れています。撮影を忘れていないか確認してください。',
      ),
    );
  }

  void _cleanup() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _departureTimer?.cancel();
    _departureTimer = null;
    _alertEventController.close();
  }
}
