import 'dart:convert';
import 'dart:typed_data';

import 'package:snampo/features/coop/domain/entity/packed_mission_bundle.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// [MissionEntity] から Storage 用 bundle を作る。
class PackMissionBundleUseCase {
  /// [PackMissionBundleUseCase] を作成する。
  const PackMissionBundleUseCase();

  /// 地点順は `[...waypoints, destination]`。画像は `images/{n}.jpg`。
  PackedMissionBundle call(MissionEntity mission) {
    final spots = [...mission.waypoints, mission.destination];
    final images = <String, Uint8List>{};
    final packedSpots = <Map<String, Object?>>[];

    for (var i = 0; i < spots.length; i++) {
      final path = 'images/$i.jpg';
      images[path] = _decodeImage(spots[i].imageBase64, path);
      packedSpots.add(_spotJson(spots[i], path));
    }

    final bundle = <String, Object?>{
      'departure': const CoordinateConverter().toJson(mission.departure),
      'waypoints': packedSpots.sublist(0, packedSpots.length - 1),
      'destination': packedSpots.last,
      'overviewPolyline': mission.overviewPolyline,
      'radius':
          mission.radius == null
              ? null
              : const RadiusConverter().toJson(mission.radius!),
    };

    return PackedMissionBundle(bundleJson: jsonEncode(bundle), images: images);
  }

  Map<String, Object?> _spotJson(ImageCoordinate spot, String imagePath) {
    return <String, Object?>{
      'coordinate': const CoordinateConverter().toJson(spot.coordinate),
      'imagePath': imagePath,
      'referenceHeading': spot.referenceHeading,
      'name': spot.name,
      'genre': spot.genre,
      'googleMapsUrl': spot.googleMapsUrl,
    };
  }

  Uint8List _decodeImage(String imageBase64, String path) {
    try {
      final bytes = Uint8List.fromList(base64Decode(imageBase64));
      if (bytes.isEmpty) {
        throw ArgumentError.value(path, 'image', '画像バイトが空です');
      }
      return bytes;
    } on FormatException catch (error) {
      throw ArgumentError.value(path, 'imageBase64', error.message);
    }
  }
}
