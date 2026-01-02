//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.12

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of openapi.api;

class MidPoint {
  /// Returns a new [MidPoint] instance.
  MidPoint({
    required this.latitude,
    required this.longitude,
    this.imageLatitude,
    this.imageLongitude,
    this.imageUtf8,
  });

  num latitude;

  num longitude;

  num? imageLatitude;

  num? imageLongitude;

  String? imageUtf8;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MidPoint &&
    other.latitude == latitude &&
    other.longitude == longitude &&
    other.imageLatitude == imageLatitude &&
    other.imageLongitude == imageLongitude &&
    other.imageUtf8 == imageUtf8;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (latitude.hashCode) +
    (longitude.hashCode) +
    (imageLatitude == null ? 0 : imageLatitude!.hashCode) +
    (imageLongitude == null ? 0 : imageLongitude!.hashCode) +
    (imageUtf8 == null ? 0 : imageUtf8!.hashCode);

  @override
  String toString() => 'MidPoint[latitude=$latitude, longitude=$longitude, imageLatitude=$imageLatitude, imageLongitude=$imageLongitude, imageUtf8=$imageUtf8]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'latitude'] = this.latitude;
      json[r'longitude'] = this.longitude;
    if (this.imageLatitude != null) {
      json[r'image_latitude'] = this.imageLatitude;
    } else {
      json[r'image_latitude'] = null;
    }
    if (this.imageLongitude != null) {
      json[r'image_longitude'] = this.imageLongitude;
    } else {
      json[r'image_longitude'] = null;
    }
    if (this.imageUtf8 != null) {
      json[r'image_utf8'] = this.imageUtf8;
    } else {
      json[r'image_utf8'] = null;
    }
    return json;
  }

  /// Returns a new [MidPoint] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MidPoint? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MidPoint[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MidPoint[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MidPoint(
        latitude: num.parse('${json[r'latitude']}'),
        longitude: num.parse('${json[r'longitude']}'),
        imageLatitude: json[r'image_latitude'] == null
            ? null
            : num.parse('${json[r'image_latitude']}'),
        imageLongitude: json[r'image_longitude'] == null
            ? null
            : num.parse('${json[r'image_longitude']}'),
        imageUtf8: mapValueOfType<String>(json, r'image_utf8'),
      );
    }
    return null;
  }

  static List<MidPoint> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MidPoint>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MidPoint.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MidPoint> mapFromJson(dynamic json) {
    final map = <String, MidPoint>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MidPoint.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MidPoint-objects as value to a dart map
  static Map<String, List<MidPoint>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MidPoint>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MidPoint.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'latitude',
    'longitude',
  };
}

