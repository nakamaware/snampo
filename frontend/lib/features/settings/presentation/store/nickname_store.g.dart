// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nickname_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// アプリに保存するニックネーム (未設定なら null)

@ProviderFor(NicknameStore)
@JsonPersist()
final nicknameStoreProvider = NicknameStoreProvider._();

/// アプリに保存するニックネーム (未設定なら null)
@JsonPersist()
final class NicknameStoreProvider
    extends $AsyncNotifierProvider<NicknameStore, String?> {
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

String _$nicknameStoreHash() => r'd88ecbdb028a3075bf9e00c2f0186f5a9a3e9507';

/// アプリに保存するニックネーム (未設定なら null)

@JsonPersist()
abstract class _$NicknameStoreBase extends $AsyncNotifier<String?> {
  FutureOr<String?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String?>, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String?>, String?>,
              AsyncValue<String?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$NicknameStore extends _$NicknameStoreBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "NicknameStore";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(String? state)? encode,
    String? Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return e == null ? null : e as String;
          },
      options: options,
    );
  }
}
