import 'dart:convert';

import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/storage_provider.dart';
import 'package:snampo/core/domain/nickname.dart';

part 'nickname_store.g.dart';

/// アプリに保存したニックネーム
@immutable
class SavedNickname {
  /// [SavedNickname] を作成する
  const SavedNickname(this.nickname, {required this.isAuto});

  /// ニックネーム
  final Nickname nickname;

  /// おまかせで付けた名前か (自分で入力した名前なら false)
  final bool isAuto;

  @override
  bool operator ==(Object other) =>
      other is SavedNickname &&
      other.nickname == nickname &&
      other.isAuto == isAuto;

  @override
  int get hashCode => Object.hash(nickname, isAuto);
}

/// アプリに保存するニックネーム
///
/// 初めて読み込んだときにおまかせの名前を作って保存する (開くたびに変わらないように)。
@Riverpod(keepAlive: true)
class NicknameStore extends _$NicknameStore {
  @override
  Future<SavedNickname> build() async {
    await persist<String, String>(
      ref.watch(storageProvider.future),
      key: 'NicknameStore',
      encode:
          (saved) => jsonEncode({
            'value': saved.nickname.value,
            'isAuto': saved.isAuto,
          }),
      decode: decodeSavedNickname,
    ).future;
    return state.value ?? SavedNickname(Nickname.auto(), isAuto: true);
  }

  /// ニックネームを保存する
  void save(Nickname nickname, {required bool isAuto}) {
    state = AsyncValue.data(SavedNickname(nickname, isAuto: isAuto));
  }

  /// 入力からニックネームを保存する。空欄ならおまかせの名前を作って保存する
  SavedNickname saveInput(String input) {
    final saved = SavedNickname(
      Nickname.orAuto(input),
      isAuto: isAutoInput(input, state.value),
    );
    state = AsyncValue.data(saved);
    return saved;
  }
}

/// 入力から保存する名前が、おまかせの名前かどうか
///
/// 空欄ならおまかせで命名する。保存済みのおまかせの名前をそのまま保存したときも、おまかせのまま
/// にする (設定画面の入力欄には保存済みの名前が入っているため)。
@visibleForTesting
bool isAutoInput(String input, SavedNickname? previous) {
  final trimmed = input.trim();
  return trimmed.isEmpty ||
      (previous != null &&
          previous.isAuto &&
          previous.nickname.value == trimmed);
}

/// 以前の自動命名の形式 (おまかせかを保存していなかったころの値の判定に使う)
final _legacyAutoPattern = RegExp(r'^プレイヤー\d{4}$');

/// 保存した文字列から [SavedNickname] を復元する
@visibleForTesting
SavedNickname decodeSavedNickname(String encoded) {
  final json = jsonDecode(encoded);
  return switch (json) {
    {'value': final String value} => SavedNickname(
      Nickname.parse(value),
      isAuto: json['isAuto'] == true,
    ),
    // 以前は名前の文字列だけを保存していた
    final String value => SavedNickname(
      Nickname.parse(value),
      isAuto: _legacyAutoPattern.hasMatch(value.trim()),
    ),
    // 以前は未設定のとき null を保存していた
    _ => SavedNickname(Nickname.auto(), isAuto: true),
  };
}
