import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

/// ルームコード値オブジェクト
///
/// 紛らわしい文字 (`0` `O` `1` `I` `L`) を除いた英数字大文字 6 文字。
@immutable
class RoomCode {
  const RoomCode._(this.value);

  /// ランダムなルームコードを生成する
  factory RoomCode.generate([Random? random]) {
    final r = random ?? Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(alphabet[r.nextInt(alphabet.length)]);
    }
    return RoomCode._(buffer.toString());
  }

  /// ルームコードの文字数
  static const length = 6;

  /// ルームコードに使う文字
  static const alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  static const _qrPrefix = 'snampo:room:';

  static final _pattern = RegExp('^[$alphabet]{$length}\$');

  /// 入力 (前後の空白を除き、大文字にしたもの) を検証し、不正なら null を返す
  static RoomCode? tryParse(String input) {
    final normalized = input.trim().toUpperCase();
    if (!_pattern.hasMatch(normalized)) {
      return null;
    }
    return RoomCode._(normalized);
  }

  /// QR に入れる、アプリ内のスキャナ専用の文字列 (`snampo:room:{roomCode}`) から読み取る
  static RoomCode? fromQrPayload(String payload) {
    if (!payload.startsWith(_qrPrefix)) {
      return null;
    }
    final code = payload.substring(_qrPrefix.length);
    return _pattern.hasMatch(code) ? RoomCode._(code) : null;
  }

  /// コードの文字列
  final String value;

  /// QR に入れる文字列
  String toQrPayload() => '$_qrPrefix$value';

  @override
  bool operator ==(Object other) => other is RoomCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// [RoomCode] を JSON (文字列) と相互変換する [JsonConverter]
///
/// 復元時も検証するため、破損した保存データからの不正値は [FormatException] で弾く。
class RoomCodeConverter implements JsonConverter<RoomCode, String> {
  /// [RoomCodeConverter] を作成する
  const RoomCodeConverter();

  @override
  RoomCode fromJson(String json) =>
      RoomCode.tryParse(json) ?? (throw FormatException('不正なルームコード', json));

  @override
  String toJson(RoomCode object) => object.value;
}
