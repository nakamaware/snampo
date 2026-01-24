//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class Request {
  /// Returns a new [Request] instance.
  Request({
    required this.currentLat,
    required this.currentLng,
    required this.mode,
    required this.radius,
    required this.destinationLat,
    required this.destinationLng,
  });

  /// 現在地の緯度
  ///
  /// Minimum value: -90.0
  /// Maximum value: 90.0
  Object? currentLat;

  /// 現在地の経度
  ///
  /// Minimum value: -180.0
  /// Maximum value: 180.0
  Object? currentLng;

  /// ルート生成モード
  Object? mode;

  /// 目的地を生成する半径 (メートル単位)
  ///
  /// Maximum value: 40075000
  Object? radius;

  /// 目的地の緯度
  ///
  /// Minimum value: -90.0
  /// Maximum value: 90.0
  Object? destinationLat;

  /// 目的地の経度
  ///
  /// Minimum value: -180.0
  /// Maximum value: 180.0
  Object? destinationLng;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Request &&
    other.currentLat == currentLat &&
    other.currentLng == currentLng &&
    other.mode == mode &&
    other.radius == radius &&
    other.destinationLat == destinationLat &&
    other.destinationLng == destinationLng;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (currentLat == null ? 0 : currentLat!.hashCode) +
    (currentLng == null ? 0 : currentLng!.hashCode) +
    (mode == null ? 0 : mode!.hashCode) +
    (radius == null ? 0 : radius!.hashCode) +
    (destinationLat == null ? 0 : destinationLat!.hashCode) +
    (destinationLng == null ? 0 : destinationLng!.hashCode);

  @override
  String toString() => 'Request[currentLat=$currentLat, currentLng=$currentLng, mode=$mode, radius=$radius, destinationLat=$destinationLat, destinationLng=$destinationLng]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.currentLat != null) {
      json[r'current_lat'] = this.currentLat;
    } else {
      json[r'current_lat'] = null;
    }
    if (this.currentLng != null) {
      json[r'current_lng'] = this.currentLng;
    } else {
      json[r'current_lng'] = null;
    }
    if (this.mode != null) {
      json[r'mode'] = this.mode;
    } else {
      json[r'mode'] = null;
    }
    if (this.radius != null) {
      json[r'radius'] = this.radius;
    } else {
      json[r'radius'] = null;
    }
    if (this.destinationLat != null) {
      json[r'destination_lat'] = this.destinationLat;
    } else {
      json[r'destination_lat'] = null;
    }
    if (this.destinationLng != null) {
      json[r'destination_lng'] = this.destinationLng;
    } else {
      json[r'destination_lng'] = null;
    }
    return json;
  }

  /// Returns a new [Request] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Request? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Request[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Request[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Request(
        currentLat: mapValueOfType<Object>(json, r'current_lat'),
        currentLng: mapValueOfType<Object>(json, r'current_lng'),
        mode: mapValueOfType<Object>(json, r'mode'),
        radius: mapValueOfType<Object>(json, r'radius'),
        destinationLat: mapValueOfType<Object>(json, r'destination_lat'),
        destinationLng: mapValueOfType<Object>(json, r'destination_lng'),
      );
    }
    return null;
  }

  static List<Request> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Request>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Request.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Request> mapFromJson(dynamic json) {
    final map = <String, Request>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Request.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Request-objects as value to a dart map
  static Map<String, List<Request>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Request>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Request.listFromJson(entry.value, growable: growable,);
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
    'destination_lat',
    'destination_lng',
  };
}

