import 'package:flutter/foundation.dart';

/// Firestore `clears/{spotId}` のキー。
///
/// 現行ミッションに地点 ID が無いので、
/// `[...waypoints, destination]` の index を十進文字列にする。
@immutable
class SpotId {
  /// 0 以上の index から作る。
  factory SpotId.fromIndex(int index) {
    if (index < 0) {
      throw ArgumentError.value(index, 'index', 'spot の index は 0 以上です');
    }
    return SpotId._('$index');
  }

  /// 十進文字列だけを受け付ける。先頭ゼロは拒否する。
  factory SpotId.parse(String raw) {
    final value = raw.trim();
    final index = int.tryParse(value);
    if (index == null || index < 0 || '$index' != value) {
      throw ArgumentError.value(raw, 'value', 'spotId は 0 以上の整数文字列です');
    }
    return SpotId._(value);
  }

  const SpotId._(this.value);

  /// Firestore ドキュメント ID。
  final String value;

  /// 進捗リストの index。
  int get index => int.parse(value);

  @override
  bool operator ==(Object other) => other is SpotId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'SpotId($value)';
}
