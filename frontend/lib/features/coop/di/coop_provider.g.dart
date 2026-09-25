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

/// 協力プレイのサインインを済ませるユースケース

@ProviderFor(ensureCoopSignInUseCase)
final ensureCoopSignInUseCaseProvider = EnsureCoopSignInUseCaseProvider._();

/// 協力プレイのサインインを済ませるユースケース

final class EnsureCoopSignInUseCaseProvider
    extends
        $FunctionalProvider<
          EnsureCoopSignInUseCase,
          EnsureCoopSignInUseCase,
          EnsureCoopSignInUseCase
        >
    with $Provider<EnsureCoopSignInUseCase> {
  /// 協力プレイのサインインを済ませるユースケース
  EnsureCoopSignInUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ensureCoopSignInUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ensureCoopSignInUseCaseHash();

  @$internal
  @override
  $ProviderElement<EnsureCoopSignInUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnsureCoopSignInUseCase create(Ref ref) {
    return ensureCoopSignInUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnsureCoopSignInUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnsureCoopSignInUseCase>(value),
    );
  }
}

String _$ensureCoopSignInUseCaseHash() =>
    r'3e257dbdd36e949d112b03bfcbe95262113ae0f5';

/// サインイン済みの uid を返すユースケース (サインインは試さない)

@ProviderFor(getCoopSignedInUidUseCase)
final getCoopSignedInUidUseCaseProvider = GetCoopSignedInUidUseCaseProvider._();

/// サインイン済みの uid を返すユースケース (サインインは試さない)

final class GetCoopSignedInUidUseCaseProvider
    extends
        $FunctionalProvider<
          GetCoopSignedInUidUseCase,
          GetCoopSignedInUidUseCase,
          GetCoopSignedInUidUseCase
        >
    with $Provider<GetCoopSignedInUidUseCase> {
  /// サインイン済みの uid を返すユースケース (サインインは試さない)
  GetCoopSignedInUidUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCoopSignedInUidUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCoopSignedInUidUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCoopSignedInUidUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCoopSignedInUidUseCase create(Ref ref) {
    return getCoopSignedInUidUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCoopSignedInUidUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCoopSignedInUidUseCase>(value),
    );
  }
}

String _$getCoopSignedInUidUseCaseHash() =>
    r'c91c85ce3afd45d2ffb3207e38e0cfcbaffcf43a';

/// ルームとメンバー、クリアを監視するユースケース

@ProviderFor(watchRoomUseCase)
final watchRoomUseCaseProvider = WatchRoomUseCaseProvider._();

/// ルームとメンバー、クリアを監視するユースケース

final class WatchRoomUseCaseProvider
    extends
        $FunctionalProvider<
          WatchRoomUseCase,
          WatchRoomUseCase,
          WatchRoomUseCase
        >
    with $Provider<WatchRoomUseCase> {
  /// ルームとメンバー、クリアを監視するユースケース
  WatchRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchRoomUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WatchRoomUseCase create(Ref ref) {
    return watchRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchRoomUseCase>(value),
    );
  }
}

String _$watchRoomUseCaseHash() => r'123c691147598b3d59bfd01b44aceb5a5fa5fe1a';

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

/// ルームを抜けるユースケース

@ProviderFor(leaveRoomUseCase)
final leaveRoomUseCaseProvider = LeaveRoomUseCaseProvider._();

/// ルームを抜けるユースケース

final class LeaveRoomUseCaseProvider
    extends
        $FunctionalProvider<
          LeaveRoomUseCase,
          LeaveRoomUseCase,
          LeaveRoomUseCase
        >
    with $Provider<LeaveRoomUseCase> {
  /// ルームを抜けるユースケース
  LeaveRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaveRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaveRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<LeaveRoomUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LeaveRoomUseCase create(Ref ref) {
    return leaveRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaveRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaveRoomUseCase>(value),
    );
  }
}

String _$leaveRoomUseCaseHash() => r'b251999b441111a87626dcbe84a29fdd85fe8637';

/// ロビーでミッションの設定を変更するユースケース

@ProviderFor(updateRoomSettingsUseCase)
final updateRoomSettingsUseCaseProvider = UpdateRoomSettingsUseCaseProvider._();

/// ロビーでミッションの設定を変更するユースケース

final class UpdateRoomSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateRoomSettingsUseCase,
          UpdateRoomSettingsUseCase,
          UpdateRoomSettingsUseCase
        >
    with $Provider<UpdateRoomSettingsUseCase> {
  /// ロビーでミッションの設定を変更するユースケース
  UpdateRoomSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateRoomSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateRoomSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateRoomSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateRoomSettingsUseCase create(Ref ref) {
    return updateRoomSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateRoomSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateRoomSettingsUseCase>(value),
    );
  }
}

String _$updateRoomSettingsUseCaseHash() =>
    r'6276919b5106030ff6c584cc93084856eaba3948';

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
    r'8605e283cb1764a2038b48e28671e23efc48c536';

/// 協力プレイの履歴を作成・更新するユースケース

@ProviderFor(upsertCoopHistoryUseCase)
final upsertCoopHistoryUseCaseProvider = UpsertCoopHistoryUseCaseProvider._();

/// 協力プレイの履歴を作成・更新するユースケース

final class UpsertCoopHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          UpsertCoopHistoryUseCase,
          UpsertCoopHistoryUseCase,
          UpsertCoopHistoryUseCase
        >
    with $Provider<UpsertCoopHistoryUseCase> {
  /// 協力プレイの履歴を作成・更新するユースケース
  UpsertCoopHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upsertCoopHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upsertCoopHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpsertCoopHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpsertCoopHistoryUseCase create(Ref ref) {
    return upsertCoopHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpsertCoopHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpsertCoopHistoryUseCase>(value),
    );
  }
}

String _$upsertCoopHistoryUseCaseHash() =>
    r'e3ba02fa109ef6e2308472f0a7b284001ac0c5a8';

/// ミッションを端末に用意するユースケース

@ProviderFor(prepareCoopMissionUseCase)
final prepareCoopMissionUseCaseProvider = PrepareCoopMissionUseCaseProvider._();

/// ミッションを端末に用意するユースケース

final class PrepareCoopMissionUseCaseProvider
    extends
        $FunctionalProvider<
          PrepareCoopMissionUseCase,
          PrepareCoopMissionUseCase,
          PrepareCoopMissionUseCase
        >
    with $Provider<PrepareCoopMissionUseCase> {
  /// ミッションを端末に用意するユースケース
  PrepareCoopMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prepareCoopMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prepareCoopMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<PrepareCoopMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrepareCoopMissionUseCase create(Ref ref) {
    return prepareCoopMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrepareCoopMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrepareCoopMissionUseCase>(value),
    );
  }
}

String _$prepareCoopMissionUseCaseHash() =>
    r'4d063e985ff9bc4469f8f56542e22fd359b5c0e5';

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

String _$clearSpotUseCaseHash() => r'f3c0a6f3595715d928f1d8808b6840b9ae2b2a25';

/// 共有の途中でアプリが終了した撮影の扱いを決めるユースケース

@ProviderFor(resolveUnsharedCapturesUseCase)
final resolveUnsharedCapturesUseCaseProvider =
    ResolveUnsharedCapturesUseCaseProvider._();

/// 共有の途中でアプリが終了した撮影の扱いを決めるユースケース

final class ResolveUnsharedCapturesUseCaseProvider
    extends
        $FunctionalProvider<
          ResolveUnsharedCapturesUseCase,
          ResolveUnsharedCapturesUseCase,
          ResolveUnsharedCapturesUseCase
        >
    with $Provider<ResolveUnsharedCapturesUseCase> {
  /// 共有の途中でアプリが終了した撮影の扱いを決めるユースケース
  ResolveUnsharedCapturesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resolveUnsharedCapturesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resolveUnsharedCapturesUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResolveUnsharedCapturesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ResolveUnsharedCapturesUseCase create(Ref ref) {
    return resolveUnsharedCapturesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResolveUnsharedCapturesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResolveUnsharedCapturesUseCase>(
        value,
      ),
    );
  }
}

String _$resolveUnsharedCapturesUseCaseHash() =>
    r'5d94e8fd19ecfd9c6c22a3dacccd7bd90c71b841';

/// 全スポットがクリアされていれば finished にするユースケース

@ProviderFor(finishIfAllClearedUseCase)
final finishIfAllClearedUseCaseProvider = FinishIfAllClearedUseCaseProvider._();

/// 全スポットがクリアされていれば finished にするユースケース

final class FinishIfAllClearedUseCaseProvider
    extends
        $FunctionalProvider<
          FinishIfAllClearedUseCase,
          FinishIfAllClearedUseCase,
          FinishIfAllClearedUseCase
        >
    with $Provider<FinishIfAllClearedUseCase> {
  /// 全スポットがクリアされていれば finished にするユースケース
  FinishIfAllClearedUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'finishIfAllClearedUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$finishIfAllClearedUseCaseHash();

  @$internal
  @override
  $ProviderElement<FinishIfAllClearedUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinishIfAllClearedUseCase create(Ref ref) {
    return finishIfAllClearedUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinishIfAllClearedUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinishIfAllClearedUseCase>(value),
    );
  }
}

String _$finishIfAllClearedUseCaseHash() =>
    r'990e2c48a19ce0193df1df92f0a9aae3585e5b6e';

/// ホストが途中終了するユースケース

@ProviderFor(endCoopMissionUseCase)
final endCoopMissionUseCaseProvider = EndCoopMissionUseCaseProvider._();

/// ホストが途中終了するユースケース

final class EndCoopMissionUseCaseProvider
    extends
        $FunctionalProvider<
          EndCoopMissionUseCase,
          EndCoopMissionUseCase,
          EndCoopMissionUseCase
        >
    with $Provider<EndCoopMissionUseCase> {
  /// ホストが途中終了するユースケース
  EndCoopMissionUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'endCoopMissionUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$endCoopMissionUseCaseHash();

  @$internal
  @override
  $ProviderElement<EndCoopMissionUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EndCoopMissionUseCase create(Ref ref) {
    return endCoopMissionUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EndCoopMissionUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EndCoopMissionUseCase>(value),
    );
  }
}

String _$endCoopMissionUseCaseHash() =>
    r'69f64cd27791a9f477737570d04828bbd713648d';

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

/// 条件を満たしていれば協力プレイの履歴を確定するユースケース

@ProviderFor(finalizeCoopHistoryUseCase)
final finalizeCoopHistoryUseCaseProvider =
    FinalizeCoopHistoryUseCaseProvider._();

/// 条件を満たしていれば協力プレイの履歴を確定するユースケース

final class FinalizeCoopHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          FinalizeCoopHistoryUseCase,
          FinalizeCoopHistoryUseCase,
          FinalizeCoopHistoryUseCase
        >
    with $Provider<FinalizeCoopHistoryUseCase> {
  /// 条件を満たしていれば協力プレイの履歴を確定するユースケース
  FinalizeCoopHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'finalizeCoopHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$finalizeCoopHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<FinalizeCoopHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FinalizeCoopHistoryUseCase create(Ref ref) {
    return finalizeCoopHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FinalizeCoopHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FinalizeCoopHistoryUseCase>(value),
    );
  }
}

String _$finalizeCoopHistoryUseCaseHash() =>
    r'e2cf7cb2d9508c09206e22a31480c69a869b4e97';

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
    r'd91f38814a4020be7c4eb459b9f62ed03c01e38a';

/// 履歴画面を開いたときに、未確定の協力プレイ履歴を同期する
///
/// サインインの再試行はしない (未サインインなら同期しない)。オフラインや協力プレイを使えない
/// 端末では何もせず、手元の履歴だけを表示する。

@ProviderFor(coopHistorySync)
final coopHistorySyncProvider = CoopHistorySyncProvider._();

/// 履歴画面を開いたときに、未確定の協力プレイ履歴を同期する
///
/// サインインの再試行はしない (未サインインなら同期しない)。オフラインや協力プレイを使えない
/// 端末では何もせず、手元の履歴だけを表示する。

final class CoopHistorySyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// 履歴画面を開いたときに、未確定の協力プレイ履歴を同期する
  ///
  /// サインインの再試行はしない (未サインインなら同期しない)。オフラインや協力プレイを使えない
  /// 端末では何もせず、手元の履歴だけを表示する。
  CoopHistorySyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'coopHistorySyncProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$coopHistorySyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return coopHistorySync(ref);
  }
}

String _$coopHistorySyncHash() => r'e197a4a28d29343c3aa7e2898a11717f139ea786';
