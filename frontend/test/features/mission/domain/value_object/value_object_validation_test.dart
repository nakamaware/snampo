import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

void main() {
  group('Coordinate', () {
    test('有効な範囲の値で生成できる', () {
      final value = Coordinate(latitude: 35.681236, longitude: 139.767125);

      expect(value.latitude, 35.681236);
      expect(value.longitude, 139.767125);
    });

    test('境界値で生成できる', () {
      expect(() => Coordinate(latitude: -90, longitude: -180), returnsNormally);
      expect(() => Coordinate(latitude: 90, longitude: 180), returnsNormally);
    });

    test('範囲外の緯度で生成すると ArgumentError', () {
      expect(
        () => Coordinate(latitude: 90.1, longitude: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => Coordinate(latitude: -90.1, longitude: 0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('範囲外の経度で生成すると ArgumentError', () {
      expect(
        () => Coordinate(latitude: 0, longitude: 180.1),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => Coordinate(latitude: 0, longitude: -180.1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('Radius', () {
    test('有効な範囲の値で生成できる', () {
      final value = Radius(meters: 5000);

      expect(value.meters, 5000);
    });

    test('境界値で生成できる', () {
      expect(() => Radius(meters: 500), returnsNormally);
      expect(() => Radius(meters: 10000), returnsNormally);
    });

    test('範囲外の値で生成すると ArgumentError', () {
      expect(() => Radius(meters: 499), throwsA(isA<ArgumentError>()));
      expect(() => Radius(meters: 10001), throwsA(isA<ArgumentError>()));
    });
  });
}
