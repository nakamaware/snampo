// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリに保存するニックネーム
///
/// 初めて読み込んだときにおまかせの名前を作って保存する (開くたびに変わらないように)。

@ProviderFor(NicknameStore)
final nicknameStoreProvider = NicknameStoreProvider._();

/// アプリに保存するニックネーム
///
/// 初めて読み込んだときにおまかせの名前を作って保存する (開くたびに変わらないように)。
final class NicknameStoreProvider
    extends $AsyncNotifierProvider<NicknameStore, SavedNickname> {
  /// アプリに保存するニックネーム
  ///
  /// 初めて読み込んだときにおまかせの名前を作って保存する (開くたびに変わらないように)。
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

String _$nicknameStoreHash() => r'648e0e627594a0c7a72ce983ca885dd745d356f8';

/// アプリに保存するニックネーム
///
/// 初めて読み込んだときにおまかせの名前を作って保存する (開くたびに変わらないように)。

abstract class _$NicknameStore extends $AsyncNotifier<SavedNickname> {
  FutureOr<SavedNickname> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SavedNickname>, SavedNickname>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedNickname>, SavedNickname>,
              AsyncValue<SavedNickname>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
