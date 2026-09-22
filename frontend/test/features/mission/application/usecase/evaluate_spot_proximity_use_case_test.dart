import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/application/usecase/evaluate_spot_proximity_use_case.dart';
import 'package:snampo/features/mission/domain/entity/spot_proximity_state.dart';

void main() {
  group('EvaluateSpotProximityUseCase', () {
    late EvaluateSpotProximityUseCase useCase;
    final baseTime = DateTime(2026, 9, 21);

    setUp(() {
      useCase = const EvaluateSpotProximityUseCase();
    });

    test('初期状態から接近し、最短距離を更新し続ける', () {
      var state = const SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.initial,
      );

      // 初回: 100m
      var result = useCase.call(
        currentDistance: 100,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime,
      );
      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.none);
      expect(result.minDistanceMeters, 100);

      state = state.copyWith(
        status: result.newStatus,
        minDistanceMeters: result.minDistanceMeters,
        recentDistances: result.recentDistances,
      );

      // 2回目: 80m (接近)
      result = useCase.call(
        currentDistance: 80,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime.add(const Duration(seconds: 5)),
      );
      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.none);
      // 移動平均 (100+80)/2 = 90
      expect(result.minDistanceMeters, 90);

      // さらに接近して 20m
      state = state.copyWith(
        status: result.newStatus,
        minDistanceMeters: 20,
        recentDistances: [20, 20, 20],
      );

      // GPSの微小なブレ（23m、デッドバンド6m以内）では離脱と判定されない
      result = useCase.call(
        currentDistance: 23,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime.add(const Duration(seconds: 10)),
      );
      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.none);
    });

    test('最短距離からデッドバンドを超えて離れた際に離脱中(departing)になりタイマー開始アクションが返る', () {
      const state = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.approaching,
        minDistanceMeters: 20,
        recentDistances: [20, 20, 20, 20, 20],
      );

      // 35mに移動 (移動平均も 20 より 6m 超離れる)
      final departTime = baseTime.add(const Duration(seconds: 10));
      final result = useCase.call(
        currentDistance: 60,
        currentState: state,
        isPhotoTaken: false,
        now: departTime,
      );

      expect(result.newStatus, SpotProximityStatus.departing);
      expect(result.action, ProximityAction.startTimer);
      expect(result.departedAt, departTime);
    });

    test('離脱カウントダウン中に再接近した場合、タイマーキャンセルアクションが返り接近状態へ復帰する', () {
      final departTime = baseTime;
      final state = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.departing,
        minDistanceMeters: 20,
        recentDistances: [28, 28, 28],
        departedAt: departTime,
      );

      // 再び引き返して 10m に最接近
      final result = useCase.call(
        currentDistance: 10,
        currentState: state,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 20)),
      );

      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.cancelTimer);
      // 移動平均は (28*3 + 10)/4 = 23.5 なので、最短距離 20 はまだ維持
      expect(result.minDistanceMeters, 20);

      // さらに近づいて 10m が連続した場合、最短距離も更新される
      final nextState = state.copyWith(
        status: result.newStatus,
        recentDistances: result.recentDistances,
        minDistanceMeters: result.minDistanceMeters,
      );
      final nextResult = useCase.call(
        currentDistance: 10,
        currentState: nextState,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 25)),
      );
      expect(nextResult.newStatus, SpotProximityStatus.approaching);
      // (28*3 + 10 + 10)/5 = 20.8 -> さらに 10m
      final state3 = nextState.copyWith(
        status: nextResult.newStatus,
        recentDistances: nextResult.recentDistances,
        minDistanceMeters: nextResult.minDistanceMeters,
      );
      final result3 = useCase.call(
        currentDistance: 5,
        currentState: state3,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 30)),
      );
      expect(result3.minDistanceMeters! < 20, isTrue);
    });

    test('引き返し中にデッドバンド外であっても距離縮小中ならタイマーが再開されない', () {
      // minDistance: 10m, 離脱して 30m に達した後、引き返して 25m, 20m と接近中
      final departTime = baseTime;
      final departingState = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.departing,
        minDistanceMeters: 10,
        recentDistances: [30, 30, 30, 30, 30],
        departedAt: departTime,
      );

      // 1. 引き返し1回目 (25m) -> approaching に復帰、タイマーキャンセル
      final result1 = useCase.call(
        currentDistance: 25,
        currentState: departingState,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 10)),
      );
      expect(result1.newStatus, SpotProximityStatus.approaching);
      expect(result1.action, ProximityAction.cancelTimer);

      // 2. 引き返し2回目 (20m) -> smoothedDistance は約26m
      // (minDistance 10m から 16m 離れておりデッドバンド6mの外側)
      // だが前回の smoothedDistance より距離が縮小中なので、
      // departing に再遷移せずタイマーも再開しない
      final approachingState = departingState.copyWith(
        status: result1.newStatus,
        recentDistances: result1.recentDistances,
        minDistanceMeters: result1.minDistanceMeters,
      );
      final result2 = useCase.call(
        currentDistance: 20,
        currentState: approachingState,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 15)),
      );
      expect(result2.newStatus, SpotProximityStatus.approaching);
      expect(result2.action, ProximityAction.none);
    });

    test('離脱中に写真が撮影された場合、タイマーキャンセル&完了アクションが返る', () {
      final state = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.departing,
        minDistanceMeters: 20,
        recentDistances: [30, 30],
        departedAt: baseTime,
      );

      final result = useCase.call(
        currentDistance: 30,
        currentState: state,
        isPhotoTaken: true,
        now: baseTime.add(const Duration(seconds: 15)),
      );

      expect(result.newStatus, SpotProximityStatus.completed);
      expect(result.action, ProximityAction.cancelTimerAndComplete);
    });

    test('離脱状態が60秒継続した際に通知発火アクションが返り、notifiedに遷移する', () {
      final departTime = baseTime;
      var state = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.departing,
        minDistanceMeters: 20,
        recentDistances: [30, 30, 30],
        departedAt: departTime,
      );

      // 59秒経過: まだ通知は出ない
      var result = useCase.call(
        currentDistance: 35,
        currentState: state,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 59)),
      );
      expect(result.newStatus, SpotProximityStatus.departing);
      expect(result.action, ProximityAction.none);

      state = state.copyWith(
        recentDistances: result.recentDistances,
        departedAt: result.departedAt,
      );

      // 60秒経過: 通知発火！
      result = useCase.call(
        currentDistance: 36,
        currentState: state,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 60)),
      );
      expect(result.newStatus, SpotProximityStatus.notified);
      expect(result.action, ProximityAction.triggerNotification);

      // 通知後、さらに離れても二重通知は出ない
      state = state.copyWith(status: result.newStatus);
      result = useCase.call(
        currentDistance: 40,
        currentState: state,
        isPhotoTaken: false,
        now: departTime.add(const Duration(seconds: 70)),
      );
      expect(result.newStatus, SpotProximityStatus.notified);
      expect(result.action, ProximityAction.none);
    });

    test('スポットから遠い初期状態から単調に遠ざかる場合、タイマーは開始されず initial が維持される', () {
      var state = const SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.initial,
      );

      // 1. 初回サンプル: スポットから 500m (閾値 100m 外)
      var result = useCase.call(
        currentDistance: 500,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime,
      );
      expect(result.newStatus, SpotProximityStatus.initial);
      expect(result.action, ProximityAction.none);
      expect(result.minDistanceMeters, 500);

      state = state.copyWith(
        status: result.newStatus,
        minDistanceMeters: result.minDistanceMeters,
        recentDistances: result.recentDistances,
      );

      // 2. 単調に遠ざかる: 520m
      result = useCase.call(
        currentDistance: 520,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime.add(const Duration(seconds: 10)),
      );
      expect(result.newStatus, SpotProximityStatus.initial);
      expect(result.action, ProximityAction.none);

      state = state.copyWith(
        status: result.newStatus,
        minDistanceMeters: result.minDistanceMeters,
        recentDistances: result.recentDistances,
      );

      // 3. さらに遠ざかる: 550m (デッドバンド超でも接近履歴がないためタイマーは開始されない)
      result = useCase.call(
        currentDistance: 550,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime.add(const Duration(seconds: 20)),
      );
      expect(result.newStatus, SpotProximityStatus.initial);
      expect(result.action, ProximityAction.none);
    });

    test('スポットから遠い初期状態からスポットに向かって接近した場合、approaching に遷移する', () {
      var state = const SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.initial,
      );

      // 1. 初回サンプル: 500m
      var result = useCase.call(
        currentDistance: 500,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime,
      );
      expect(result.newStatus, SpotProximityStatus.initial);

      state = state.copyWith(
        status: result.newStatus,
        minDistanceMeters: result.minDistanceMeters,
        recentDistances: result.recentDistances,
      );

      // 2. 接近: 450m (距離減少により approaching に遷移)
      result = useCase.call(
        currentDistance: 450,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime.add(const Duration(seconds: 10)),
      );
      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.none);
      expect(result.minDistanceMeters, 475);
    });

    test('最初から接近圏内（150m以内）にいる場合、初回から approaching になる', () {
      const state = SpotProximityState(
        spotIndex: 0,
        status: SpotProximityStatus.initial,
      );

      // 初回サンプル: 50m (デフォルト閾値 150m 以内)
      final result = useCase.call(
        currentDistance: 50,
        currentState: state,
        isPhotoTaken: false,
        now: baseTime,
      );
      expect(result.newStatus, SpotProximityStatus.approaching);
      expect(result.action, ProximityAction.none);
      expect(result.minDistanceMeters, 50);
    });
  });
}
