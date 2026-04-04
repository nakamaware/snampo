import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:snampo/features/mission/application/interface/heading_service.dart';

/// 端末の現在方角を取得するサービス
class HeadingService implements IHeadingService {
  /// HeadingServiceのコンストラクタ
  HeadingService();

  @override
  Future<double?> getCurrentHeading() async {
    final events = FlutterCompass.events;
    if (events == null) {
      return null;
    }

    try {
      final event = await events
          .firstWhere((value) => value.heading != null)
          .timeout(const Duration(seconds: 2));
      final heading = event.heading;
      if (heading == null) {
        return null;
      }
      return _normalizeHeading(heading);
    } on TimeoutException {
      return null;
    } on Object {
      return null;
    }
  }

  double _normalizeHeading(double heading) {
    final normalized = heading % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }
}
