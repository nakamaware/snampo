import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/spot_id.dart';

void main() {
  group('SpotId', () {
    test('place_id はそのままランドマークのスポット ID として読む', () {
      final spotId = SpotId.parse('ChIJC3Cf2PuLGGAROO00ukl8JwA');

      expect(spotId, isA<PlaceSpotId>());
      expect(spotId.value, 'ChIJC3Cf2PuLGGAROO00ukl8JwA');
    });

    test('geo URI は GeoSpotId として読み取る', () {
      final spotId = SpotId.parse('geo:35.681236,139.767125');

      expect(spotId, isA<GeoSpotId>());
    });

    test('Storage のパスに使える文字列にエンコードする', () {
      final place = SpotId.parse('ChIJ_abc-123');
      final geo = SpotId.parse('geo:35.681236,139.767125');

      expect(place.pathSegment, 'ChIJ_abc-123');
      expect(geo.pathSegment, isNot(contains(':')));
      expect(geo.pathSegment, isNot(contains(',')));
    });

    test('不正な geo URI や空文字は FormatException', () {
      expect(() => SpotId.parse(''), throwsFormatException);
      expect(() => SpotId.parse('geo:abc,def'), throwsFormatException);
      expect(() => SpotId.parse('geo:95,0'), throwsFormatException);
    });
  });

  group('SpotIdConverter', () {
    test('JSON の文字列と相互変換できる', () {
      const converter = SpotIdConverter();
      final spotId = SpotId.parse('geo:35.681236,139.767125');

      expect(converter.fromJson(converter.toJson(spotId)), spotId);
    });
  });
}
