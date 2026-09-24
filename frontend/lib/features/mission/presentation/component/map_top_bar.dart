import 'package:flutter/material.dart';

/// 地図の上に浮かべる、戻るボタンとモードのボタン (AppBar の代わり)
///
/// 地図を画面いっぱいに見せるため、タイトルは出さない。`Stack` の子として置く。
class MapTopBar extends StatelessWidget {
  /// [MapTopBar] を作成する
  const MapTopBar({this.actions = const [], super.key});

  /// 右上に並べるボタン (協力プレイのメニューなど)
  final List<Widget> actions;

  /// ボタンを置く帯の高さ (地図の余白を決めるのに使う)
  static const height = 64.0;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.impliesAppBarDismissal ?? false;
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (canPop)
                  _FloatingSurface(
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: '戻る',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                const Spacer(),
                if (actions.isNotEmpty)
                  _FloatingSurface(
                    shape: const StadiumBorder(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: actions,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 地図の上で読みやすいよう、背景と影をつけた土台
class _FloatingSurface extends StatelessWidget {
  const _FloatingSurface({required this.shape, required this.child});

  final ShapeBorder shape;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerLow,
      shape: shape,
      elevation: 3,
      shadowColor: Colors.black,
      clipBehavior: Clip.antiAlias,
      child: IconTheme.merge(
        data: IconThemeData(color: colorScheme.onSurface),
        child: child,
      ),
    );
  }
}
