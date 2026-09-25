import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/config.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/image_coordinate.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/photo_rejected_exception.dart';
import 'package:snampo/features/mission/presentation/component/map_top_bar.dart';
import 'package:snampo/features/mission/presentation/component/mission_error_view.dart';
import 'package:snampo/features/mission/presentation/component/mission_loading_view.dart';
import 'package:snampo/features/mission/presentation/component/mission_spot_sheet.dart';
import 'package:snampo/features/mission/presentation/page/camera_page.dart';
import 'package:snampo/features/mission/presentation/page/spot_result_page.dart';
import 'package:snampo/features/mission/presentation/store/camera_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_sheet_layout_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

// 競合解消メモ（main × 再開機能の統合）:
// - main 系: MissionStoreParams + 専用カメラ画面 + cameraStore で取得〜撮影 UI
// - feature 系: missionProgressStore でスポット数・撮影の永続、
//   persistedMissionProvider でホームからの再開
// TODO(kawayama): ミッションロードのページを分離する

/// ミッション画面（ルートごとに `MissionStoreParams` が決まる）。
///
/// 次のモードをすべて提供する。
/// - **半径指定（ランダム）**: コンストラクタ … API が半径内で目的地を決める
/// - **目的地指定**: `MissionPage.withDestination` … 地図で選んだ座標でルート生成
/// - **再開**: `MissionPage.resume` … 永続ストアのミッションを復元（API 呼び出しなし）
///
/// 協力プレイなどのモードは、[MissionPageExtension] で部品を差し込む
/// (このページはモードの機能を知らない)。
class MissionPage extends HookConsumerWidget {
  /// 半径指定（ランダム）モード。
  ///
  /// [radius] は検索半径（メートル）。`/mission/random/:radius` から遷移する想定。
  MissionPage({required int radius, super.key})
    : _initialParams = MissionStoreParams.random(
        radius: Radius(meters: radius),
      ),
      kind = MissionSessionKind.solo,
      extension = null;

  /// 目的地指定モード。
  ///
  /// [destinationLat] / [destinationLng] はユーザーが地図で選択した緯度経度。
  MissionPage.withDestination({
    required double destinationLat,
    required double destinationLng,
    super.key,
  }) : _initialParams = MissionStoreParams.destination(
         destination: Coordinate(
           latitude: destinationLat,
           longitude: destinationLng,
         ),
       ),
       kind = MissionSessionKind.solo,
       extension = null;

  /// ゲーム再開モード（永続化済みミッションの復元）。
  ///
  /// [kind] の保存枠からミッションと進捗を読む。[extension] はモード固有の部品。
  const MissionPage.resume({
    this.kind = MissionSessionKind.solo,
    this.extension,
    super.key,
  }) : _initialParams = null;

  /// API から新規に取得するときのパラメータ (再開では null)
  final MissionStoreParams? _initialParams;

  /// ミッションと進捗の保存枠
  final MissionSessionKind kind;

  /// モード固有の部品 (ソロでは null)
  final MissionPageExtension? extension;

  /// ミッションストアのパラメータ
  MissionStoreParams get _params =>
      _initialParams ?? MissionStoreParams.resume(kind: kind);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MissionPage build');
    // ミッション確定時: チェックポイント数を進捗ストアに載せる（旧 HEAD）。
    // これが無いと missionProgressStore.savePhoto が正しく繋がらない。
    //
    // さらに API で新規取得した場合のみ persistedMissionProvider へ書き込み、
    // ホームの「再開」と整合させる。resume 時は既に DB に同一内容があるのでスキップ。
    ref.listen(missionStoreProvider(_params), (prev, next) {
      next.whenData((mission) {
        // 再開時は missionProgressStore が SQLite から復元済みなので、
        // startProgress するとチェックポイントが空に上書きされ写真が消える。
        if (_params is! MissionStoreParamsResume) {
          // 新規開始前に、捨てる進捗の mission_photos を削除してから始める
          // （startProgress だけだとパス参照が失われオーファンが残る）
          final progressNotifier = ref.read(
            missionProgressStoreProvider(MissionSessionKind.solo).notifier,
          );
          final persistedNotifier = ref.read(
            persistedMissionProvider(MissionSessionKind.solo).notifier,
          );
          final checkpointCount = mission.spots.length;
          Future(() async {
            await progressNotifier.restartProgress(checkpointCount);
            persistedNotifier.setMission(mission);
          });
        }
      });
    });

    final extension = this.extension;
    final missionAsyncValue = ref.watch(missionStoreProvider(_params));

    return missionAsyncValue.when(
      data: (missionInfo) {
        final body = Stack(
          children: [
            MapView(currentLocation: missionInfo.departure, params: _params),
            SnapView(params: _params, extension: extension),
          ],
        );
        // AppBar は置かず、地図を画面いっぱいに見せる (見出しはシートの「ミッション」が兼ねる)。
        // 戻るボタンとモードのボタンは、モードの画面 (準備の失敗など) の上にも出す
        return AnnotatedRegion<SystemUiOverlayStyle>(
          // 地図の上なので、ステータスバーの文字を濃くする
          value: SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: Stack(
              children: [
                extension?.wrapBody(context, body) ?? body,
                MapTopBar(actions: extension?.topActions(context) ?? const []),
              ],
            ),
          ),
        );
      },
      loading: () => const MissionLoadingView(),
      error: (error, stackTrace) {
        // やり直している間も前のエラーが残るので、読み込み中の画面にする
        if (missionAsyncValue.isLoading) return const MissionLoadingView();
        log('error: $error');
        return MissionErrorView(
          onRetry: () => ref.invalidate(missionStoreProvider(_params)),
          locationUnavailable: error is LocationUnavailableException,
          detail: Env.isDev ? '$error' : null,
          actions: extension?.topActions(context) ?? const [],
        );
      },
    );
  }
}

/// Googleマップを表示するウィジェット
class MapView extends ConsumerStatefulWidget {
  /// MapViewを作成する
  ///
  /// [currentLocation] は現在位置の座標情報
  /// [params] はミッションストアのパラメータ
  const MapView({
    required this.currentLocation,
    required this.params,
    super.key,
  });

  /// 現在位置の座標情報
  final Coordinate currentLocation;

  /// ミッションストアのパラメータ
  final MissionStoreParams params;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

/// MapViewの状態を管理するクラス
class _MapViewState extends ConsumerState<MapView> {
  /// マップの表示制御用
  late GoogleMapController mapController;

  /// ポリラインの座標リスト
  final List<LatLng> _polylineCoordinates = [];
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // main: [missionStoreProvider]（params 付き）でポリラインを一度だけデコードして描画
    ref.watch(missionStoreProvider(widget.params)).whenData((missionInfo) {
      final encodedPolyline = missionInfo.overviewPolyline;
      if (encodedPolyline.isNotEmpty && _polylineCoordinates.isEmpty) {
        final coordinates = decodePolyline(encodedPolyline);
        if (coordinates.isNotEmpty) {
          _polylineCoordinates.addAll(coordinates);

          if (mounted) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('poly'),
                  points: _polylineCoordinates,
                  color: Colors.blue,
                  width: 3,
                ),
              );
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面の幅と高さを決定する
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final missionAsyncValue = ref.watch(missionStoreProvider(widget.params));
    final missionInfo = missionAsyncValue.value;
    if (missionInfo == null) {
      return const SizedBox.shrink();
    }

    final target = missionInfo.destination;
    final currentLat = widget.currentLocation.latitude;
    final currentLng = widget.currentLocation.longitude;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                //マップの初期位置を指定
                zoom: 17, //ズーム
                target: LatLng(
                  //緯度, 経度
                  currentLat,
                  currentLng,
                ),
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('marker_1'),
                  position: LatLng(
                    target.coordinate.latitude,
                    target.coordinate.longitude,
                  ),
                ),
              },
              polylines: _polylines,
              padding: EdgeInsets.only(
                top: MediaQuery.paddingOf(context).top + MapTopBar.height,
                bottom: MediaQuery.paddingOf(context).bottom + 130,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Mission 画面の、スポットを並べるボトムシート
class SnapView extends HookConsumerWidget {
  /// SnapViewウィジェットのコンストラクタ
  const SnapView({required this.params, this.extension, super.key});

  /// ミッションストアのパラメータ
  final MissionStoreParams params;

  /// モード固有の部品 (ソロでは null)
  final MissionPageExtension? extension;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = useState(false);
    final capturingIndex = useState<int?>(null);
    final missionInfo = ref.watch(missionStoreProvider(params)).value;
    final progress = ref.watch(missionProgressStoreProvider(params.kind)).value;
    // 今セッションで撮った直後の写真 (進捗に保存されるまでのあいだ使う)
    final cameraPaths = ref.watch(cameraStoreProvider);
    final layout = ref.watch(missionSheetLayoutStoreProvider);
    if (missionInfo == null) {
      return const SizedBox.shrink();
    }

    final missionSpots = missionInfo.spots;
    final isDestinationMode = missionInfo.radius == null;
    final checkpoints = progress?.checkpoints ?? const [];
    CheckpointProgress? checkpointAt(int index) =>
        index < checkpoints.length ? checkpoints[index] : null;
    final allCompleted =
        checkpoints.isNotEmpty &&
        checkpoints.every((checkpoint) => checkpoint != null);

    final extension = this.extension;
    final sheetSpots = [
      for (var i = 0; i < missionSpots.length; i++)
        () {
          final checkpoint = checkpointAt(i);
          final ownPhotoPath = checkpoint?.userPhotoPath ?? cameraPaths[i];
          final discovererName = extension?.discovererName(
            ref,
            checkpoint: checkpoint,
          );
          return MissionSheetSpot(
            referenceImageBase64: missionSpots[i].imageBase64,
            name: missionSpots[i].name,
            // 協力プレイで他の人が発見したスポットも、結果 (発見者の写真) を見られる
            isCleared: checkpoint?.hasResult ?? false,
            canCapture:
                ownPhotoPath == null &&
                (extension?.canCapture(
                      ref,
                      spot: missionSpots[i],
                      checkpoint: checkpoint,
                    ) ??
                    true),
            photoPath: ownPhotoPath ?? checkpoint?.discovererThumbPath,
            photoOwnerName: ownPhotoPath != null ? 'あなた' : discovererName,
            discovererName: discovererName,
          );
        }(),
    ];

    Future<void> showPlayResult() async {
      isSubmitting.value = true;
      try {
        final progress = await _resolveCurrentProgress(
          ref,
          missionInfo,
          params.kind,
        );
        if (progress == null) {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('進捗情報を取得できませんでした')));
          }
          return;
        }
        try {
          await ref
              .read(addMissionHistoryUseCaseProvider)
              .call(mission: missionInfo, progress: progress);
        } on Exception {
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('履歴の保存に失敗しました')));
          }
          return;
        }
        if (context.mounted) {
          context.go('/result');
        }
      } finally {
        if (context.mounted) {
          isSubmitting.value = false;
        }
      }
    }

    return MissionSpotSheet(
      spots: sheetSpots,
      layout: layout,
      onLayoutChanged:
          ref.read(missionSheetLayoutStoreProvider.notifier).change,
      capturingIndex: capturingIndex.value,
      onCapture: (index) async {
        if (capturingIndex.value != null) return;
        capturingIndex.value = index;
        try {
          await _captureSpot(
            context,
            ref,
            spotIndex: index,
            missionPoint: missionSpots[index],
            isDestinationMode: isDestinationMode,
            kind: params.kind,
            extension: extension,
          );
        } finally {
          if (context.mounted) capturingIndex.value = null;
        }
      },
      onShowResult: (index) {
        final checkpoint = checkpointAt(index);
        if (checkpoint == null) return;
        context.push(
          '/spot-result',
          extra: SpotResultPageArgs(
            spotIndex: index,
            totalCheckpointCount: missionSpots.length,
            missionPoint: missionSpots[index],
            checkpoint: checkpoint,
            isDestinationMode: isDestinationMode,
            isCoop: params.kind == MissionSessionKind.coop,
          ),
        );
      },
      showPlayResultButton:
          (extension?.showsResultButton ?? true) && allCompleted,
      onShowPlayResult: isSubmitting.value ? null : showPlayResult,
    );
  }
}

/// [spotIndex] 番目のスポットを撮影する。
///
/// カメラ画面へ移り、撮影と採点が確定したら `missionProgressStore` に保存して
/// (再開後もプレビューできる)、スポットの結果画面へ進む。
Future<void> _captureSpot(
  BuildContext context,
  WidgetRef ref, {
  required int spotIndex,
  required ImageCoordinate missionPoint,
  required bool isDestinationMode,
  required MissionSessionKind kind,
  required MissionPageExtension? extension,
}) async {
  final router = GoRouter.of(context);
  SpotResultPageArgs? nextSpotResultArgs;
  await router.push<void>(
    '/camera',
    extra: CameraPageArgs(
      title: 'Spot ${spotIndex + 1}',
      referenceImageBase64: missionPoint.imageBase64,
      loadingMessage: extension?.captureLoadingMessage ?? '採点中...',
      onPhotoAccepted: (capturedFile, zoomLevel) async {
        final path = capturedFile.path;
        final currentPosition =
            await ref.read(getCurrentPositionUseCaseProvider).call();
        final capturedHeading =
            await ref.read(getCurrentHeadingUseCaseProvider).call();
        final judgeResult = ref
            .read(judgePhotoUseCaseProvider)
            .call(
              currentPosition: currentPosition,
              target: missionPoint,
              capturedHeading: capturedHeading,
              zoomLevel: zoomLevel,
            );

        final checkpoint = await ref
            .read(missionProgressStoreProvider(kind).notifier)
            .completeCheckpoint(
              index: spotIndex,
              tempPhotoPath: path,
              guessPosition: currentPosition,
              capturedHeading: capturedHeading,
              judgeRank: judgeResult.rank,
              distanceErrorMeters: judgeResult.distanceErrorMeters,
              headingErrorDegrees: judgeResult.headingErrorDegrees,
              zoomLevel: judgeResult.zoomLevel,
            );
        if (checkpoint == null) {
          return false;
        }
        await extension?.onCheckpointCompleted(
          ref,
          index: spotIndex,
          checkpoint: checkpoint,
        );

        ref
            .read(cameraStoreProvider.notifier)
            .savePhoto(spotIndex, checkpoint.userPhotoPath ?? path);
        nextSpotResultArgs = SpotResultPageArgs(
          spotIndex: spotIndex,
          totalCheckpointCount:
              ref
                  .read(missionProgressStoreProvider(kind))
                  .value
                  ?.checkpoints
                  .length ??
              spotIndex + 1,
          missionPoint: missionPoint,
          checkpoint: checkpoint,
          isDestinationMode: isDestinationMode,
          closeLabel: extension?.spotResultCloseLabel(ref, index: spotIndex),
          isCoop: kind == MissionSessionKind.coop,
        );
        return true;
      },
    ),
  );
  if (!context.mounted || nextSpotResultArgs == null) {
    return;
  }
  await router.push('/spot-result', extra: nextSpotResultArgs);
}

/// [missionProgressStoreProvider] から最新の進捗を取得する。
///
/// `.future` は build 完了時の値に留まり savePhoto 後の最新 state を反映しないため、
/// 現在の AsyncData → loading 中なら await → まだ null なら新規開始、の順で解決する。
Future<MissionProgressEntity?> _resolveCurrentProgress(
  WidgetRef ref,
  MissionEntity missionInfo,
  MissionSessionKind kind,
) async {
  final snap = ref.read(missionProgressStoreProvider(kind));
  if (snap.hasError) {
    return null;
  }
  var progress = switch (snap) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (progress == null && snap.isLoading) {
    try {
      progress = await ref.read(missionProgressStoreProvider(kind).future);
    } on Object {
      return null;
    }
  }
  if (progress == null) {
    final checkpointCount = missionInfo.spots.length;
    ref
        .read(missionProgressStoreProvider(kind).notifier)
        .startProgress(checkpointCount);
    final snap2 = ref.read(missionProgressStoreProvider(kind));
    progress = switch (snap2) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
  return progress;
}

/// Mission 画面にモード (協力プレイなど) ごとの部品を差し込むための口
///
/// Mission 画面はモードの機能を知らず、モードの側がこれを実装して渡す。
abstract class MissionPageExtension {
  /// [MissionPageExtension] を作成する
  const MissionPageExtension();

  /// 画面の中身を包む (モード固有のお知らせや画面遷移など)
  Widget wrapBody(BuildContext context, Widget body) => body;

  /// 地図の右上に並べるボタン
  List<Widget> topActions(BuildContext context) => const [];

  /// スポットの発見者の表示名 (発見者がいない・ソロなら null)
  ///
  /// build の中で呼ぶ。状態の変化で作り直すときは [ref] で watch する。
  String? discovererName(
    WidgetRef ref, {
    required CheckpointProgress? checkpoint,
  }) => null;

  /// スポットを撮影できるか (build の中で呼ぶ。状態の変化で作り直すときは [ref] で watch する)
  bool canCapture(
    WidgetRef ref, {
    required ImageCoordinate spot,
    required CheckpointProgress? checkpoint,
  }) => true;

  /// 撮影と採点が確定したとき
  ///
  /// 完了するまで撮影画面のローディングを続け、完了したらスポットの結果画面へ進む。
  /// 撮影を受け付けられなければ [PhotoRejectedException] を投げる (結果画面へは進まない)。
  Future<void> onCheckpointCompleted(
    WidgetRef ref, {
    required int index,
    required CheckpointProgress checkpoint,
  }) async {}

  /// 撮影してから [onCheckpointCompleted] が完了するまでに表示する文言
  String get captureLoadingMessage => '採点中...';

  /// 撮影した [index] 番目のスポットの結果画面で、閉じるボタンに出す文言 (null なら既定)
  String? spotResultCloseLabel(WidgetRef ref, {required int index}) => null;

  /// 「プレイ結果」ボタンを表示するか
  bool get showsResultButton => true;
}
