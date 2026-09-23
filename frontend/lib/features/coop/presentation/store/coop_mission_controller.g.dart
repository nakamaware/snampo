// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coop_mission_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - finished になったら履歴を確定する

@ProviderFor(CoopMissionController)
final coopMissionControllerProvider = CoopMissionControllerFamily._();

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - finished になったら履歴を確定する
final class CoopMissionControllerProvider
    extends $NotifierProvider<CoopMissionController, CoopMissionState> {
  /// 協力プレイのミッションを進める
  ///
  /// ルームと `clears` を監視し、次を行う。
  /// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
  /// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
  /// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
  /// - finished になったら履歴を確定する
  CoopMissionControllerProvider._({
    required CoopMissionControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'coopMissionControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$coopMissionControllerHash();

  @override
  String toString() {
    return r'coopMissionControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CoopMissionController create() => CoopMissionController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CoopMissionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CoopMissionState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CoopMissionControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$coopMissionControllerHash() =>
    r'6be93d6ac7af432723e5aa62bd3e2bc3cc715e41';

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - finished になったら履歴を確定する

final class CoopMissionControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CoopMissionController,
          CoopMissionState,
          CoopMissionState,
          CoopMissionState,
          String
        > {
  CoopMissionControllerFamily._()
    : super(
        retry: null,
        name: r'coopMissionControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// 協力プレイのミッションを進める
  ///
  /// ルームと `clears` を監視し、次を行う。
  /// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
  /// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
  /// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
  /// - finished になったら履歴を確定する

  CoopMissionControllerProvider call(String roomCode) =>
      CoopMissionControllerProvider._(argument: roomCode, from: this);

  @override
  String toString() => r'coopMissionControllerProvider';
}

/// 協力プレイのミッションを進める
///
/// ルームと `clears` を監視し、次を行う。
/// - playing になったら、バンドルを取得してミッションを端末に用意し、履歴を「進行中」で作る
/// - `clears` の変更を履歴と進捗に反映し (サーバが正)、他の人の発見をバナーで知らせる
/// - 全スポットがクリアされたら finished にする (どの端末が書いてもよい)
/// - finished になったら履歴を確定する

abstract class _$CoopMissionController extends $Notifier<CoopMissionState> {
  late final _$args = ref.$arg as String;
  String get roomCode => _$args;

  CoopMissionState build(String roomCode);
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
