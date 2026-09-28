import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

/// ニックネーム値オブジェクト
@immutable
class Nickname {
  const Nickname._(this.value);

  /// おまかせのニックネームを作る (例: 「プレイヤー1234」)
  factory Nickname.auto([Random? random]) {
    final number = (random ?? Random()).nextInt(10000);
    return Nickname._('プレイヤー${number.toString().padLeft(4, '0')}');
  }

  /// 入力からニックネームを作る。空欄なら自動で命名する (例: 「プレイヤー1234」)
  factory Nickname.orAuto(String input, [Random? random]) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return Nickname.auto(random);
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
/// 名前が重複した場合は、表示するときだけ 2 人目以降に「たろう(2)」のような番号を付ける
/// (保存するデータは変えない)。番号は `namedAt` の順に付ける。基本は入室時刻で、ルーム内で
/// 名前を変えた人はその時刻になる (あとから同じ名前にした人に番号が付く)。
/// [members] は入室順に並べたメンバー。`namedAt` が分からない人がいれば入室順のまま付ける。
Map<String, String> displayNicknames(
  List<({String uid, String nickname, DateTime? namedAt})> members,
) {
  final ordered = [...members];
  if (ordered.every((m) => m.namedAt != null)) {
    // 同じ時刻なら入室順を保つ (List.sort は安定ではないので、元の位置も比べる)
    final index = {for (final (i, m) in members.indexed) m.uid: i};
    ordered.sort((a, b) {
      final byTime = a.namedAt!.compareTo(b.namedAt!);
      return byTime != 0 ? byTime : index[a.uid]!.compareTo(index[b.uid]!);
    });
  }
  final counts = <String, int>{};
  return {
    for (final member in ordered)
      member.uid: () {
        final count = (counts[member.nickname] ?? 0) + 1;
        counts[member.nickname] = count;
        return count == 1 ? member.nickname : '${member.nickname}($count)';
      }(),
  };
}

/// 協力プレイのスポットの発見者の表示
///
/// [displayName] は発見者の表示名 ([displayNicknames] で番号を付けたもの)。
/// 発見者がいなければ「未クリア」。クリア済みなのに発見者が分からない
/// (データが消えた後など) 場合は、取得できなかったと表示する。
String discovererLabel(String? displayName, {bool isCleared = false}) {
  if (displayName != null) {
    return '発見: $displayName';
  }
  return isCleared ? '発見者: 取得できませんでした' : '未クリア';
}
