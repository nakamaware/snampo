import 'package:flutter_riverpod/experimental/persist.dart';
import 'package:riverpod_annotation/experimental/json_persist.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';

part 'nickname_store.g.dart';

/// アプリに保存するニックネーム (未設定なら null)
@Riverpod(keepAlive: true)
@JsonPersist()
class NicknameStore extends _$NicknameStore {
  @override
  Future<String?> build() async {
    await persist(ref.watch(storageProvider.future)).future;
    return state.value;
  }

  /// ニックネームを保存する。空欄なら自動で命名したものを保存する
  String save(String input) {
    final nickname = Nickname.orAuto(input).value;
    state = AsyncValue.data(nickname);
    return nickname;
  }
}
