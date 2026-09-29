import 'dart:math';
import 'package:freezed_annotation/freezed_annotation.dart';

/// ニックネーム値オブジェクト
@immutable
class Nickname {
  const Nickname._(this.value);

  /// おまかせのニックネームを作る (例: 「プレイヤー1234」)
  factory Nickname.auto([Random? random]) {
    final number = (random ?? Random()).nextInt(10000);
    return Nickname._('$_autoPrefix${number.toString().padLeft(4, '0')}');
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

  /// おまかせの名前と同じ書式か
  ///
  /// おまかせかどうかを保存していなかったころの値を読むときだけに使う。自分で「プレイヤー1234」と
  /// 付けた人もおまかせと見なしてしまうので、それ以外では [SavedNickname.isAuto] を使う。
  bool get hasAutoFormat => _autoFormat.hasMatch(value);

  static const _autoPrefix = 'プレイヤー';
  static final _autoFormat = RegExp('^$_autoPrefix\\d{4}\$');

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

/// 端末に保存したニックネーム
@immutable
class SavedNickname {
  /// [SavedNickname] を作成する
  const SavedNickname(this.nickname, {required this.isAuto});

  /// 設定画面などの入力から作る。空欄ならおまかせの名前を作る
  ///
  /// 保存済みのおまかせの名前 ([previous]) をそのまま保存したときは、おまかせのままにする
  /// (設定画面の入力欄には保存済みの名前が入っているため)。
  factory SavedNickname.fromInput(String input, {SavedNickname? previous}) {
    final trimmed = input.trim();
    final keepsAuto =
        previous != null &&
        previous.isAuto &&
        previous.nickname.value == trimmed;
    return SavedNickname(
      Nickname.orAuto(input),
      isAuto: trimmed.isEmpty || keepsAuto,
    );
  }

  /// ニックネーム
  final Nickname nickname;

  /// おまかせで付けた名前か (自分で入力した名前なら false)
  final bool isAuto;

  /// ルームでの自分の名前 ([roomNickname]) が、この端末で付けたおまかせの名前のままか
  bool isAutoIn(String? roomNickname) =>
      isAuto && nickname.value == roomNickname;

  @override
  bool operator ==(Object other) =>
      other is SavedNickname &&
      other.nickname == nickname &&
      other.isAuto == isAuto;

  @override
  int get hashCode => Object.hash(nickname, isAuto);
}

/// 同じ名前の番号付けに使う、メンバー 1 人分の情報
///
/// `namedAt` は名前を付けた時刻 (基本は入室時刻。ルーム内で名前を変えたらその時刻)。
typedef NamedMember = ({String uid, String nickname, DateTime? namedAt});

/// ルーム内の表示名を uid ごとに返す
///
/// 名前が重複した場合は、表示するときだけ 2 人目以降に「たろう(2)」のような番号を付ける
/// (保存するデータは変えない)。番号は `namedAt` の順に付ける。基本は入室時刻で、ルーム内で
/// 名前を変えた人はその時刻になる (あとから同じ名前にした人に番号が付く)。
/// [members] は入室順に並べたメンバー。`namedAt` が分からない人がいれば入室順のまま付ける。
Map<String, String> displayNicknames(List<NamedMember> members) {
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

/// ロビーで [name] に変えようとしている人 ([myUid]) に、同じ名前の人がいることを知らせる文
///
/// 名前を変えた人があとから同じ名前にした人になるので、自分に付く番号を示す。同じ名前の人が
/// いなければ null。
String? duplicateNicknameWarning({
  required String name,
  required String myUid,
  required List<NamedMember> members,
  required DateTime now,
}) {
  if (!members.any((m) => m.uid != myUid && m.nickname == name)) {
    return null;
  }
  final names = displayNicknames([
    for (final m in members)
      m.uid == myUid ? (uid: m.uid, nickname: name, namedAt: now) : m,
  ]);
  return '「$name」さんと同じ名前です。あなたは「${names[myUid] ?? name}」と表示されます';
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
