import 'dart:convert';

import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';

part 'nickname_store.g.dart';

/// アプリに保存するニックネーム (未設定なら null)
@Riverpod(keepAlive: true)
class NicknameStore extends _$NicknameStore {
  @override
  Future<Nickname?> build() async {
    await persist<String, String>(
      ref.watch(storageProvider.future),
      key: 'NicknameStore',
      encode: (nickname) => jsonEncode(nickname?.value),
      decode: (encoded) {
        final value = jsonDecode(encoded) as String?;
        return value == null ? null : Nickname.parse(value);
      },
    ).future;
    return state.value;
  }

  /// ニックネームを保存する。空欄なら自動で命名したものを保存する
  Nickname save(String input) {
    final nickname = Nickname.orAuto(input);
    state = AsyncValue.data(nickname);
    return nickname;
  }
}
