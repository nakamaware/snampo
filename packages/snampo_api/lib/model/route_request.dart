//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RouteRequest {
  /// Returns a new [RouteRequest] instance.
  RouteRequest({
    required this.currentLat,
    required this.currentLng,
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

  /// 目的地を生成する半径 (メートル単位)
  ///
  /// Maximum value: 40075000
  int radius;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RouteRequest &&
    other.currentLat == currentLat &&
    other.currentLng == currentLng &&
    other.radius == radius;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentLat.hashCode) +
    (currentLng.hashCode) +
    (radius.hashCode);

  @override
  String toString() => 'RouteRequest[currentLat=$currentLat, currentLng=$currentLng, radius=$radius]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'current_lat'] = this.currentLat;
      json[r'current_lng'] = this.currentLng;
      json[r'radius'] = this.radius;
    return json;
  }

  /// Returns a new [RouteRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RouteRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RouteRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RouteRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RouteRequest(
        currentLat: num.parse('${json[r'current_lat']}'),
        currentLng: num.parse('${json[r'current_lng']}'),
        radius: mapValueOfType<int>(json, r'radius')!,
      );
    }
    return null;
  }

  static List<RouteRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RouteRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RouteRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RouteRequest> mapFromJson(dynamic json) {
    final map = <String, RouteRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RouteRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RouteRequest-objects as value to a dart map
  static Map<String, List<RouteRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RouteRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RouteRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'current_lat',
    'current_lng',
    'radius',
  };
}

