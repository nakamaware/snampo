import 'dart:convert';

import 'package:snampo/features/coop/domain/entity/packed_mission_bundle.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/image_coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// Storage の bundle を [MissionEntity] に戻す。
class UnpackMissionBundleUseCase {
  /// [UnpackMissionBundleUseCase] を作成する。
  const UnpackMissionBundleUseCase();

  /// [bundle] の JSON と画像ファイルからミッションを復元する。
  MissionEntity call(PackedMissionBundle bundle) {
    final decoded = jsonDecode(bundle.bundleJson);
    if (decoded is! Map<String, dynamic>) {
      throw ArgumentError.value(
        bundle.bundleJson,
        'bundleJson',
        'bundle.json はオブジェクトです',
      );
    }

    final waypointsJson = decoded['waypoints'];
    if (waypointsJson is! List<dynamic>) {
      throw ArgumentError('waypoints が配列ではありません');
    }

    final destinationJson = decoded['destination'];
    if (destinationJson is! Map) {
      throw ArgumentError('destination がオブジェクトではありません');
    }

    final departureJson = decoded['departure'];
    if (departureJson is! Map<String, dynamic>) {
      throw ArgumentError('departure がオブジェクトではありません');
    }

    final polyline = decoded['overviewPolyline'];
    if (polyline is! String || polyline.isEmpty) {
      throw ArgumentError('overviewPolyline がありません');
    }

    return MissionEntity(
      departure: const CoordinateConverter().fromJson(departureJson),
      waypoints: waypointsJson
          .map((item) => _spotFromJson(item, bundle))
          .toList(growable: false),
      destination: _spotFromJson(destinationJson, bundle),
      overviewPolyline: polyline,
      radius: _radiusFromJson(decoded['radius']),
    );
  }

  ImageCoordinate _spotFromJson(Object? raw, PackedMissionBundle bundle) {
    if (raw is! Map) {
      throw ArgumentError('地点がオブジェクトではありません');
    }
    final json = Map<String, dynamic>.from(raw);
    final imagePath = json['imagePath'];
    if (imagePath is! String || imagePath.isEmpty) {
      throw ArgumentError('imagePath がありません');
    }
    final bytes = bundle.images[imagePath];
    if (bytes == null) {
      throw ArgumentError.value(imagePath, 'imagePath', '画像ファイルがありません');
    }
    if (bytes.isEmpty) {
      throw ArgumentError.value(imagePath, 'image', '画像バイトが空です');
    }

    final coordinateJson = json['coordinate'];
    if (coordinateJson is! Map<String, dynamic>) {
      throw ArgumentError('coordinate がありません');
    }

    return ImageCoordinate(
      coordinate: const CoordinateConverter().fromJson(coordinateJson),
      imageBase64: base64Encode(bytes),
      referenceHeading: (json['referenceHeading'] as num?)?.toDouble(),
      name: json['name'] as String?,
      genre: json['genre'] as String?,
      googleMapsUrl: json['googleMapsUrl'] as String?,
    );
  }

  Radius? _radiusFromJson(Object? raw) {
    if (raw == null) {
      return null;
    }
    if (raw is! Map<String, dynamic>) {
      throw ArgumentError('radius がオブジェクトではありません');
    }
    return const RadiusConverter().fromJson(raw);
  }
}
