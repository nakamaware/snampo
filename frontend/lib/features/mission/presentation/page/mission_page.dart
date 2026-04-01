import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/features/history/di/history_provider.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/domain/entity/mission_progress_entity.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/store/camera_store.dart';
import 'package:snampo/features/mission/presentation/store/mission_progress_store.dart';
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
/// 次の3モードをすべて提供する。
/// - **半径指定（ランダム）**: コンストラクタ … API が半径内で目的地を決める
/// - **目的地指定**: `MissionPage.withDestination` … 地図で選んだ座標でルート生成
/// - **再開**: `MissionPage.resume` … 永続ストアのミッションを復元（API 呼び出しなし）
class MissionPage extends HookConsumerWidget {
  /// 半径指定（ランダム）モード。
  ///
  /// [radius] は検索半径（メートル）。`/mission/random/:radius` から遷移する想定。
  MissionPage({required int radius, super.key})
    : _params = MissionStoreParams.random(radius: Radius(meters: radius));

  /// 目的地指定モード。
  ///
  /// [destinationLat] / [destinationLng] はユーザーが地図で選択した緯度経度。
  MissionPage.withDestination({
    required double destinationLat,
    required double destinationLng,
    super.key,
  }) : _params = MissionStoreParams.destination(
         destination: Coordinate(
           latitude: destinationLat,
           longitude: destinationLng,
         ),
       );

  /// ゲーム再開モード（永続化済みミッションの復元）。
  const MissionPage.resume({super.key})
    : _params = const MissionStoreParams.resume();

  /// ミッションストアのパラメータ
  final MissionStoreParams _params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MissionPage build');
    final theme = Theme.of(context);
    final textStyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

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
          // 新規開始前に clearProgress し、捨てる進捗の mission_photos を削除する
          // （startProgress だけだとパス参照が失われオーファンが残る）
          final progressNotifier = ref.read(
            missionProgressStoreProvider.notifier,
          );
          final persistedNotifier = ref.read(persistedMissionProvider.notifier);
          final checkpointCount = mission.waypoints.length + 1;
          Future(() async {
            await progressNotifier.clearProgress();
            progressNotifier.startProgress(checkpointCount);
            persistedNotifier.setMission(mission);
          });
        }
      });
    });

    final missionAsyncValue = ref.watch(missionStoreProvider(_params));

    return missionAsyncValue.when(
      data: (missionInfo) {
        return Scaffold(
          appBar: AppBar(
            title: Text('On MISSION', style: textStyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Stack(
            children: [
              MapView(currentLocation: missionInfo.departure, params: _params),
              SnapView(params: _params),
            ],
          ),
        );
      },
      loading:
          () => Scaffold(
            appBar: AppBar(
              title: Text('On MISSION', style: textStyle),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.blue,
                    size: 100,
                  ),
                  const Text('NOW LOADING'),
                ],
              ),
            ),
          ),
      error: (error, stackTrace) {
        log('error: $error');
        return Scaffold(
          appBar: AppBar(
            title: Text('On MISSION', style: textStyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [const Text('エラーが発生しました'), Text('$error')],
            ),
          ),
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

/// mission_pageで表示するsnapのメニューウィジェット
class SnapView extends StatelessWidget {
  /// SnapViewウィジェットのコンストラクタ
  const SnapView({required this.params, super.key});

  /// ミッションストアのパラメータ
  final MissionStoreParams params;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      // 初期の表示割合
      initialChildSize: 0.15,
      // 最小の表示割合
      minChildSize: 0.15,
      // snapで止める時の割合
      snapSizes: const [0.15, 0.6, 1.0],
      builder: (BuildContext context, ScrollController scrollController) {
        return ColoredBox(
          color: theme.colorScheme.surface,
          child: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      SnapViewState(params: params),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                child: ColoredBox(
                  color: theme.colorScheme.surface,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        height: 10,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// SnapView内でミッション情報を表示するウィジェット
class SnapViewState extends HookConsumerWidget {
  /// SnapViewStateウィジェットのコンストラクタ
  const SnapViewState({required this.params, super.key});

  /// ミッションストアのパラメータ
  final MissionStoreParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubmitting = useState(false);
    final theme = Theme.of(context);
    final titleTextStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final buttonTextStyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final missionAsyncValue = ref.watch(missionStoreProvider(params));

    return missionAsyncValue.when(
      data: (missionInfo) {
        // main: 経由地 + 目的地を可変長スポットとして列挙
        final missionSpots = [
          ...missionInfo.waypoints,
          missionInfo.destination,
        ];

        return Column(
          children: [
            Text('MISSION', style: titleTextStyle),
            for (var i = 0; i < missionSpots.length; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('- Spot${i + 1}: '),
                  AnswerImage(imageBase64: missionSpots[i].imageBase64),
                  TakeSnap(spotIndex: i),
                ],
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // ボタンの背景色
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  // 形を変えるか否か
                  borderRadius: BorderRadius.circular(10), // 角の丸み
                ),
              ),
              onPressed:
                  isSubmitting.value
                      ? null
                      : () async {
                        if (isSubmitting.value) {
                          return;
                        }
                        isSubmitting.value = true;
                        try {
                          final progress = await _resolveCurrentProgress(
                            ref,
                            missionInfo,
                          );
                          if (progress == null) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('進捗情報を取得できませんでした'),
                                ),
                              );
                            }
                            return;
                          }
                          try {
                            await ref
                                .read(addMissionHistoryUseCaseProvider)
                                .call(mission: missionInfo, progress: progress);
                          } on Exception {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('履歴の保存に失敗しました')),
                              );
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
                      },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('到着', style: buttonTextStyle),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('エラーが発生しました: $error')),
    );
  }
}

/// Base64エンコードされた画像データを表示するウィジェット
class AnswerImage extends StatelessWidget {
  /// AnswerImageウィジェットのコンストラクタ
  ///
  /// [imageBase64] Base64エンコードされた画像データの文字列
  const AnswerImage({required this.imageBase64, super.key});

  /// Base64エンコードされた画像データの文字列
  final String imageBase64;

  @override
  Widget build(BuildContext context) {
    final imageUint8 = base64Decode(imageBase64);
    return SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
        // child: Image.asset(picture_name),
        child: Image.memory(
          imageUint8,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// スポットごとの撮影 UI。
///
/// - main: カメラ画面へ遷移し `cameraStore` でセッション中プレビュー
/// - feature（旧 HEAD）: 撮影後 `missionProgressStore.savePhoto` で永続パスを記録
///   （再開後もプレビュー可能）
class TakeSnap extends HookConsumerWidget {
  /// [TakeSnap] ウィジェットを作成する
  ///
  /// [spotIndex] は撮影対象スポットのインデックス（0 から連番）
  const TakeSnap({required this.spotIndex, super.key});

  /// 撮影するスポットのインデックス
  final int spotIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // main: 今セッションで撮った直後のプレビュー用パス
    final cameraPath = ref.watch(
      cameraStoreProvider.select((map) => map[spotIndex]),
    );

    // feature: 再開後は進捗の永続パスで表示。撮り直し中は camera が先に更新されるため camera を優先する
    final progressAsync = ref.watch(missionProgressStoreProvider);
    final progressPath = progressAsync.maybeWhen(
      data: (progress) {
        if (progress == null || spotIndex >= progress.checkpoints.length) {
          return null;
        }
        return progress.checkpoints[spotIndex]?.userPhotoPath;
      },
      orElse: () => null,
    );

    final displayPath = cameraPath ?? progressPath;

    if (displayPath == null) {
      return FloatingActionButton(
        heroTag: 'take_snap_spot_$spotIndex',
        onPressed: () => _handleCameraCapture(context, ref),
        child: const Icon(Icons.add_a_photo),
      );
    }

    return SizedBox(
      width: 150,
      height: 150,
      child: SetImage(picture: File(displayPath)),
    );
  }

  Future<void> _handleCameraCapture(BuildContext context, WidgetRef ref) async {
    // main: 専用カメラページへ遷移
    final capturedFile = await context.push<XFile?>('/camera');

    if (capturedFile != null && context.mounted) {
      final path = capturedFile.path;
      // プレビュー用（メモリ上の Map）
      ref.read(cameraStoreProvider.notifier).savePhoto(spotIndex, path);
      // 旧 HEAD 相当: SavePhotoUseCase 経由で永続化しチェックポイントを更新
      await ref
          .read(missionProgressStoreProvider.notifier)
          .savePhoto(spotIndex, path);
    }
  }
}

/// ファイルから読み込んだ画像を表示するウィジェット
class SetImage extends StatelessWidget {
  /// SetImageウィジェットのコンストラクタ
  ///
  /// [picture] 表示する画像ファイル
  const SetImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });
  // final String picture_name;
  /// 表示する画像ファイル
  final File picture;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      // child: Image.asset(picture_name),
      child: Image.file(picture),
    );
  }
}

/// アセットから読み込んだ画像を表示するウィジェット
class SetTestImage extends StatelessWidget {
  // final File picture;
  /// SetTestImageウィジェットのコンストラクタ
  ///
  /// [picture] 表示する画像のアセットパス
  const SetTestImage({
    // required this.picture_name,
    required this.picture,
    super.key,
  });

  /// 表示する画像のアセットパス
  final String picture;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
        // child: Image.asset(picture_name),
        child: Image.asset(picture),
      ),
    );
  }
}

/// [missionProgressStoreProvider] から最新の進捗を取得する。
///
/// `.future` は build 完了時の値に留まり savePhoto 後の最新 state を反映しないため、
/// 現在の AsyncData → loading 中なら await → まだ null なら新規開始、の順で解決する。
Future<MissionProgressEntity?> _resolveCurrentProgress(
  WidgetRef ref,
  MissionEntity missionInfo,
) async {
  final snap = ref.read(missionProgressStoreProvider);
  var progress = switch (snap) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (progress == null && snap.isLoading) {
    progress = await ref.read(missionProgressStoreProvider.future);
  }
  if (progress == null) {
    final checkpointCount = missionInfo.waypoints.length + 1;
    ref
        .read(missionProgressStoreProvider.notifier)
        .startProgress(checkpointCount);
    final snap2 = ref.read(missionProgressStoreProvider);
    progress = switch (snap2) {
      AsyncData(:final value) => value,
      _ => null,
    };
  }
  return progress;
}
