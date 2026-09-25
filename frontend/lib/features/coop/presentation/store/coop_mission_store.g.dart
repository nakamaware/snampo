// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_mission_store.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。

@ProviderFor(CoopMissionStore)
final coopMissionStoreProvider = CoopMissionStoreFamily._();

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。
final class CoopMissionStoreProvider
    extends $NotifierProvider<CoopMissionStore, CoopMissionState> {
  /// 協力プレイのミッションを進める
  ///
  /// ルームと `clears` を監視し、次を行う。
  /// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
  /// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
  ///   そのスポットの結果画面へ移るためのイベントを出す
  /// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
  /// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
  ///   (finished のあとも、サムネを取得するまでは確定しない)
  ///
  /// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。
  CoopMissionStoreProvider._({
    required CoopMissionStoreFamily super.from,
    required RoomCode super.argument,
  }) : super(
         retry: null,
         name: r'coopMissionStoreProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coopMissionStoreHash();

  @override
  String toString() {
    return r'coopMissionStoreProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CoopMissionStore create() => CoopMissionStore();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoopMissionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoopMissionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoopMissionStoreProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coopMissionStoreHash() => r'0c662c40e5f91176f7928b67f9a0acdea367f40b';

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。

final class CoopMissionStoreFamily extends $Family
    with
        $ClassFamilyOverride<
          CoopMissionStore,
          CoopMissionState,
          CoopMissionState,
          CoopMissionState,
          RoomCode
        > {
  CoopMissionStoreFamily._()
    : super(
        retry: null,
        name: r'coopMissionStoreProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 協力プレイのミッションを進める
  ///
  /// ルームと `clears` を監視し、次を行う。
  /// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
  /// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
  ///   そのスポットの結果画面へ移るためのイベントを出す
  /// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
  /// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
  ///   (finished のあとも、サムネを取得するまでは確定しない)
  ///
  /// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。

  CoopMissionStoreProvider call(RoomCode roomCode) =>
      CoopMissionStoreProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'coopMissionStoreProvider';
}

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせて、
///   そのスポットの結果画面へ移るためのイベントを出す
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - 確定の条件 ([shouldFinalizeHistory]) を満たしたら履歴を確定する
///   (finished のあとも、サムネを取得するまでは確定しない)
///
/// ルームを抜けたら invalidate して監視を止める (抜けたルームの通知で今の進捗を変えないため)。

abstract class _$CoopMissionStore extends $Notifier<CoopMissionState> {
  late final _$args = ref.$arg as RoomCode;
  RoomCode get roomCode => _$args;

  CoopMissionState build(RoomCode roomCode);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CoopMissionState, CoopMissionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CoopMissionState, CoopMissionState>,
              CoopMissionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
