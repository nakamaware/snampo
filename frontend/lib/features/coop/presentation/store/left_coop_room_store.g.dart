// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'left_coop_room_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 最後に抜けたルーム (ルームが終わるまで、ホームから入り直せるように保存する)
///
/// 別のルームに入ると消す (`CoopSessionStore.enter`)。

@ProviderFor(LeftCoopRoomStore)
@JsonPersist()
final leftCoopRoomStoreProvider = LeftCoopRoomStoreProvider._();

/// 最後に抜けたルーム (ルームが終わるまで、ホームから入り直せるように保存する)
///
/// 別のルームに入ると消す (`CoopSessionStore.enter`)。
@JsonPersist()
final class LeftCoopRoomStoreProvider
    extends $AsyncNotifierProvider<LeftCoopRoomStore, CoopSession?> {
  /// 最後に抜けたルーム (ルームが終わるまで、ホームから入り直せるように保存する)
  ///
  /// 別のルームに入ると消す (`CoopSessionStore.enter`)。
  LeftCoopRoomStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leftCoopRoomStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leftCoopRoomStoreHash();

  @$internal
  @override
  LeftCoopRoomStore create() => LeftCoopRoomStore();
}

String _$leftCoopRoomStoreHash() => r'8156d7cfac734f1ae823a17461c8cc74e275c6b0';

/// 最後に抜けたルーム (ルームが終わるまで、ホームから入り直せるように保存する)
///
/// 別のルームに入ると消す (`CoopSessionStore.enter`)。

@JsonPersist()
abstract class _$LeftCoopRoomStoreBase extends $AsyncNotifier<CoopSession?> {
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
abstract class _$LeftCoopRoomStore extends _$LeftCoopRoomStoreBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "LeftCoopRoomStore";
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
