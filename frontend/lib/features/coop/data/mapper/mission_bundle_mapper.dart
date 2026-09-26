import 'dart:convert';
import 'dart:typed_data';

import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/core/domain/spot_id.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';

/// Storage にアップロードするミッションバンドル
typedef MissionBundle =
    ({
      /// `bundle.json` の中身 (画像は含まない)
      Map<String, dynamic> json,

      /// Storage のパスごとの目標画像 (base64 をデコードした JPEG)
      Map<String, Uint8List> images,
    });

/// [MissionEntity] とミッションバンドル (`bundle.json` とスポット画像) の相互変換
///
/// ```text
/// rooms/{roomCode}/mission/bundle.json            // スポット ID・座標・方角・名前など (画像は含まない)
/// rooms/{roomCode}/mission/images/{spotId}.jpg    // 目標画像
/// ```
class MissionBundleMapper {
  MissionBundleMapper._();

  static const _version = 1;

  /// `bundle.json` の Storage パス
  static String bundlePath(RoomCode code) =>
      'rooms/${code.value}/mission/bundle.json';

  /// 目標画像の Storage パス
  static String imagePath(RoomCode code, SpotId spotId) =>
      'rooms/${code.value}/mission/images/${spotId.pathSegment}.jpg';

  /// [MissionEntity] をバンドルにする
  ///
  /// スポット ID がないスポットがあれば [StateError] を投げる。
  static MissionBundle toBundle(RoomCode code, MissionEntity mission) {
    final images = <String, Uint8List>{};
    final spots = [
      for (final spot in mission.spots)
        () {
          final spotId =
              spot.spotId ?? (throw StateError('スポット ID がないスポットがあります'));
          final path = imagePath(code, spotId);
          images[path] = base64Decode(spot.imageBase64);
          return {
            'spotId': spotId.value,
            'latitude': spot.coordinate.latitude,
            'longitude': spot.coordinate.longitude,
            'referenceHeading': spot.referenceHeading,
            'name': spot.name,
            'genre': spot.genre,
            'googleMapsUrl': spot.googleMapsUrl,
            'streetViewLatitude': spot.streetViewLatitude,
            'streetViewLongitude': spot.streetViewLongitude,
            'imagePath': path,
          };
        }(),
    ];
    return (
      json: {
        'version': _version,
        'departure': {
          'latitude': mission.departure.latitude,
          'longitude': mission.departure.longitude,
        },
        'overviewPolyline': mission.overviewPolyline,
        'radiusMeters': mission.radius?.meters,
        // 並び順は経由地のあとに目的地 (最後の 1 件が目的地)
        'spots': spots,
      },
      images: images,
    );
  }

  /// `bundle.json` の中の画像パスの一覧 (並び順どおり)
  static List<String> imagePaths(Map<String, dynamic> json) => [
    for (final spot in json['spots'] as List<dynamic>)
      (spot as Map<String, dynamic>)['imagePath'] as String,
  ];

  /// バンドルと、画像パスごとの画像から [MissionEntity] を組み直す
  static MissionEntity fromBundle(
    Map<String, dynamic> json,
    Map<String, Uint8List> images,
  ) {
    final spots = [
      for (final raw in json['spots'] as List<dynamic>)
        () {
          final spot = raw as Map<String, dynamic>;
          final path = spot['imagePath'] as String;
          final image = images[path] ?? (throw StateError('画像がありません: $path'));
          return ImageCoordinate(
            coordinate: Coordinate(
              latitude: (spot['latitude'] as num).toDouble(),
              longitude: (spot['longitude'] as num).toDouble(),
            ),
            imageBase64: base64Encode(image),
            referenceHeading: (spot['referenceHeading'] as num?)?.toDouble(),
            name: spot['name'] as String?,
            genre: spot['genre'] as String?,
            googleMapsUrl: spot['googleMapsUrl'] as String?,
            streetViewLatitude:
                (spot['streetViewLatitude'] as num?)?.toDouble(),
            streetViewLongitude:
                (spot['streetViewLongitude'] as num?)?.toDouble(),
            spotId: SpotId.parse(spot['spotId'] as String),
          );
        }(),
    ];
    if (spots.isEmpty) {
      throw StateError('バンドルにスポットがありません');
    }
    final departure = json['departure'] as Map<String, dynamic>;
    final radiusMeters = json['radiusMeters'] as int?;
    return MissionEntity(
      departure: Coordinate(
        latitude: (departure['latitude'] as num).toDouble(),
        longitude: (departure['longitude'] as num).toDouble(),
      ),
      waypoints: spots.sublist(0, spots.length - 1),
      destination: spots.last,
      overviewPolyline: json['overviewPolyline'] as String,
      radius: radiusMeters == null ? null : Radius(meters: radiusMeters),
    );
  }
}
