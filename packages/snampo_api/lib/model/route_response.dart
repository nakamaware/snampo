//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class RouteResponse {
  /// Returns a new [RouteResponse] instance.
  RouteResponse({
    required this.departure,
    required this.destination,
    this.midpoints = const [],
    required this.overviewPolyline,
  });

  Point departure;

  Point destination;

  List<Point> midpoints;

  String overviewPolyline;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RouteResponse &&
    other.departure == departure &&
    other.destination == destination &&
    _deepEquality.equals(other.midpoints, midpoints) &&
    other.overviewPolyline == overviewPolyline;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (departure.hashCode) +
    (destination.hashCode) +
    (midpoints.hashCode) +
    (overviewPolyline.hashCode);

  @override
  String toString() => 'RouteResponse[departure=$departure, destination=$destination, midpoints=$midpoints, overviewPolyline=$overviewPolyline]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'departure'] = this.departure;
      json[r'destination'] = this.destination;
      json[r'midpoints'] = this.midpoints;
      json[r'overview_polyline'] = this.overviewPolyline;
    return json;
  }

  /// Returns a new [RouteResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RouteResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RouteResponse[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "RouteResponse[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return RouteResponse(
        departure: Point.fromJson(json[r'departure'])!,
        destination: Point.fromJson(json[r'destination'])!,
        midpoints: Point.listFromJson(json[r'midpoints']),
        overviewPolyline: mapValueOfType<String>(json, r'overview_polyline')!,
      );
    }
    return null;
  }

  static List<RouteResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RouteResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RouteResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RouteResponse> mapFromJson(dynamic json) {
    final map = <String, RouteResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RouteResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RouteResponse-objects as value to a dart map
  static Map<String, List<RouteResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RouteResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RouteResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'departure',
    'destination',
    'midpoints',
    'overview_polyline',
  };
}

