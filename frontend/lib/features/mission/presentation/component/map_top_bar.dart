import 'package:flutter/material.dart';
import 'package:snampo/features/mission/presentation/component/map_floating_surface.dart';

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
                  MapFloatingSurface(
                    shape: const CircleBorder(),
                    child: IconButton(
                      tooltip: '戻る',
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                const Spacer(),
                if (actions.isNotEmpty)
                  MapFloatingSurface(
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
