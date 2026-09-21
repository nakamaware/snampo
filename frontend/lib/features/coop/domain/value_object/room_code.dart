import 'package:flutter/foundation.dart';

/// ルームコード。空と内部空白は拒否する。生成規則はここでは決めない。
@immutable
class RoomCode {
  /// [raw] を trim して [RoomCode] にする。
  factory RoomCode(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(raw, 'value', 'ルームコードは空にできません');
    }
    if (value.contains(RegExp(r'\s'))) {
      throw ArgumentError.value(raw, 'value', 'ルームコードに空白を含められません');
    }
    return RoomCode._(value);
  }

  const RoomCode._(this.value);

  /// コード文字列。
  final String value;

  @override
  bool operator ==(Object other) => other is RoomCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RoomCode($value)';
}
