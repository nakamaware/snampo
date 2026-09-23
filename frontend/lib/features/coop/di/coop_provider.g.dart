// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 協力プレイの認証

@ProviderFor(coopAuthService)
final coopAuthServiceProvider = CoopAuthServiceProvider._();

/// 協力プレイの認証

final class CoopAuthServiceProvider
    extends
        $FunctionalProvider<
          ICoopAuthService,
          ICoopAuthService,
          ICoopAuthService
        >
    with $Provider<ICoopAuthService> {
  /// 協力プレイの認証
  CoopAuthServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coopAuthServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coopAuthServiceHash();

  @$internal
  @override
  $ProviderElement<ICoopAuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ICoopAuthService create(Ref ref) {
    return coopAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICoopAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICoopAuthService>(value),
    );
  }
}

String _$coopAuthServiceHash() => r'8fe2086826e6b9b403d2020957a01f3592b0189d';

/// ルームのリポジトリ (Firebase の初期化後に使う)

@ProviderFor(roomRepository)
final roomRepositoryProvider = RoomRepositoryProvider._();

/// ルームのリポジトリ (Firebase の初期化後に使う)

final class RoomRepositoryProvider
    extends
        $FunctionalProvider<IRoomRepository, IRoomRepository, IRoomRepository>
    with $Provider<IRoomRepository> {
  /// ルームのリポジトリ (Firebase の初期化後に使う)
  RoomRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomRepositoryHash();

  @$internal
  @override
  $ProviderElement<IRoomRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IRoomRepository create(Ref ref) {
    return roomRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IRoomRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IRoomRepository>(value),
    );
  }
}

String _$roomRepositoryHash() => r'1e85f501a20807ea09480fca829fd959420df8cb';

/// 協力プレイの Storage (Firebase の初期化後に使う)

@ProviderFor(coopStorage)
final coopStorageProvider = CoopStorageProvider._();

/// 協力プレイの Storage (Firebase の初期化後に使う)

final class CoopStorageProvider
    extends $FunctionalProvider<ICoopStorage, ICoopStorage, ICoopStorage>
    with $Provider<ICoopStorage> {
  /// 協力プレイの Storage (Firebase の初期化後に使う)
  CoopStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coopStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coopStorageHash();

  @$internal
  @override
  $ProviderElement<ICoopStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ICoopStorage create(Ref ref) {
    return coopStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ICoopStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ICoopStorage>(value),
    );
  }
}

String _$coopStorageHash() => r'9726ed4c61ba66a54d306a732181b1eb33238919';

/// サムネを作るサービス

@ProviderFor(thumbnailService)
final thumbnailServiceProvider = ThumbnailServiceProvider._();

/// サムネを作るサービス

final class ThumbnailServiceProvider
    extends
        $FunctionalProvider<
          IThumbnailService,
          IThumbnailService,
          IThumbnailService
        >
    with $Provider<IThumbnailService> {
  /// サムネを作るサービス
  ThumbnailServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thumbnailServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thumbnailServiceHash();

  @$internal
  @override
  $ProviderElement<IThumbnailService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IThumbnailService create(Ref ref) {
    return thumbnailService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IThumbnailService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IThumbnailService>(value),
    );
  }
}

String _$thumbnailServiceHash() => r'5859cc04befbd2d2a5f0d02a04a1ec649db10e4d';

/// サムネの再送キュー

@ProviderFor(thumbUploadQueueStore)
final thumbUploadQueueStoreProvider = ThumbUploadQueueStoreProvider._();

/// サムネの再送キュー

final class ThumbUploadQueueStoreProvider
    extends
        $FunctionalProvider<
          IThumbUploadQueueStore,
          IThumbUploadQueueStore,
          IThumbUploadQueueStore
        >
    with $Provider<IThumbUploadQueueStore> {
  /// サムネの再送キュー
  ThumbUploadQueueStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'thumbUploadQueueStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$thumbUploadQueueStoreHash();

  @$internal
  @override
  $ProviderElement<IThumbUploadQueueStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IThumbUploadQueueStore create(Ref ref) {
    return thumbUploadQueueStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IThumbUploadQueueStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IThumbUploadQueueStore>(value),
    );
  }
}

String _$thumbUploadQueueStoreHash() =>
    r'447668a849ce46b292a72aefdbe4e4f5e50e1ebd';

/// ルームを作成するユースケース

@ProviderFor(createRoomUseCase)
final createRoomUseCaseProvider = CreateRoomUseCaseProvider._();

/// ルームを作成するユースケース

final class CreateRoomUseCaseProvider
    extends
        $FunctionalProvider<
          CreateRoomUseCase,
          CreateRoomUseCase,
          CreateRoomUseCase
        >
    with $Provider<CreateRoomUseCase> {
  /// ルームを作成するユースケース
  CreateRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateRoomUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateRoomUseCase create(Ref ref) {
    return createRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateRoomUseCase>(value),
    );
  }
}

String _$createRoomUseCaseHash() => r'8557fde257c880e30bf3bb8ddf90d02623592ea6';

/// ルームに入室するユースケース

@ProviderFor(joinRoomUseCase)
final joinRoomUseCaseProvider = JoinRoomUseCaseProvider._();

/// ルームに入室するユースケース

final class JoinRoomUseCaseProvider
    extends
        $FunctionalProvider<JoinRoomUseCase, JoinRoomUseCase, JoinRoomUseCase>
    with $Provider<JoinRoomUseCase> {
  /// ルームに入室するユースケース
  JoinRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'joinRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$joinRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<JoinRoomUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  JoinRoomUseCase create(Ref ref) {
    return joinRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(JoinRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<JoinRoomUseCase>(value),
    );
  }
}

String _$joinRoomUseCaseHash() => r'9006f34c24bf463df81db49108d21c164646a459';

/// ホストがミッションを生成して配るユースケース

@ProviderFor(startCoopMissionUseCase)
final startCoopMissionUseCaseProvider = StartCoopMissionUseCaseProvider._();

/// ホストがミッションを生成して配るユースケース

final class StartCoopMissionUseCaseProvider
    extends
        $FunctionalProvider<
          StartCoopMissionUseCase,
          StartCoopMissionUseCase,
          StartCoopMissionUseCase
        >
    with $Provider<StartCoopMissionUseCase> {
  /// ホストがミッションを生成して配るユースケース
  StartCoopMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startCoopMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startCoopMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<StartCoopMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartCoopMissionUseCase create(Ref ref) {
    return startCoopMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartCoopMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartCoopMissionUseCase>(value),
    );
  }
}

String _$startCoopMissionUseCaseHash() =>
    r'558b1965c12374f3c016a96b8aea1c81b284b66c';

/// スポットをクリアにするユースケース

@ProviderFor(clearSpotUseCase)
final clearSpotUseCaseProvider = ClearSpotUseCaseProvider._();

/// スポットをクリアにするユースケース

final class ClearSpotUseCaseProvider
    extends
        $FunctionalProvider<
          ClearSpotUseCase,
          ClearSpotUseCase,
          ClearSpotUseCase
        >
    with $Provider<ClearSpotUseCase> {
  /// スポットをクリアにするユースケース
  ClearSpotUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearSpotUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearSpotUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearSpotUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClearSpotUseCase create(Ref ref) {
    return clearSpotUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearSpotUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearSpotUseCase>(value),
    );
  }
}

String _$clearSpotUseCaseHash() => r'1b36e2fbc8d17d9ec48c42e2a0d27fc624c188b8';

/// サムネを再送するユースケース (実行中の二重起動を防ぐため keepAlive)

@ProviderFor(retryThumbUploadsUseCase)
final retryThumbUploadsUseCaseProvider = RetryThumbUploadsUseCaseProvider._();

/// サムネを再送するユースケース (実行中の二重起動を防ぐため keepAlive)

final class RetryThumbUploadsUseCaseProvider
    extends
        $FunctionalProvider<
          RetryThumbUploadsUseCase,
          RetryThumbUploadsUseCase,
          RetryThumbUploadsUseCase
        >
    with $Provider<RetryThumbUploadsUseCase> {
  /// サムネを再送するユースケース (実行中の二重起動を防ぐため keepAlive)
  RetryThumbUploadsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'retryThumbUploadsUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$retryThumbUploadsUseCaseHash();

  @$internal
  @override
  $ProviderElement<RetryThumbUploadsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RetryThumbUploadsUseCase create(Ref ref) {
    return retryThumbUploadsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RetryThumbUploadsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RetryThumbUploadsUseCase>(value),
    );
  }
}

String _$retryThumbUploadsUseCaseHash() =>
    r'0188a9bd76fe20de901f9e9983de0b9821f1cd22';

/// `clears` を履歴に反映するユースケース

@ProviderFor(syncCoopClearsUseCase)
final syncCoopClearsUseCaseProvider = SyncCoopClearsUseCaseProvider._();

/// `clears` を履歴に反映するユースケース

final class SyncCoopClearsUseCaseProvider
    extends
        $FunctionalProvider<
          SyncCoopClearsUseCase,
          SyncCoopClearsUseCase,
          SyncCoopClearsUseCase
        >
    with $Provider<SyncCoopClearsUseCase> {
  /// `clears` を履歴に反映するユースケース
  SyncCoopClearsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncCoopClearsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncCoopClearsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncCoopClearsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncCoopClearsUseCase create(Ref ref) {
    return syncCoopClearsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncCoopClearsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncCoopClearsUseCase>(value),
    );
  }
}

String _$syncCoopClearsUseCaseHash() =>
    r'ce0d7b8ef004c376a19d98031dd0175a62e12cab';

/// 未確定の協力プレイ履歴を同期するユースケース

@ProviderFor(syncCoopHistoryUseCase)
final syncCoopHistoryUseCaseProvider = SyncCoopHistoryUseCaseProvider._();

/// 未確定の協力プレイ履歴を同期するユースケース

final class SyncCoopHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          SyncCoopHistoryUseCase,
          SyncCoopHistoryUseCase,
          SyncCoopHistoryUseCase
        >
    with $Provider<SyncCoopHistoryUseCase> {
  /// 未確定の協力プレイ履歴を同期するユースケース
  SyncCoopHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncCoopHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncCoopHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncCoopHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncCoopHistoryUseCase create(Ref ref) {
    return syncCoopHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncCoopHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncCoopHistoryUseCase>(value),
    );
  }
}

String _$syncCoopHistoryUseCaseHash() =>
    r'8c7b5980c103786d342567cc3b389b537dcee94f';
