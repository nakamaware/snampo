import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/mission/presentation/dialog/photo_confirm_dialog.dart';

/// カメラページの引数
class CameraPageArgs {
  /// CameraPageArgsのコンストラクタ
  const CameraPageArgs({
    required this.referenceImageBase64,
    required this.onPhotoAccepted,
  });

  /// 正解画像の base64 文字列
  final String referenceImageBase64;

  /// 画像確定後の処理
  final Future<bool> Function(XFile file) onPhotoAccepted;
}

/// カメラページウィジェット。
class CameraPage extends StatefulWidget {
  /// [CameraPage] ウィジェットを作成します。
  const CameraPage({required this.args, super.key});

  /// カメラページの引数
  final CameraPageArgs args;

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;
  double _minZoomLevel = 1;
  double _maxZoomLevel = 1;
  double _currentZoomLevel = 1;
  double _baseZoomLevel = 1;
  int _activePointers = 0;
  bool _isSettingZoomLevel = false;
  double? _queuedZoomLevel;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  // エラーを表示する共通メソッド
  Future<void> _showErrorDialog(String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // 枠外をタップしても閉じないようにする
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラー'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('戻る'),
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
                Navigator.of(context).pop(); // カメラ画面も閉じる
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) {
        await _showErrorDialog('カメラが見つかりませんでした。');
        return;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false, // 音声録音をしない
      );

      await controller.initialize();
      final minZoomLevel = await controller.getMinZoomLevel();
      final maxZoomLevel = await controller.getMaxZoomLevel();
      final initialZoomLevel = 1.0.clamp(minZoomLevel, maxZoomLevel).toDouble();
      await controller.setZoomLevel(initialZoomLevel);

      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isInitialized = true;
        _minZoomLevel = minZoomLevel;
        _maxZoomLevel = maxZoomLevel;
        _currentZoomLevel = initialZoomLevel;
        _baseZoomLevel = initialZoomLevel;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      var message = 'カメラの起動に失敗しました。';
      if (e.code == 'CameraAccessDenied') {
        message = 'カメラへのアクセスが拒否されています。設定から許可してください。';
      }
      await _showErrorDialog(message);
    } catch (e) {
      if (!mounted) return;
      // その他の予期せぬエラー
      await _showErrorDialog('予期せぬエラーが発生しました: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    if (_activePointers < 2) {
      return;
    }

    final targetZoomLevel = (_baseZoomLevel * details.scale).clamp(
      _minZoomLevel,
      _maxZoomLevel,
    );
    await _setZoomLevel(targetZoomLevel.toDouble());
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _baseZoomLevel = _currentZoomLevel;
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers++;
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointers > 0) {
      _activePointers--;
    }
    if (_activePointers < 2) {
      _baseZoomLevel = _currentZoomLevel;
    }
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointers > 0) {
      _activePointers--;
    }
    if (_activePointers < 2) {
      _baseZoomLevel = _currentZoomLevel;
    }
  }

  Future<void> _setZoomLevel(double zoomLevel) async {
    final controller = _controller;
    if (controller == null || !_isInitialized) {
      return;
    }

    if (_isSettingZoomLevel) {
      _queuedZoomLevel = zoomLevel;
      return;
    }

    _isSettingZoomLevel = true;
    var nextZoomLevel = zoomLevel;

    while (true) {
      try {
        await controller.setZoomLevel(nextZoomLevel);
      } on CameraException {
        break;
      }

      if (!mounted) {
        _isSettingZoomLevel = false;
        return;
      }

      final hasChanged = (_currentZoomLevel - nextZoomLevel).abs() > 0.001;
      if (hasChanged) {
        setState(() {
          _currentZoomLevel = nextZoomLevel;
        });
      }

      final queuedZoomLevel = _queuedZoomLevel;
      _queuedZoomLevel = null;
      if (queuedZoomLevel == null) {
        break;
      }
      nextZoomLevel = queuedZoomLevel;
    }

    _isSettingZoomLevel = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final theme = Theme.of(context);
    final textStyle = (theme.textTheme.displaySmall ??
            theme.textTheme.headlineMedium ??
            const TextStyle())
        .copyWith(color: theme.colorScheme.onPrimary);
    // FAB (56dp) + FAB margin (16dp) + safe area + gap (16dp)
    final sliderBottom = MediaQuery.paddingOf(context).bottom + 56 + 16 + 16;

    return Scaffold(
      appBar: AppBar(
        title: Text('Take SNAP', style: textStyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Listener(
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          child: Stack(
            fit: StackFit.expand,
            children: [
              const ColoredBox(color: Colors.black),
              // カメラプレビューを 16:9 に制限して表示
              Center(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRect(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 1,
                        height: _controller!.value.aspectRatio,
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text(
                      '${_currentZoomLevel.toStringAsFixed(1)}x',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: sliderBottom,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.zoom_out,
                        color: Colors.white70,
                        size: 20,
                      ),
                      Expanded(
                        child: Slider(
                          value: _currentZoomLevel.clamp(
                            _minZoomLevel,
                            _maxZoomLevel,
                          ),
                          min: _minZoomLevel,
                          max: _maxZoomLevel,
                          onChanged: (value) {
                            setState(() => _currentZoomLevel = value);
                            _setZoomLevel(value);
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white38,
                        ),
                      ),
                      const Icon(
                        Icons.zoom_in,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _handleCapture(context);
          } catch (e) {
            if (!context.mounted) return;
            await _showErrorDialog('写真の撮影に失敗しました。');
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
      // 撮影ボタンの位置を中央に設定
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Future<XFile> _cropTo16x9(XFile original) async {
    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return original;

    final srcW = decoded.width;
    final srcH = decoded.height;
    const targetRatio = 16.0 / 9.0;
    final srcRatio = srcW / srcH;

    final int cropW;
    final int cropH;
    final int cropX;
    final int cropY;

    if (srcRatio > targetRatio) {
      cropH = srcH;
      cropW = (srcH * targetRatio).round().clamp(1, srcW);
      cropX = (srcW - cropW) ~/ 2;
      cropY = 0;
    } else {
      cropW = srcW;
      cropH = (srcW / targetRatio).round().clamp(1, srcH);
      cropX = 0;
      cropY = (srcH - cropH) ~/ 2;
    }

    final cropped = img.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: cropW,
      height: cropH,
    );
    final jpegBytes = img.encodeJpg(cropped, quality: 90);

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/snap_${DateTime.now().millisecondsSinceEpoch}.jpg';
    await File(path).writeAsBytes(jpegBytes);

    return XFile(path);
  }

  Future<void> _handleCapture(BuildContext context) async {
    final rawFile = await _controller!.takePicture();
    final file = await _cropTo16x9(rawFile);
    if (!context.mounted) {
      return;
    }

    await _controller!.pausePreview();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => PhotoConfirmDialog(
            args: PhotoConfirmDialogArgs(
              referenceImageBase64: widget.args.referenceImageBase64,
              capturedPhotoPath: file.path,
            ),
          ),
    );
    if (confirmed != true || !context.mounted) {
      await _controller!.resumePreview();
      return;
    }

    final rootNavigator = Navigator.of(context, rootNavigator: true);
    var loadingVisible = false;
    var shouldResumePreview = true;

    try {
      loadingVisible = true;
      unawaited(
        showGeneralDialog<void>(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.black,
          pageBuilder:
              (_, __, ___) => PopScope(
                canPop: false,
                child: Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LoadingAnimationWidget.staggeredDotsWave(
                          color: Colors.blue,
                          size: 100,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '採点中...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      );

      final isAccepted = await widget.args.onPhotoAccepted(file);

      if (rootNavigator.mounted) {
        rootNavigator.pop();
        loadingVisible = false;
      }

      if (!isAccepted) {
        return;
      }

      shouldResumePreview = false;
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (loadingVisible && rootNavigator.mounted) {
        rootNavigator.pop();
      }
      if (shouldResumePreview && mounted) {
        await _controller!.resumePreview();
      }
    }
  }
}
