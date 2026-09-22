import 'dart:math';

import 'package:flutter/foundation.dart';

/// 数字 6 桁のルームコード。QR も同じ数字を載せる。
@immutable
class RoomCode {
  /// [raw] を trim して [RoomCode] にする。
  factory RoomCode(String raw) {
    final value = raw.trim();
    if (!canCreate(raw)) {
      throw ArgumentError.value(raw, 'value', 'ルームコードは数字 6 桁です');
    }
    return RoomCode._(value);
  }

  /// [random] から数字 6 桁を作る。`000000` から `999999` まで。
  factory RoomCode.generate(Random random) {
    final n = random.nextInt(1000000);
    return RoomCode(n.toString().padLeft(6, '0'));
  }

  const RoomCode._(this.value);

  /// trim して数字 6 桁なら作れる。
  static bool canCreate(String raw) => RegExp(r'^\d{6}$').hasMatch(raw.trim());

  /// コード文字列。
  final String value;

  @override
  bool operator ==(Object other) => other is RoomCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'RoomCode($value)';
}
