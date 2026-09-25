import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [PhotoCompareViewer] に並べる写真
class ComparePhoto {
  /// [ComparePhoto] を作成する
  const ComparePhoto({
    required this.label,
    required this.image,
    this.isMine = false,
  });

  /// 写真の左上に出す名札 (「見本」「あなた」「発見者の名前」)
  final String label;

  /// 写真 (読めなければ null。枠だけを出す)
  final ImageProvider? image;

  /// 自分の写真か (名札をアプリの色にする)
  final bool isMine;
}

/// 見本 (上) と撮った写真 (下) を同じ大きさで並べる全画面の表示
///
/// 2 枚は 1 つの [TransformationController] を共有するので、どちらを拡大・移動しても
/// 2 枚が同じ位置・同じ倍率になる。横の位置がそろうので、向きのずれ (景色の左右のずれ) と
/// 距離のずれ (大きさの違い) をそのまま見比べられる。撮った写真がなければ見本だけを出す。
class PhotoCompareViewer extends StatefulWidget {
  /// [PhotoCompareViewer] を作成する
  const PhotoCompareViewer({
    required this.title,
    required this.caption,
    required this.reference,
    this.photo,
    super.key,
  });

  /// 見出し (スポットの名前など)
  final String title;

  /// 見出しの上の小さな文字 (「SPOT 2 / 5」など)
  final String caption;

  /// 見本
  final ComparePhoto reference;

  /// 撮った写真 (未発見のスポットでは null)
  final ComparePhoto? photo;

  /// ダブルタップで拡大する倍率
  static const doubleTapScale = 2.5;

  /// 全画面で開く
  static Future<void> open(
    BuildContext context, {
    required String title,
    required String caption,
    required ComparePhoto reference,
    ComparePhoto? photo,
  }) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder:
          (_) => PhotoCompareViewer(
            title: title,
            caption: caption,
            reference: reference,
            photo: photo,
          ),
    ),
  );

  @override
  State<PhotoCompareViewer> createState() => _PhotoCompareViewerState();
}

class _PhotoCompareViewerState extends State<PhotoCompareViewer> {
  final _transformation = TransformationController();
  Offset _doubleTapPosition = Offset.zero;

  /// 拡大していないときに、1 本指で下へ引いた量 (閉じる操作)
  double _dismissDrag = 0;
  bool _dismissing = false;

  /// これより下へ引いて離すと閉じる
  static const _dismissDistance = 120.0;
  static const _dismissVelocity = 900.0;

  @override
  void dispose() {
    _transformation.dispose();
    super.dispose();
  }

  /// 拡大していなければタップした所を中心に拡大し、拡大していれば元に戻す
  void _toggleZoom() {
    if (_transformation.value.getMaxScaleOnAxis() > 1) {
      _transformation.value = Matrix4.identity();
      return;
    }
    const scale = PhotoCompareViewer.doubleTapScale;
    final p = _doubleTapPosition;
    _transformation.value = Matrix4.diagonal3Values(scale, scale, 1)
      ..setTranslationRaw(-p.dx * (scale - 1), -p.dy * (scale - 1), 0);
  }

  bool get _isZoomed => _transformation.value.getMaxScaleOnAxis() > 1.01;

  void _onInteractionStart(ScaleStartDetails details) {
    _dismissing = details.pointerCount == 1 && !_isZoomed;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (!_dismissing) return;
    if (details.pointerCount != 1) {
      // 2 本指になったら拡大の操作なので、閉じる操作はやめる
      setState(() {
        _dismissing = false;
        _dismissDrag = 0;
      });
      return;
    }
    setState(() {
      _dismissDrag = math.max(0, _dismissDrag + details.focalPointDelta.dy);
    });
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (!_dismissing) return;
    _dismissing = false;
    if (_dismissDrag > _dismissDistance ||
        details.velocity.pixelsPerSecond.dy > _dismissVelocity) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _dismissDrag = 0);
  }

  @override
  Widget build(BuildContext context) {
    final photo = widget.photo;
    final fade = (_dismissDrag / 400).clamp(0.0, 0.6);
    // 黒い背景でもステータスバーのアイコンが見えるよう、明るい色にする
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E100E).withValues(alpha: 1 - fade),
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: widget.title, caption: widget.caption),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const gap = 8.0;
                    final count = photo == null ? 1 : 2;
                    final side = math.min(
                      constraints.maxWidth - 32,
                      (constraints.maxHeight - gap * (count - 1)) / count,
                    );
                    Widget frame(ComparePhoto p) => _Frame(
                      size: side,
                      photo: p,
                      transformation: _transformation,
                      onDoubleTapDown:
                          (d) => _doubleTapPosition = d.localPosition,
                      onDoubleTap: _toggleZoom,
                      onInteractionStart: _onInteractionStart,
                      onInteractionUpdate: _onInteractionUpdate,
                      onInteractionEnd: _onInteractionEnd,
                    );
                    return AnimatedContainer(
                      duration:
                          _dismissing
                              ? Duration.zero
                              : const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      transform: Matrix4.translationValues(0, _dismissDrag, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          frame(widget.reference),
                          if (photo != null) ...[
                            const SizedBox(height: gap),
                            frame(photo),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  photo == null
                      ? 'ダブルタップで拡大 · 下にスワイプで閉じる'
                      : 'ダブルタップで2枚とも拡大 · 下にスワイプで閉じる',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF8A9486),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: '閉じる',
            color: Colors.white,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caption,
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF9BA695),
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({
    required this.size,
    required this.photo,
    required this.transformation,
    required this.onDoubleTapDown,
    required this.onDoubleTap,
    required this.onInteractionStart,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
  });

  final double size;
  final ComparePhoto photo;
  final TransformationController transformation;
  final GestureTapDownCallback onDoubleTapDown;
  final VoidCallback onDoubleTap;
  final GestureScaleStartCallback onInteractionStart;
  final GestureScaleUpdateCallback onInteractionUpdate;
  final GestureScaleEndCallback onInteractionEnd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final image = photo.image;
    const placeholder = ColoredBox(
      color: Color(0xFF2A2F29),
      child: Center(
        child: Icon(Icons.image_not_supported_outlined, color: Colors.white54),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onDoubleTapDown: onDoubleTapDown,
              onDoubleTap: onDoubleTap,
              child: InteractiveViewer(
                transformationController: transformation,
                onInteractionStart: onInteractionStart,
                onInteractionUpdate: onInteractionUpdate,
                onInteractionEnd: onInteractionEnd,
                maxScale: 5,
                child: SizedBox.expand(
                  child:
                      image == null
                          ? placeholder
                          : Image(
                            image: image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => placeholder,
                          ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              top: 8,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color:
                        photo.isMine
                            ? colorScheme.primary.withValues(alpha: 0.9)
                            : Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 2,
                    ),
                    child: Text(
                      photo.label,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
