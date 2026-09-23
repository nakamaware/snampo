import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';

/// スポット ID 値オブジェクト
///
/// バックエンドの `/route` が付与する、スポット (中間地点・目的地) の識別子。
/// - ランドマークがあるスポットは Places API の `place_id` ([PlaceSpotId])
/// - 目的地指定モードの目的地は RFC 5870 の geo URI `geo:{lat},{lng}` ([GeoSpotId])
@immutable
sealed class SpotId {
  const SpotId._(this.value);

  /// スポット ID の文字列から読み取る
  ///
  /// 不正な値なら [FormatException] を投げる。
  factory SpotId.parse(String value) {
    if (value.isEmpty) {
      throw const FormatException('スポット ID が空です');
    }
    if (!value.startsWith(_geoPrefix)) {
      return PlaceSpotId._(value);
    }
    final parts = value.substring(_geoPrefix.length).split(',');
    final lat = parts.length == 2 ? double.tryParse(parts[0]) : null;
    final lng = parts.length == 2 ? double.tryParse(parts[1]) : null;
    if (lat == null || lng == null) {
      throw FormatException('geo URI の形式が不正です', value);
    }
    if (lat.abs() > 90 || lng.abs() > 180) {
      throw FormatException('geo URI の座標が範囲外です', value);
    }
    return GeoSpotId._(value, Coordinate(latitude: lat, longitude: lng));
  }

  /// 座標から geo URI のスポット ID を作る (小数 6 桁)
  factory SpotId.fromCoordinate(Coordinate coordinate) {
    final lat = coordinate.latitude.toStringAsFixed(_geoDecimalPlaces);
    final lng = coordinate.longitude.toStringAsFixed(_geoDecimalPlaces);
    return SpotId.parse('$_geoPrefix$lat,$lng');
  }

  /// [pathSegment] で作ったパスの部分から元に戻す
  factory SpotId.fromPathSegment(String segment) => SpotId.parse(
    segment.startsWith(_geoPathPrefix)
        ? segment
            .replaceFirst(_geoPathPrefix, _geoPrefix)
            .replaceFirst(_pathSeparator, ',')
        : segment,
  );

  static const _geoPrefix = 'geo:';
  static const _geoDecimalPlaces = 6;

  // place_id は英数字と `_`、`-` だけでできているため、`~` とは衝突しない
  static const _pathSeparator = '~';
  static const _geoPathPrefix = 'geo$_pathSeparator';

  /// スポット ID の文字列 (Firestore のドキュメント ID にも使う)
  final String value;

  /// Storage のパスやファイル名に使う部分 (`:` と `,` を含まない)
  String get pathSegment => switch (this) {
    PlaceSpotId() => value,
    GeoSpotId() => value
        .replaceFirst(_geoPrefix, _geoPathPrefix)
        .replaceFirst(',', _pathSeparator),
  };

  @override
  bool operator ==(Object other) => other is SpotId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// ランドマークのスポット ID (Places API の place_id)
final class PlaceSpotId extends SpotId {
  const PlaceSpotId._(super.value) : super._();
}

/// 座標のスポット ID (geo URI)
final class GeoSpotId extends SpotId {
  const GeoSpotId._(super.value, this.coordinate) : super._();

  /// スポット ID から戻した座標
  final Coordinate coordinate;
}

/// [SpotId] を JSON (文字列) と相互変換する [JsonConverter]
class SpotIdConverter implements JsonConverter<SpotId, String> {
  /// [SpotIdConverter] を作成する
  const SpotIdConverter();

  @override
  SpotId fromJson(String json) => SpotId.parse(json);

  @override
  String toJson(SpotId object) => object.value;
}
