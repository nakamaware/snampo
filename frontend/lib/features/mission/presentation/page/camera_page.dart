import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snampo/features/mission/application/interface/location_service.dart';
import 'package:snampo/features/mission/presentation/component/camera_shoot_layout.dart';
import 'package:snampo/features/mission/presentation/component/photo_confirm_dialog.dart';

/// カメラページの引数
class CameraPageArgs {
  /// CameraPageArgsのコンストラクタ
  const CameraPageArgs({
    required this.title,
    required this.referenceImageBase64,
    required this.onPhotoAccepted,
    this.loadingMessage = '採点中...',
  });

  /// 上に出すタイトル (例: Spot 2)
  final String title;

  /// 正解画像の base64 文字列
  final String referenceImageBase64;

  /// 画像確定後の処理。撮影時のズームレベルを合わせて渡す
  ///
  /// 完了するまでローディングを表示する。撮影を受け付けられなければ
  /// [PhotoRejectedException] を投げる (理由をそのまま表示する)。
  final Future<bool> Function(XFile file, double zoomLevel) onPhotoAccepted;

  /// [onPhotoAccepted] の完了を待つ間に表示する文言
  final String loadingMessage;
}

/// 撮影を受け付けられなかった ([message] を利用者にそのまま表示する)
class PhotoRejectedException implements Exception {
  /// [PhotoRejectedException] を作成する
  const PhotoRejectedException(this.message);

  /// 利用者に表示する理由
  final String message;

  @override
  String toString() => 'PhotoRejectedException($message)';
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
  late final _referenceImage = MemoryImage(
    base64Decode(widget.args.referenceImageBase64),
  );
  CameraController? _controller;
  bool _isInitialized = false;
  double _minZoomLevel = 1;
  double _maxZoomLevel = 1;
  double _currentZoomLevel = 1;
  double _baseZoomLevel = 1;
  int _activePointers = 0;
  bool _isSettingZoomLevel = false;
  double? _queuedZoomLevel;
  bool _isCapturing = false;

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
    final controller = _controller;
    final isReady = _isInitialized && controller != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: CameraShootLayout(
            title: widget.args.title,
            referenceImage: _referenceImage,
            viewfinder:
                isReady
                    ? _buildPreview(controller)
                    : const Center(child: CircularProgressIndicator()),
            controls: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isReady)
                  _ZoomChips(
                    minZoomLevel: _minZoomLevel,
                    maxZoomLevel: _maxZoomLevel,
                    currentZoomLevel: _currentZoomLevel,
                    onSelected: (value) {
                      setState(() => _currentZoomLevel = value);
                      _baseZoomLevel = value;
                      _setZoomLevel(value);
                    },
                  ),
                const SizedBox(height: 16),
                _ShutterButton(
                  onPressed:
                      isReady && !_isCapturing ? _onShutterPressed : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ピンチでズームできる、正方形に切り取ったプレビュー
  Widget _buildPreview(CameraController controller) {
    return Listener(
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
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: 1,
                height: controller.value.aspectRatio,
                child: CameraPreview(controller),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Text(
                    '${_currentZoomLevel.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onShutterPressed() async {
    setState(() => _isCapturing = true);
    try {
      await _handleCapture(context);
    } on PhotoRejectedException catch (e) {
      if (!mounted) return;
      await _showErrorDialog(e.message);
    } on LocationUnavailableException {
      if (!mounted) return;
      await _showErrorDialog(
        '現在地を取得できなかったため、採点できませんでした。'
        '端末の位置情報をオンにして、もう一度撮影してください。',
      );
    } catch (e) {
      if (!mounted) return;
      await _showErrorDialog('写真の撮影に失敗しました。');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<XFile> _cropToSquare(XFile original) async {
    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return original;

    final srcW = decoded.width;
    final srcH = decoded.height;

    final int cropSize;
    final int cropX;
    final int cropY;

    if (srcW > srcH) {
      cropSize = srcH;
      cropX = (srcW - cropSize) ~/ 2;
      cropY = 0;
    } else {
      cropSize = srcW;
      cropX = 0;
      cropY = (srcH - cropSize) ~/ 2;
    }

    final cropW = cropSize;
    final cropH = cropSize;

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
    final file = await _cropToSquare(rawFile);
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
                        Text(
                          widget.args.loadingMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        ),
      );

      final isAccepted = await widget.args.onPhotoAccepted(
        file,
        _currentZoomLevel,
      );

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

/// ズームの倍率を選ぶボタン (1x・2x・4x のうち、カメラが対応するもの)
///
/// 2x に届かないカメラでは、1x と最大の倍率を出す。
/// ピンチで間の倍率にもできる。そのときはどのボタンも選ばない。
class _ZoomChips extends StatelessWidget {
  const _ZoomChips({
    required this.minZoomLevel,
    required this.maxZoomLevel,
    required this.currentZoomLevel,
    required this.onSelected,
  });

  final double minZoomLevel;
  final double maxZoomLevel;
  final double currentZoomLevel;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final levels = [
      for (final level in const [1.0, 2.0, 4.0])
        if (level >= minZoomLevel && level <= maxZoomLevel) level,
    ];
    if (levels.length == 1 && maxZoomLevel >= 1.2) levels.add(maxZoomLevel);
    if (levels.length < 2) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final level in levels)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _ZoomChip(
              label: '${_formatZoomLevel(level)}x',
              isSelected: (currentZoomLevel - level).abs() < 0.05,
              onPressed: () => onSelected(level),
            ),
          ),
      ],
    );
  }
}

/// 整数ならそのまま (2)、そうでなければ小数 1 桁 (1.5)
String _formatZoomLevel(double level) =>
    level == level.roundToDouble()
        ? level.toStringAsFixed(0)
        : level.toStringAsFixed(1);

class _ZoomChip extends StatelessWidget {
  const _ZoomChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: isSelected,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          minimumSize: const Size.square(40),
          fixedSize: const Size.square(40),
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
          backgroundColor: isSelected ? Colors.white : Colors.white12,
          foregroundColor: isSelected ? Colors.black : Colors.white,
          textStyle: Theme.of(context).textTheme.labelMedium,
        ),
        child: Text(label),
      ),
    );
  }
}

/// 白い丸のシャッターボタン
class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return Semantics(
      button: true,
      enabled: isEnabled,
      label: '撮影',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 76,
          height: 76,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isEnabled ? Colors.white : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }
}
