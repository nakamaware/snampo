import 'package:flutter/foundation.dart';

/// Firebase Auth の `uid`。空は作れない。
@immutable
class PlayerId {
  /// [raw] を trim して [PlayerId] にする。
  factory PlayerId(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(raw, 'value', 'uid は空にできません');
    }
    return PlayerId._(value);
  }

  const PlayerId._(this.value);

  /// Auth `uid` 文字列。
  final String value;

  @override
  bool operator ==(Object other) => other is PlayerId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'PlayerId($value)';
}
