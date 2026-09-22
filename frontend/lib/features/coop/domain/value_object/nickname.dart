import 'package:flutter/foundation.dart';

/// ルーム作成時と参加時に指定する表示名。空は作れない。
@immutable
class Nickname {
  /// [raw] を trim して [Nickname] にする。
  factory Nickname(String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      throw ArgumentError.value(raw, 'value', 'ニックネームは空にできません');
    }
    return Nickname._(value);
  }

  const Nickname._(this.value);

  /// 表示名。
  final String value;

  @override
  bool operator ==(Object other) => other is Nickname && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Nickname($value)';
}
