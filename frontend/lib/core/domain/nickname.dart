import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

/// ニックネーム値オブジェクト
@immutable
class Nickname {
  const Nickname._(this.value);

  /// 入力からニックネームを作る。空欄なら自動で命名する (例: 「プレイヤー1234」)
  factory Nickname.orAuto(String input, [Random? random]) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      final number = (random ?? Random()).nextInt(10000);
      return Nickname._('プレイヤー${number.toString().padLeft(4, '0')}');
    }
    final runes = trimmed.runes.toList();
    return Nickname._(
      runes.length <= maxLength
          ? trimmed
          : String.fromCharCodes(runes.take(maxLength)),
    );
  }

  /// 保存済みの値から復元する (前後の空白は除く)
  ///
  /// 空欄や長すぎる値は [FormatException] を投げる (自動で命名はしない)。
  factory Nickname.parse(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.runes.length > maxLength) {
      throw FormatException('不正なニックネーム', value);
    }
    return Nickname._(trimmed);
  }

  /// ニックネームの最大文字数 (Security Rules の上限と揃える)
  static const maxLength = 30;

  /// ニックネームの文字列
  final String value;

  @override
  bool operator ==(Object other) => other is Nickname && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

/// [Nickname] を JSON (文字列) と相互変換する [JsonConverter]
class NicknameConverter implements JsonConverter<Nickname, String> {
  /// [NicknameConverter] を作成する
  const NicknameConverter();

  @override
  Nickname fromJson(String json) => Nickname.parse(json);

  @override
  String toJson(Nickname object) => object.value;
}

/// ルーム内の表示名を uid ごとに返す
///
/// [membersInJoinOrder] は入室順に並べたメンバー。名前が重複した場合は、表示するときだけ
/// 2 人目以降に「たろう(2)」のような番号を付ける (保存するデータは変えない)。
Map<String, String> displayNicknames(
  List<({String uid, String nickname})> membersInJoinOrder,
) {
  final counts = <String, int>{};
  return {
    for (final member in membersInJoinOrder)
      member.uid: () {
        final count = (counts[member.nickname] ?? 0) + 1;
        counts[member.nickname] = count;
        return count == 1 ? member.nickname : '${member.nickname}($count)';
      }(),
  };
}
