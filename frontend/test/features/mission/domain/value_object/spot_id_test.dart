import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

void main() {
  group('SpotId', () {
    test('place_id はそのままランドマークのスポット ID として読む', () {
      final spotId = SpotId.parse('ChIJC3Cf2PuLGGAROO00ukl8JwA');

      expect(spotId, isA<PlaceSpotId>());
      expect(spotId.value, 'ChIJC3Cf2PuLGGAROO00ukl8JwA');
    });

    test('geo URI は緯度経度に戻せる', () {
      final spotId = SpotId.parse('geo:35.681236,139.767125');

      expect(spotId, isA<GeoSpotId>());
      final coordinate = (spotId as GeoSpotId).coordinate;
      expect(coordinate.latitude, 35.681236);
      expect(coordinate.longitude, 139.767125);
    });

    test('座標から geo URI を小数 6 桁で作る', () {
      final spotId = SpotId.fromCoordinate(
        Coordinate(latitude: 35.6812364999, longitude: -139.5),
      );

      expect(spotId.value, 'geo:35.681236,-139.500000');
    });

    test('Storage のパスに使える文字列にエンコードし、元に戻せる', () {
      final place = SpotId.parse('ChIJ_abc-123');
      final geo = SpotId.parse('geo:35.681236,139.767125');

      expect(place.pathSegment, 'ChIJ_abc-123');
      expect(geo.pathSegment, isNot(contains(':')));
      expect(geo.pathSegment, isNot(contains(',')));
      expect(SpotId.fromPathSegment(geo.pathSegment), geo);
      expect(SpotId.fromPathSegment(place.pathSegment), place);
    });

    test('不正な geo URI や空文字は FormatException', () {
      expect(() => SpotId.parse(''), throwsFormatException);
      expect(() => SpotId.parse('geo:abc,def'), throwsFormatException);
      expect(() => SpotId.parse('geo:95,0'), throwsFormatException);
    });
  });
}
