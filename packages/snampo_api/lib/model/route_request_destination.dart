//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RouteRequestDestination {
  /// Returns a new [RouteRequestDestination] instance.
  RouteRequestDestination({
    required this.currentLat,
    required this.currentLng,
    required this.mode,
    required this.destinationLat,
    required this.destinationLng,
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

  /// 目的地の緯度
  ///
  /// Minimum value: -90.0
  /// Maximum value: 90.0
  num destinationLat;

  /// 目的地の経度
  ///
  /// Minimum value: -180.0
  /// Maximum value: 180.0
  num destinationLng;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RouteRequestDestination &&
    other.currentLat == currentLat &&
    other.currentLng == currentLng &&
    other.mode == mode &&
    other.destinationLat == destinationLat &&
    other.destinationLng == destinationLng;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentLat.hashCode) +
    (currentLng.hashCode) +
    (mode.hashCode) +
    (destinationLat.hashCode) +
    (destinationLng.hashCode);

  @override
  String toString() => 'RouteRequestDestination[currentLat=$currentLat, currentLng=$currentLng, mode=$mode, destinationLat=$destinationLat, destinationLng=$destinationLng]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'current_lat'] = this.currentLat;
      json[r'current_lng'] = this.currentLng;
      json[r'mode'] = this.mode;
      json[r'destination_lat'] = this.destinationLat;
      json[r'destination_lng'] = this.destinationLng;
    return json;
  }

  /// Returns a new [RouteRequestDestination] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RouteRequestDestination? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RouteRequestDestination[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RouteRequestDestination[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RouteRequestDestination(
        currentLat: num.parse('${json[r'current_lat']}'),
        currentLng: num.parse('${json[r'current_lng']}'),
        mode: mapValueOfType<String>(json, r'mode')!,
        destinationLat: num.parse('${json[r'destination_lat']}'),
        destinationLng: num.parse('${json[r'destination_lng']}'),
      );
    }
    return null;
  }

  static List<RouteRequestDestination> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RouteRequestDestination>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RouteRequestDestination.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RouteRequestDestination> mapFromJson(dynamic json) {
    final map = <String, RouteRequestDestination>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RouteRequestDestination.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RouteRequestDestination-objects as value to a dart map
  static Map<String, List<RouteRequestDestination>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RouteRequestDestination>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RouteRequestDestination.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'current_lat',
    'current_lng',
    'mode',
    'destination_lat',
    'destination_lng',
  };
}

