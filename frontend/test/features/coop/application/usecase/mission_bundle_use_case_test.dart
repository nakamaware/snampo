import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:snampo/features/coop/application/usecase/pack_mission_bundle_use_case.dart';
import 'package:snampo/features/coop/application/usecase/unpack_mission_bundle_use_case.dart';
import 'package:snampo/features/coop/domain/entity/packed_mission_bundle.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

void main() {
  const pack = PackMissionBundleUseCase();
  const unpack = UnpackMissionBundleUseCase();

  final waypointBytes = Uint8List.fromList([1, 2, 3]);
  final destinationBytes = Uint8List.fromList([4, 5, 6, 7]);

  MissionEntity sampleMission() {
    return MissionEntity(
      departure: Coordinate(latitude: 35, longitude: 139),
      waypoints: [
        ImageCoordinate(
          coordinate: Coordinate(latitude: 35.1, longitude: 139.1),
          imageBase64: base64Encode(waypointBytes),
          name: 'spot',
        ),
      ],
      destination: ImageCoordinate(
        coordinate: Coordinate(latitude: 35.2, longitude: 139.2),
        imageBase64: base64Encode(destinationBytes),
        name: 'goal',
        genre: 'park',
      ),
      overviewPolyline: 'encoded',
      radius: Radius(meters: 500),
    );
  }

  test('pack した JSON に imageBase64 を含めない', () {
    final packed = pack(sampleMission());
    expect(packed.bundleJson.contains('imageBase64'), isFalse);
    expect(packed.images.keys, ['images/0.jpg', 'images/1.jpg']);
    expect(packed.images['images/0.jpg'], waypointBytes);
    expect(packed.images['images/1.jpg'], destinationBytes);
  });

  test('pack と unpack でミッションが戻る', () {
    final original = sampleMission();
    final restored = unpack(pack(original));

    expect(restored.departure, original.departure);
    expect(restored.overviewPolyline, original.overviewPolyline);
    expect(restored.radius, original.radius);
    expect(
      restored.waypoints.single.coordinate,
      original.waypoints.single.coordinate,
    );
    expect(restored.waypoints.single.name, 'spot');
    expect(base64Decode(restored.waypoints.single.imageBase64), waypointBytes);
    expect(restored.destination.name, 'goal');
    expect(restored.destination.genre, 'park');
    expect(base64Decode(restored.destination.imageBase64), destinationBytes);
  });

  test('画像ファイルが無いと ArgumentError', () {
    final packed = pack(sampleMission());
    final missing = PackedMissionBundle(
      bundleJson: packed.bundleJson,
      images: const {},
    );

    expect(() => unpack(missing), throwsA(isA<ArgumentError>()));
  });

  test('壊れた Base64 は pack で ArgumentError', () {
    final broken = MissionEntity(
      departure: Coordinate(latitude: 35, longitude: 139),
      destination: ImageCoordinate(
        coordinate: Coordinate(latitude: 35.2, longitude: 139.2),
        imageBase64: '%%%%',
      ),
      overviewPolyline: 'encoded',
    );

    expect(() => pack(broken), throwsA(isA<ArgumentError>()));
  });
}
