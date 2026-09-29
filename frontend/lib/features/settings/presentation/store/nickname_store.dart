import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/di/storage_provider.dart';
import 'package:snampo/core/domain/nickname.dart';

part 'nickname_store.g.dart';

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
    final saved = SavedNickname.fromInput(input, previous: state.value);
    state = AsyncValue.data(saved);
    return saved;
  }
}

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
    final String value => () {
      final nickname = Nickname.parse(value);
      return SavedNickname(nickname, isAuto: nickname.hasAutoFormat);
    }(),
    // 以前は未設定のとき null を保存していた
    _ => SavedNickname(Nickname.auto(), isAuto: true),
  };
}
