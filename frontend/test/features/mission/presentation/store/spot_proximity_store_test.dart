import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/application/interface/notification_service.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/entity/spot_proximity_state.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/spot_proximity_store.dart';

class FakeLocationService implements ILocationService {
  final controller = StreamController<Coordinate>.broadcast();

  @override
  Future<Coordinate> getCurrentPosition() async =>
      Coordinate(latitude: 35.681236, longitude: 139.767125);

  @override
  Stream<Coordinate> getPositionStream({int distanceFilterMeters = 5}) =>
      controller.stream;
}

class FakeNotificationService implements INotificationService {
  int? lastAlertId;
  String? lastTitle;
  String? lastBody;
  int? lastCanceledId;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> showDepartureAlert({
    required int id,
    required String title,
    required String body,
  }) async {
    lastAlertId = id;
    lastTitle = title;
    lastBody = body;
  }

  @override
  Future<void> cancel(int id) async {
    lastCanceledId = id;
    if (lastAlertId == id) {
      lastAlertId = null;
    }
  }
}

class FakeMissionProgressStoreNotifier extends MissionProgressStoreNotifier {
  @override
  Future<MissionProgressEntity?> build() async => null;

  void setProgress(MissionProgressEntity? progress) {
    state = AsyncData(progress);
  }
}

void main() {
  group('SpotProximityStoreNotifier', () {
    late FakeLocationService fakeLocationService;
    late FakeNotificationService fakeNotificationService;
    late ProviderContainer container;

    // Spot 1: (35.6812, 139.7671)
    // 目的地: (35.6850, 139.7671)
    final testMission = MissionEntity(
      departure: Coordinate(latitude: 35.6800, longitude: 139.7671),
      destination: ImageCoordinate(
        coordinate: Coordinate(latitude: 35.6850, longitude: 139.7671),
        imageBase64: '',
        name: '東京駅',
      ),
      overviewPolyline: '',
      waypoints: [
        ImageCoordinate(
          coordinate: Coordinate(latitude: 35.6812, longitude: 139.7671),
          imageBase64: '',
          name: '経由地A',
        ),
      ],
    );

    setUp(() {
      fakeLocationService = FakeLocationService();
      fakeNotificationService = FakeNotificationService();
      container = ProviderContainer(
        overrides: [
          locationServiceProvider.overrideWithValue(fakeLocationService),
          notificationServiceProvider.overrideWithValue(
            fakeNotificationService,
          ),
          missionProgressStoreProvider.overrideWith(
            FakeMissionProgressStoreNotifier.new,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      fakeLocationService.controller.close();
    });

    test('startMonitoring で位置情報を受信し、最接近から離脱して60秒経過で通知イベントが発火する', () {
      fakeAsync((async) {
        final notifier = container.read(spotProximityStoreProvider.notifier);

        SpotDepartureAlertEvent? receivedEvent;
        final sub = notifier.alertEvents.listen((event) {
          receivedEvent = event;
        });

        notifier.startMonitoring(testMission);

        // 1. Spot 1 に向かって接近する (初期位置: 100m手前)
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6803, longitude: 139.7671),
        );
        async.flushMicrotasks();

        final state1 = container.read(spotProximityStoreProvider);
        expect(state1, isNotNull);
        expect(state1!.spotIndex, 0);
        expect(state1.status, SpotProximityStatus.approaching);

        // 2. Spot 1 の至近距離（最接近）を通過
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6812, longitude: 139.7671),
        );
        async.flushMicrotasks();

        final state2 = container.read(spotProximityStoreProvider);
        expect(state2!.status, SpotProximityStatus.approaching);
        expect(state2.minDistanceMeters! < state1.minDistanceMeters!, isTrue);

        // 3. 通過して遠ざかり始める (離脱)
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6825, longitude: 139.7671),
        );
        async.flushMicrotasks();

        final state3 = container.read(spotProximityStoreProvider);
        expect(state3!.status, SpotProximityStatus.departing);
        expect(receivedEvent, isNull);

        // 4. 59秒経過: まだ通知は来ない
        async.elapse(const Duration(seconds: 59));
        expect(receivedEvent, isNull);

        // 5. 60秒経過: アラートイベントが発火！
        async.elapse(const Duration(seconds: 1));
        expect(receivedEvent, isNotNull);
        expect(receivedEvent!.spotIndex, 0);
        expect(receivedEvent!.spotName, contains('Spot 1'));

        // OSローカル通知も発火されていることを検証
        expect(fakeNotificationService.lastAlertId, 0);
        expect(fakeNotificationService.lastTitle, contains('写真の撮り忘れはありませんか？'));
        expect(fakeNotificationService.lastBody, contains('Spot 1'));

        final state4 = container.read(spotProximityStoreProvider);
        expect(state4!.status, SpotProximityStatus.notified);

        sub.cancel();
      });
    });

    test('離脱カウントダウン中に再接近した場合、タイマーが破棄され通知は発火しない', () {
      fakeAsync((async) {
        final notifier = container.read(spotProximityStoreProvider.notifier);

        SpotDepartureAlertEvent? receivedEvent;
        final sub = notifier.alertEvents.listen((event) {
          receivedEvent = event;
        });

        notifier.startMonitoring(testMission);

        // 至近距離
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6812, longitude: 139.7671),
        );
        async.flushMicrotasks();

        // 離脱
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6825, longitude: 139.7671),
        );
        async.flushMicrotasks();

        expect(
          container.read(spotProximityStoreProvider)!.status,
          SpotProximityStatus.departing,
        );

        // 30秒後、引き返して再び近づく
        async.elapse(const Duration(seconds: 30));
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6815, longitude: 139.7671),
        );
        async.flushMicrotasks();

        expect(
          container.read(spotProximityStoreProvider)!.status,
          SpotProximityStatus.approaching,
        );

        // さらに 40秒待っても通知は出ない
        async.elapse(const Duration(seconds: 40));
        expect(receivedEvent, isNull);

        sub.cancel();
      });
    });

    test('離脱カウントダウン中に写真撮影が完了した場合（進捗更新）、タイマーが破棄され60秒経過しても通知は発火しない', () {
      fakeAsync((async) {
        final notifier = container.read(spotProximityStoreProvider.notifier);

        SpotDepartureAlertEvent? receivedEvent;
        final sub = notifier.alertEvents.listen((event) {
          receivedEvent = event;
        });

        notifier.startMonitoring(testMission);

        // 1. 至近距離
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6812, longitude: 139.7671),
        );
        async.flushMicrotasks();

        // 2. 離脱
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6825, longitude: 139.7671),
        );
        async.flushMicrotasks();

        expect(
          container.read(spotProximityStoreProvider)!.status,
          SpotProximityStatus.departing,
        );

        // 3. 30秒後、位置情報イベントがないまま写真撮影完了（進捗更新）
        async.elapse(const Duration(seconds: 30));
        final progressNotifier =
            container.read(missionProgressStoreProvider.notifier)
                as FakeMissionProgressStoreNotifier;

        final completedProgress = MissionProgressEntity(
          startedAt: DateTime.now(),
          checkpoints: [
            const CheckpointProgress(userPhotoPath: '/path/to/photo.jpg'),
          ],
        );
        progressNotifier.setProgress(completedProgress);
        async.flushMicrotasks();

        // 次のスポット（インデックス1: 目的地）へ遷移し、状態が initial にリセットされている
        expect(container.read(spotProximityStoreProvider)!.spotIndex, 1);
        expect(
          container.read(spotProximityStoreProvider)!.status,
          SpotProximityStatus.initial,
        );

        // 4. さらに40秒（合計70秒）待ってもSpot 1の撮り忘れ通知は発火しない
        async.elapse(const Duration(seconds: 40));
        expect(receivedEvent, isNull);
        expect(fakeNotificationService.lastAlertId, isNull);

        sub.cancel();
      });
    });

    test('全スポット完了時に監視が自動停止する', () {
      fakeAsync((async) {
        container
            .read(spotProximityStoreProvider.notifier)
            .startMonitoring(testMission);

        final progressNotifier =
            container.read(missionProgressStoreProvider.notifier)
                as FakeMissionProgressStoreNotifier;

        // Spot 1 & 目的地の両方が完了
        final allCompletedProgress = MissionProgressEntity(
          startedAt: DateTime.now(),
          checkpoints: [
            const CheckpointProgress(userPhotoPath: 'p1.jpg'),
            const CheckpointProgress(userPhotoPath: 'p2.jpg'),
          ],
        );
        progressNotifier.setProgress(allCompletedProgress);
        async.flushMicrotasks();

        // 全スポット完了で監視停止（state が null）
        expect(container.read(spotProximityStoreProvider), isNull);
      });
    });

    test('通知発火後に写真撮影が完了した場合、発火済み通知がキャンセルされる', () {
      fakeAsync((async) {
        container
            .read(spotProximityStoreProvider.notifier)
            .startMonitoring(testMission);

        // 1. 至近距離
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6812, longitude: 139.7671),
        );
        async.flushMicrotasks();

        // 2. 離脱
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6825, longitude: 139.7671),
        );
        async.flushMicrotasks();

        // 3. 60秒経過して通知発火
        async.elapse(const Duration(seconds: 60));
        expect(fakeNotificationService.lastAlertId, 0);

        // 4. 通知発火後に写真撮影が完了（進捗更新）
        final progressNotifier =
            container.read(missionProgressStoreProvider.notifier)
                as FakeMissionProgressStoreNotifier;
        final completedProgress = MissionProgressEntity(
          startedAt: DateTime.now(),
          checkpoints: [
            const CheckpointProgress(userPhotoPath: '/path/to/photo.jpg'),
          ],
        );
        progressNotifier.setProgress(completedProgress);
        async.flushMicrotasks();

        // Spot 0 の通知がキャンセルされていることを検証
        expect(fakeNotificationService.lastCanceledId, 0);
        expect(fakeNotificationService.lastAlertId, isNull);
      });
    });

    test('stopMonitoring でタイマーとストリームが破棄され状態がnullになる', () {
      container
          .read(spotProximityStoreProvider.notifier)
          .startMonitoring(testMission);
      fakeLocationService.controller.add(
        Coordinate(latitude: 35.6803, longitude: 139.7671),
      );

      container.read(spotProximityStoreProvider.notifier).stopMonitoring();
      expect(container.read(spotProximityStoreProvider), isNull);
    });

    test('stopMonitoring 後に再度 startMonitoring しても alertEvents が機能する', () {
      fakeAsync((async) {
        final notifier = container.read(spotProximityStoreProvider.notifier);
        notifier.startMonitoring(testMission);
        notifier.stopMonitoring();

        SpotDepartureAlertEvent? receivedEvent;
        final sub = notifier.alertEvents.listen((event) {
          receivedEvent = event;
        });

        // 2回目の監視開始
        notifier.startMonitoring(testMission);

        // 接近 -> 離脱 -> 60秒
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6812, longitude: 139.7671),
        );
        async.flushMicrotasks();
        fakeLocationService.controller.add(
          Coordinate(latitude: 35.6825, longitude: 139.7671),
        );
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 60));
        expect(receivedEvent, isNotNull);
        expect(receivedEvent?.spotIndex, 0);

        sub.cancel();
      });
    });
  });
}
