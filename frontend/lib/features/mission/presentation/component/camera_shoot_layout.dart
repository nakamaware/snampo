import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 撮影画面の並べ方。上から、戻るとタイトル、見本、正方形のファインダー、操作
///
/// 見本とファインダーを同時に見比べられるよう、見本はファインダーの上に出す。
/// 画面が低く、見本を [minReferenceSize] より大きく出せないときは、
/// ファインダーの左下に小さく重ねる。見本はタップで大きく見られる。
class CameraShootLayout extends StatefulWidget {
  /// [CameraShootLayout] を作成する
  const CameraShootLayout({
    required this.title,
    required this.referenceImage,
    required this.viewfinder,
    required this.controls,
    this.onBack,
    super.key,
  });

  /// 見本を上に出すのに必要な、見本の最小の一辺
  static const minReferenceSize = 96.0;

  /// 操作 ([controls]) のために最低限あける高さ
  static const minControlsHeight = 168.0;

  static const _topBarHeight = 56.0;
  static const _referenceGap = 12.0;

  /// 上に出すタイトル (例: Spot 2)
  final String title;

  /// 見本 (正解画像)
  final ImageProvider referenceImage;

  /// 正方形の枠に入れるもの (カメラのプレビューや撮った写真)
  final Widget viewfinder;

  /// ファインダーの下の操作
  final Widget controls;

  /// 左上の戻るボタンを押したとき。null なら前の画面へ戻る
  final VoidCallback? onBack;

  @override
  State<CameraShootLayout> createState() => _CameraShootLayoutState();
}

class _CameraShootLayoutState extends State<CameraShootLayout> {
  bool _isReferenceEnlarged = false;

  void _setEnlarged(bool value) {
    setState(() => _isReferenceEnlarged = value);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final viewfinderSize = (height -
                CameraShootLayout._topBarHeight -
                CameraShootLayout.minControlsHeight)
            .clamp(0.0, width);
        final referenceSize = math.min(
          height -
              CameraShootLayout._topBarHeight -
              viewfinderSize -
              CameraShootLayout.minControlsHeight -
              CameraShootLayout._referenceGap,
          width * 0.42,
        );
        final showsReferenceAbove =
            referenceSize >= CameraShootLayout.minReferenceSize;

        return Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: CameraShootLayout._topBarHeight,
                  child: _TopBar(title: widget.title, onBack: widget.onBack),
                ),
                if (showsReferenceAbove)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: CameraShootLayout._referenceGap,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: referenceSize,
                          child: _ReferenceTile(
                            image: widget.referenceImage,
                            onTap: () => _setEnlarged(true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: width * 0.34,
                          child: const _ReferenceHint(),
                        ),
                      ],
                    ),
                  ),
                SizedBox.square(
                  dimension: viewfinderSize,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRect(child: widget.viewfinder),
                      if (!showsReferenceAbove)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          width: viewfinderSize * 0.3,
                          height: viewfinderSize * 0.3,
                          child: _ReferenceTile(
                            image: widget.referenceImage,
                            onTap: () => _setEnlarged(true),
                            isOverlay: true,
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(child: Center(child: widget.controls)),
              ],
            ),
            if (_isReferenceEnlarged)
              Positioned.fill(
                child: _EnlargedReference(
                  image: widget.referenceImage,
                  size: math.min(width, height - 64),
                  onClose: () => _setEnlarged(false),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 8),
        IconButton(
          tooltip: '戻る',
          style: IconButton.styleFrom(
            backgroundColor: Colors.white12,
            foregroundColor: Colors.white,
          ),
          onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.white),
          ),
        ),
        // タイトルを中央に置くため、戻るボタンと同じ幅をあける
        const SizedBox(width: 56),
      ],
    );
  }
}

class _ReferenceTile extends StatelessWidget {
  const _ReferenceTile({
    required this.image,
    required this.onTap,
    this.isOverlay = false,
  });

  final ImageProvider image;
  final VoidCallback onTap;

  /// ファインダーの上に重ねるとき (景色と区別できるよう白い縁をつける)
  final bool isOverlay;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '見本を拡大',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverlay ? Colors.white : Colors.white38,
              width: isOverlay ? 2 : 1,
            ),
            boxShadow:
                isOverlay
                    ? const [BoxShadow(color: Colors.black54, blurRadius: 8)]
                    : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image(
                  image: image,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                  errorBuilder:
                      (_, __, ___) => const ColoredBox(color: Colors.white12),
                ),
                const Positioned(
                  left: 6,
                  top: 6,
                  child: CameraImageLabel(label: '見本'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReferenceHint extends StatelessWidget {
  const _ReferenceHint();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('見本と同じ場所・向きで撮ってください', style: style?.copyWith(color: Colors.white)),
        const SizedBox(height: 4),
        Text('タップで拡大', style: style?.copyWith(color: Colors.white60)),
      ],
    );
  }
}

class _EnlargedReference extends StatelessWidget {
  const _EnlargedReference({
    required this.image,
    required this.size,
    required this.onClose,
  });

  final ImageProvider image;
  final double size;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '見本を閉じる',
      child: GestureDetector(
        onTap: onClose,
        child: ColoredBox(
          color: Colors.black.withValues(alpha: 0.92),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: size,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image(image: image, fit: BoxFit.cover),
                    const Positioned(
                      left: 8,
                      top: 8,
                      child: CameraImageLabel(label: '見本'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'タップで閉じる',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 写真の左上に出す、何の写真かを示すラベル (例: 見本)
class CameraImageLabel extends StatelessWidget {
  /// [CameraImageLabel] を作成する
  const CameraImageLabel({required this.label, super.key});

  /// 表示する文言
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
