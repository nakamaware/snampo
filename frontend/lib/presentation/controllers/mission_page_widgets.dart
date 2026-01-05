import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snampo/presentation/controllers/game_session_controller.dart';
import 'package:snampo/presentation/controllers/mission_controller.dart';

/// mission_pageで表示するsnapのメニューウィジェット
class SnapView extends StatelessWidget {
  /// SnapViewウィジェットのコンストラクタ
  const SnapView({
    super.key,
  });

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
                  child: const Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      SnapViewState(),
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
class SnapViewState extends ConsumerWidget {
  /// SnapViewStateウィジェットのコンストラクタ
  const SnapViewState({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final titelTextstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.secondary,
    );
    final buttonTextstyle = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final midpointInfoList = ref.watch(midpointInfoListProvider);
    final destination = ref.watch(targetProvider);

    // データがまだ読み込まれていない場合はローディング表示
    if (midpointInfoList == null || midpointInfoList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Text(
          'MISSION',
          style: titelTextstyle,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('- Spot1: '),
            if (midpointInfoList.isNotEmpty &&
                midpointInfoList[0].imageUtf8 != null)
              AnswerImage(imageUtf8: midpointInfoList[0].imageUtf8!)
            else
              const SizedBox(width: 150, height: 150),
            const TakeSnap(spotIndex: 1),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('- Spot2: '),
            if (destination != null && destination.imageUtf8 != null)
              AnswerImage(imageUtf8: destination.imageUtf8!)
            else
              const SizedBox(width: 150, height: 150),
            const TakeSnap(spotIndex: 2),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary, // ボタンの背景色
            foregroundColor: theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              // 形を変えるか否か
              borderRadius: BorderRadius.circular(10), // 角の丸み
            ),
          ),
          onPressed: () async {
            if (context.mounted) {
              await context.push<void>('/result');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text('到着', style: buttonTextstyle),
          ),
        ),
      ],
    );
  }
}

/// Base64エンコードされた画像データを表示するウィジェット
class AnswerImage extends StatelessWidget {
  /// AnswerImageウィジェットのコンストラクタ
  ///
  /// [imageUtf8] Base64エンコードされた画像データの文字列
  const AnswerImage({
    required this.imageUtf8,
    super.key,
  });

  /// Base64エンコードされた画像データの文字列
  final String imageUtf8;

  @override
  Widget build(BuildContext context) {
    log('answer image utf8 is');
    log(imageUtf8);
    final imageUint8 = base64Decode(imageUtf8);
    log('imageUint8 is');
    log(imageUint8.toString());
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

/// 写真を撮影するためのボタンを表示するウィジェット
class TakeSnap extends ConsumerWidget {
  /// TakeSnapウィジェットのコンストラクタ
  ///
  /// [spotIndex] は撮影するスポットの番号 (1 または 2)
  const TakeSnap({
    required this.spotIndex,
    super.key,
  });

  /// 撮影するスポットの番号
  final int spotIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(gameSessionControllerProvider).value;
    // spotIndexは1-indexedなので、0-indexedに変換 (spotIndex 1 -> 0, spotIndex 2 -> 1)
    final photoPath = session?.getPhotoPath(spotIndex - 1);

    return photoPath == null
        ? FloatingActionButton(
            onPressed: () => _getImage(ref),
            child: const Icon(Icons.add_a_photo),
          )
        : SizedBox(
            width: 150,
            height: 150,
            child: SetImage(picture: File(photoPath)),
          );
  }

  Future<void> _getImage(WidgetRef ref) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final controller = ref.read(gameSessionControllerProvider.notifier);
      // spotIndexは1-indexedなので、0-indexedに変換
      await controller.saveSpotPhoto(spotIndex - 1, pickedFile.path);
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
