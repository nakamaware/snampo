import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:snampo/features/mission/domain/entity/mission_entity.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';
import 'package:snampo/features/mission/presentation/util/polyline_util.dart';

/// ミッションページを表示するウィジェット
class MissionPage extends ConsumerWidget {
  const MissionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log('MissionPage build');
    final theme = Theme.of(context);
    final textstyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);

    final missionAsyncValue = ref.watch(missionStoreProvider);

    return missionAsyncValue.when(
      data: (missionInfo) {
        if (missionInfo == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('On MISSION', style: textstyle),
              centerTitle: true,
              backgroundColor: theme.colorScheme.primary,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('On MISSION', style: textstyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: const Stack(
            children: [
              MapView(),
              SnapView(),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('On MISSION', style: textstyle),
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
      error: (Object error, StackTrace stackTrace) {
        log('error: $error');
        return Scaffold(
          appBar: AppBar(
            title: Text('On MISSION', style: textstyle),
            centerTitle: true,
            backgroundColor: theme.colorScheme.primary,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('エラーが発生しました'),
                Text('$error'),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Googleマップを表示するウィジェット
class MapView extends ConsumerWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionInfo = ref.watch(missionStoreProvider).value;
    if (missionInfo == null) return const SizedBox.shrink();

    final currentLat = missionInfo.departure.latitude;
    final currentLng = missionInfo.departure.longitude;
    final target = missionInfo.destination;

    final polylines = <Polyline>{};
    if (missionInfo.overviewPolyline.isNotEmpty) {
      final coordinates = decodePolyline(missionInfo.overviewPolyline);
      if (coordinates.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId('poly'),
            points: coordinates,
            color: Colors.blue,
            width: 3,
          ),
        );
      }
    }

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height,
      width: width,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 17,
                target: LatLng(currentLat, currentLng),
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
              polylines: polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// mission_pageで表示するsnapのメニューウィジェット
class SnapView extends ConsumerWidget {
  const SnapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final missionAsyncValue = ref.watch(missionStoreProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.15,
      minChildSize: 0.15,
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
                      missionAsyncValue.when(
                        data: (MissionEntity? missionInfo) {
                          if (missionInfo == null) {
                            return const SizedBox.shrink();
                          }
                          final midpointInfoList = missionInfo.waypoints;
                          final destination = missionInfo.destination;
                          final titelTextstyle =
                              theme.textTheme.displaySmall!.copyWith(
                            color: theme.colorScheme.secondary,
                          );
                          final buttonTextstyle =
                              theme.textTheme.bodyLarge!.copyWith(
                            color: theme.colorScheme.onPrimary,
                          );

                          return Column(
                            children: [
                              Text('MISSION', style: titelTextstyle),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('- Spot1: '),
                                  if (midpointInfoList.isNotEmpty)
                                    AnswerImage(
                                        imageBase64:
                                            midpointInfoList[0].imageBase64)
                                  else
                                    const SizedBox(width: 150, height: 150),
                                  const TakeSnap(spotIndex: 0),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('- Spot2: '),
                                  AnswerImage(
                                      imageBase64: destination.imageBase64),
                                  const TakeSnap(spotIndex: 1),
                                ],
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor:
                                      theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => context.push('/result'),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Text('到着', style: buttonTextstyle),
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (Object error, StackTrace stackTrace) =>
                            Center(
                                child: Text('エラーが発生しました: $error')),
                      ),
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

/// Base64エンコードされた画像データを表示するウィジェット
class AnswerImage extends StatelessWidget {
  const AnswerImage({required this.imageBase64, super.key});

  final String imageBase64;

  @override
  Widget build(BuildContext context) {
    final imageUint8 = base64Decode(imageBase64);
    return SizedBox(
      width: 150,
      height: 150,
      child: FittedBox(
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

/// 写真を撮影するためのボタンを表示するウィジェット
class TakeSnap extends StatefulWidget {
  const TakeSnap({required this.spotIndex, super.key});

  final int spotIndex;

  @override
  State<TakeSnap> createState() => _TakeSnapState();
}

class _TakeSnapState extends State<TakeSnap> {
  File? _image;
  final picker = ImagePicker();

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _image == null
        ? FloatingActionButton(
            heroTag: 'take_snap_spot_${widget.spotIndex}',
            onPressed: getImage,
            child: const Icon(Icons.add_a_photo),
          )
        : SizedBox(
            width: 150,
            height: 150,
            child: SetImage(picture: _image!),
          );
  }
}

/// ファイルから読み込んだ画像を表示するウィジェット
class SetImage extends StatelessWidget {
  const SetImage({required this.picture, super.key});

  final File picture;

  @override
  Widget build(BuildContext context) {
    return FittedBox(child: Image.file(picture));
  }
}
