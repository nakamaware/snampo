import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/data/mapper/mission_bundle_mapper.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/domain/value_object/spot_id.dart';

void main() {
  final code = RoomCode.tryParse('ABCD23')!;
  final mission = MissionEntity(
    departure: Coordinate(latitude: 35, longitude: 139),
    waypoints: [
      ImageCoordinate(
        coordinate: Coordinate(latitude: 35.1, longitude: 139.1),
        imageBase64: base64Encode([1, 2, 3]),
        referenceHeading: 90,
        name: '東京駅',
        genre: 'train_station',
        googleMapsUrl: 'https://maps.example/1',
        streetViewLatitude: 35.11,
        streetViewLongitude: 139.11,
        spotId: SpotId.parse('ChIJ_abc'),
      ),
    ],
    destination: ImageCoordinate(
      coordinate: Coordinate(latitude: 35.2, longitude: 139.2),
      imageBase64: base64Encode([4, 5, 6]),
      spotId: SpotId.parse('geo:35.200000,139.200000'),
    ),
    overviewPolyline: 'polyline',
    radius: Radius(meters: 1000),
  );

  test('バンドルには画像を入れず、スポットごとの画像パスを入れる', () {
    final bundle = MissionBundleMapper.toBundle(code, mission);

    final json = jsonEncode(bundle.json);
    expect(json, isNot(contains(mission.destination.imageBase64)));
    expect(bundle.images.keys, [
      'rooms/ABCD23/mission/images/ChIJ_abc.jpg',
      'rooms/ABCD23/mission/images/geo~35.200000~139.200000.jpg',
    ]);
    expect(bundle.images.values.first, [1, 2, 3]);
  });

  test('バンドルと画像から MissionEntity を組み直せる', () {
    final bundle = MissionBundleMapper.toBundle(code, mission);

    final restored = MissionBundleMapper.fromBundle(
      jsonDecode(jsonEncode(bundle.json)) as Map<String, dynamic>,
      bundle.images,
    );

    expect(restored, mission);
  });

  test('画像パスの一覧を返す', () {
    final bundle = MissionBundleMapper.toBundle(code, mission);

    expect(
      MissionBundleMapper.imagePaths(bundle.json),
      bundle.images.keys.toList(),
    );
  });

  test('スポット ID がないミッションはバンドルにできない', () {
    expect(
      () => MissionBundleMapper.toBundle(
        code,
        mission.copyWith(
          destination: mission.destination.copyWith(spotId: null),
        ),
      ),
      throwsStateError,
    );
  });
}
