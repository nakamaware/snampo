// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mission_sheet_layout_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mission 画面のシートの並べ方 (アプリを閉じるまで覚えておく)

@ProviderFor(MissionSheetLayoutStore)
final missionSheetLayoutStoreProvider = MissionSheetLayoutStoreProvider._();

/// Mission 画面のシートの並べ方 (アプリを閉じるまで覚えておく)
final class MissionSheetLayoutStoreProvider
    extends $NotifierProvider<MissionSheetLayoutStore, MissionSheetLayout> {
  /// Mission 画面のシートの並べ方 (アプリを閉じるまで覚えておく)
  MissionSheetLayoutStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'missionSheetLayoutStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$missionSheetLayoutStoreHash();

  @$internal
  @override
  MissionSheetLayoutStore create() => MissionSheetLayoutStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MissionSheetLayout value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MissionSheetLayout>(value),
    );
  }
}

String _$missionSheetLayoutStoreHash() =>
    r'fca8afe1bb24ea70d8bd7e2607b1219ef7c2edbb';

/// Mission 画面のシートの並べ方 (アプリを閉じるまで覚えておく)

abstract class _$MissionSheetLayoutStore extends $Notifier<MissionSheetLayout> {
  MissionSheetLayout build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MissionSheetLayout, MissionSheetLayout>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MissionSheetLayout, MissionSheetLayout>,
              MissionSheetLayout,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
