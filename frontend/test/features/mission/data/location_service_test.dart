import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/data/location_service.dart';

class _FakeGeolocatorPlatform extends GeolocatorPlatform {
  _FakeGeolocatorPlatform(this._result);

  final Future<Position> Function() _result;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) =>
      _result();
}

Position _position() => Position(
  latitude: 35.68,
  longitude: 139.76,
  timestamp: DateTime(2026),
  accuracy: 0,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

void main() {
  late GeolocatorPlatform original;

  setUp(() => original = GeolocatorPlatform.instance);
  tearDown(() => GeolocatorPlatform.instance = original);

  group('LocationService.getCurrentPosition', () {
    test('現在地を座標で返す', () async {
      GeolocatorPlatform.instance = _FakeGeolocatorPlatform(
        () async => _position(),
      );

      final coordinate = await LocationService().getCurrentPosition();

      expect(coordinate.latitude, 35.68);
      expect(coordinate.longitude, 139.76);
    });

    test('位置情報がオフなら LocationUnavailableException を投げる', () async {
      GeolocatorPlatform.instance = _FakeGeolocatorPlatform(
        () => throw const LocationServiceDisabledException(),
      );

      expect(
        LocationService().getCurrentPosition(),
        throwsA(isA<LocationUnavailableException>()),
      );
    });

    test('位置情報の権限がなければ LocationUnavailableException を投げる', () async {
      GeolocatorPlatform.instance = _FakeGeolocatorPlatform(
        () => throw const PermissionDeniedException('denied'),
      );

      expect(
        LocationService().getCurrentPosition(),
        throwsA(isA<LocationUnavailableException>()),
      );
    });
  });
}
