// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 履歴専用 Drift DB

@ProviderFor(historyDatabase)
final historyDatabaseProvider = HistoryDatabaseProvider._();

/// 履歴専用 Drift DB

final class HistoryDatabaseProvider
    extends
        $FunctionalProvider<HistoryDatabase, HistoryDatabase, HistoryDatabase>
    with $Provider<HistoryDatabase> {
  /// 履歴専用 Drift DB
  HistoryDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyDatabaseHash();

  @$internal
  @override
  $ProviderElement<HistoryDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HistoryDatabase create(Ref ref) {
    return historyDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryDatabase>(value),
    );
  }
}

String _$historyDatabaseHash() => r'fd67fa6ead688d33d5ea27163d3fff343298738e';

/// Street View 画像のファイル保存

@ProviderFor(streetViewStorage)
final streetViewStorageProvider = StreetViewStorageProvider._();

/// Street View 画像のファイル保存

final class StreetViewStorageProvider
    extends
        $FunctionalProvider<
          StreetViewStorage,
          StreetViewStorage,
          StreetViewStorage
        >
    with $Provider<StreetViewStorage> {
  /// Street View 画像のファイル保存
  StreetViewStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streetViewStorageProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streetViewStorageHash();

  @$internal
  @override
  $ProviderElement<StreetViewStorage> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StreetViewStorage create(Ref ref) {
    return streetViewStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreetViewStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreetViewStorage>(value),
    );
  }
}

String _$streetViewStorageHash() => r'10dc40bf16f8d2699d0504a51d66998da2d4ee0b';

/// 履歴リポジトリ

@ProviderFor(historyRepository)
final historyRepositoryProvider = HistoryRepositoryProvider._();

/// 履歴リポジトリ

final class HistoryRepositoryProvider
    extends
        $FunctionalProvider<
          IHistoryRepository,
          IHistoryRepository,
          IHistoryRepository
        >
    with $Provider<IHistoryRepository> {
  /// 履歴リポジトリ
  HistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyRepositoryHash();

  @$internal
  @override
  $ProviderElement<IHistoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IHistoryRepository create(Ref ref) {
    return historyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IHistoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IHistoryRepository>(value),
    );
  }
}

String _$historyRepositoryHash() => r'f0e5315ec31e3f0f0997c14e81cd28a025b9f818';

/// 履歴一覧を取得するユースケース

@ProviderFor(getMissionHistoriesUseCase)
final getMissionHistoriesUseCaseProvider =
    GetMissionHistoriesUseCaseProvider._();

/// 履歴一覧を取得するユースケース

final class GetMissionHistoriesUseCaseProvider
    extends
        $FunctionalProvider<
          GetMissionHistoriesUseCase,
          GetMissionHistoriesUseCase,
          GetMissionHistoriesUseCase
        >
    with $Provider<GetMissionHistoriesUseCase> {
  /// 履歴一覧を取得するユースケース
  GetMissionHistoriesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMissionHistoriesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMissionHistoriesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMissionHistoriesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMissionHistoriesUseCase create(Ref ref) {
    return getMissionHistoriesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMissionHistoriesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMissionHistoriesUseCase>(value),
    );
  }
}

String _$getMissionHistoriesUseCaseHash() =>
    r'90377eb05f29b5e45e581812aa65ec56b7487425';

/// 履歴を id で 1 件取得するユースケース

@ProviderFor(getMissionHistoryUseCase)
final getMissionHistoryUseCaseProvider = GetMissionHistoryUseCaseProvider._();

/// 履歴を id で 1 件取得するユースケース

final class GetMissionHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          GetMissionHistoryUseCase,
          GetMissionHistoryUseCase,
          GetMissionHistoryUseCase
        >
    with $Provider<GetMissionHistoryUseCase> {
  /// 履歴を id で 1 件取得するユースケース
  GetMissionHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMissionHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMissionHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMissionHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMissionHistoryUseCase create(Ref ref) {
    return getMissionHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMissionHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMissionHistoryUseCase>(value),
    );
  }
}

String _$getMissionHistoryUseCaseHash() =>
    r'1f1f183c8627216f1de3b0856ff9341070f659a3';

/// 履歴を 1 件追加するユースケース

@ProviderFor(addMissionHistoryUseCase)
final addMissionHistoryUseCaseProvider = AddMissionHistoryUseCaseProvider._();

/// 履歴を 1 件追加するユースケース

final class AddMissionHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          AddMissionHistoryUseCase,
          AddMissionHistoryUseCase,
          AddMissionHistoryUseCase
        >
    with $Provider<AddMissionHistoryUseCase> {
  /// 履歴を 1 件追加するユースケース
  AddMissionHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addMissionHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addMissionHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddMissionHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddMissionHistoryUseCase create(Ref ref) {
    return addMissionHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddMissionHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddMissionHistoryUseCase>(value),
    );
  }
}

String _$addMissionHistoryUseCaseHash() =>
    r'1be8103c1b852cd967954b3130c00a9c594c83ec';

/// 履歴を 1 件削除するユースケース

@ProviderFor(removeMissionHistoryUseCase)
final removeMissionHistoryUseCaseProvider =
    RemoveMissionHistoryUseCaseProvider._();

/// 履歴を 1 件削除するユースケース

final class RemoveMissionHistoryUseCaseProvider
    extends
        $FunctionalProvider<
          RemoveMissionHistoryUseCase,
          RemoveMissionHistoryUseCase,
          RemoveMissionHistoryUseCase
        >
    with $Provider<RemoveMissionHistoryUseCase> {
  /// 履歴を 1 件削除するユースケース
  RemoveMissionHistoryUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'removeMissionHistoryUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$removeMissionHistoryUseCaseHash();

  @$internal
  @override
  $ProviderElement<RemoveMissionHistoryUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RemoveMissionHistoryUseCase create(Ref ref) {
    return removeMissionHistoryUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RemoveMissionHistoryUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RemoveMissionHistoryUseCase>(value),
    );
  }
}

String _$removeMissionHistoryUseCaseHash() =>
    r'60e8b77e4f3afaaffa87749e23c335074303f56f';
