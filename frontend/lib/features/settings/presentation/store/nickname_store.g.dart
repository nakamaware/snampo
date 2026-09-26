// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリに保存するニックネーム (未設定なら null)

@ProviderFor(NicknameStore)
final nicknameStoreProvider = NicknameStoreProvider._();

/// アプリに保存するニックネーム (未設定なら null)
final class NicknameStoreProvider
    extends $AsyncNotifierProvider<NicknameStore, Nickname?> {
  /// アプリに保存するニックネーム (未設定なら null)
  NicknameStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nicknameStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nicknameStoreHash();

  @$internal
  @override
  NicknameStore create() => NicknameStore();
}

String _$nicknameStoreHash() => r'f356be7cacb6cdc0505dad5ac26f205398ecff08';

/// アプリに保存するニックネーム (未設定なら null)

abstract class _$NicknameStore extends $AsyncNotifier<Nickname?> {
  FutureOr<Nickname?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Nickname?>, Nickname?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Nickname?>, Nickname?>,
              AsyncValue<Nickname?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
