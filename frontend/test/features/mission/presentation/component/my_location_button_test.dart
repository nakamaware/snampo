import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/presentation/component/my_location_button.dart';

/// 現在地の取得を、テストから完了させられる位置情報サービス
class _FakeLocationService implements ILocationService {
  Completer<Coordinate> pending = Completer();
  final openedSettings = <LocationUnavailableReason>[];

  @override
  Future<Coordinate> getCurrentPosition() => pending.future;

  @override
  Future<void> openSettings(LocationUnavailableReason reason) async =>
      openedSettings.add(reason);
}

final _here = Coordinate(latitude: 35.68, longitude: 139.76);

Future<_FakeLocationService> _pump(
  WidgetTester tester, {
  required ValueChanged<Coordinate> onLocated,
  Listenable? cancel,
}) async {
  final service = _FakeLocationService();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [locationServiceProvider.overrideWithValue(service)],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: MyLocationButton(onLocated: onLocated, cancel: cancel),
          ),
        ),
      ),
    ),
  );
  return service;
}

void main() {
  group('MyLocationButton', () {
    testWidgets('押すと現在地を取り直し、取れるまではくるくるにする', (tester) async {
      final located = <Coordinate>[];
      final service = await _pump(tester, onLocated: located.add);

      await tester.tap(find.byTooltip('現在地'));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(located, isEmpty);

      service.pending.complete(_here);
      await tester.pump();

      expect(located, [_here]);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byTooltip('現在地'), findsOneWidget);
    });

    testWidgets('取得中に地図に触れたら、取れても寄せない', (tester) async {
      final located = <Coordinate>[];
      final touches = ValueNotifier(0);
      addTearDown(touches.dispose);
      final service = await _pump(
        tester,
        onLocated: located.add,
        cancel: touches,
      );

      await tester.tap(find.byTooltip('現在地'));
      await tester.pump();
      touches.value++;
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);

      service.pending.complete(_here);
      await tester.pump();

      expect(located, isEmpty);
    });

    for (final (reason, message) in const [
      (LocationUnavailableReason.serviceDisabled, '位置情報をオンにしてください'),
      (LocationUnavailableReason.permissionDenied, '位置情報の利用を許可してください'),
    ]) {
      testWidgets('${reason.name} なら「$message」と案内し、合った設定を開く', (tester) async {
        final located = <Coordinate>[];
        final service = await _pump(tester, onLocated: located.add);

        await tester.tap(find.byTooltip('現在地'));
        await tester.pump();
        service.pending.completeError(LocationUnavailableException(reason));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 750));

        expect(find.text(message), findsOneWidget);
        expect(located, isEmpty);
        // 取れなくても、もう一度押せる
        expect(find.byTooltip('現在地'), findsOneWidget);

        await tester.tap(find.text('設定を開く'));
        await tester.pump();

        expect(service.openedSettings, [reason]);
      });
    }
  });
}
