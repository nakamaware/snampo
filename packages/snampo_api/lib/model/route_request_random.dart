//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RouteRequestRandom {
  /// Returns a new [RouteRequestRandom] instance.
  RouteRequestRandom({
    required this.currentLat,
    required this.currentLng,
    required this.mode,
    required this.radius,
  });

  /// 現在地の緯度
  ///
  /// Minimum value: -90.0
  /// Maximum value: 90.0
  num currentLat;

  /// 現在地の経度
  ///
  /// Minimum value: -180.0
  /// Maximum value: 180.0
  num currentLng;

  /// ルート生成モード
  String mode;

  /// 目的地を生成する半径 (メートル単位)
  ///
  /// Maximum value: 40075000
  int radius;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RouteRequestRandom &&
    other.currentLat == currentLat &&
    other.currentLng == currentLng &&
    other.mode == mode &&
    other.radius == radius;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentLat.hashCode) +
    (currentLng.hashCode) +
    (mode.hashCode) +
    (radius.hashCode);

  @override
  String toString() => 'RouteRequestRandom[currentLat=$currentLat, currentLng=$currentLng, mode=$mode, radius=$radius]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'current_lat'] = this.currentLat;
      json[r'current_lng'] = this.currentLng;
      json[r'mode'] = this.mode;
      json[r'radius'] = this.radius;
    return json;
  }

  /// Returns a new [RouteRequestRandom] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RouteRequestRandom? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RouteRequestRandom[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RouteRequestRandom[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RouteRequestRandom(
        currentLat: num.parse('${json[r'current_lat']}'),
        currentLng: num.parse('${json[r'current_lng']}'),
        mode: mapValueOfType<String>(json, r'mode')!,
        radius: mapValueOfType<int>(json, r'radius')!,
      );
    }
    return null;
  }

  static List<RouteRequestRandom> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RouteRequestRandom>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RouteRequestRandom.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RouteRequestRandom> mapFromJson(dynamic json) {
    final map = <String, RouteRequestRandom>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RouteRequestRandom.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RouteRequestRandom-objects as value to a dart map
  static Map<String, List<RouteRequestRandom>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RouteRequestRandom>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RouteRequestRandom.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'current_lat',
    'current_lng',
    'mode',
    'radius',
  };
}

