// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_session_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 端末で進行中の協力プレイ (アプリのキルや電波断のあとに「ルームに戻る」ため保存する)

@ProviderFor(CoopSessionStore)
@JsonPersist()
final coopSessionStoreProvider = CoopSessionStoreProvider._();

/// 端末で進行中の協力プレイ (アプリのキルや電波断のあとに「ルームに戻る」ため保存する)
@JsonPersist()
final class CoopSessionStoreProvider
    extends $AsyncNotifierProvider<CoopSessionStore, CoopSession?> {
  /// 端末で進行中の協力プレイ (アプリのキルや電波断のあとに「ルームに戻る」ため保存する)
  CoopSessionStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coopSessionStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coopSessionStoreHash();

  @$internal
  @override
  CoopSessionStore create() => CoopSessionStore();
}

String _$coopSessionStoreHash() => r'd073db5094121b5e5c5e05781e1d0d18808e7e6f';

/// 端末で進行中の協力プレイ (アプリのキルや電波断のあとに「ルームに戻る」ため保存する)

@JsonPersist()
abstract class _$CoopSessionStoreBase extends $AsyncNotifier<CoopSession?> {
  FutureOr<CoopSession?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CoopSession?>, CoopSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CoopSession?>, CoopSession?>,
              AsyncValue<CoopSession?>,
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
abstract class _$CoopSessionStore extends _$CoopSessionStoreBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "CoopSessionStore";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(CoopSession? state)? encode,
    CoopSession? Function(String encoded)? decode,
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
            return e == null
                ? null
                : CoopSession?.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
