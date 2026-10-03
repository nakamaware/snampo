import 'package:flutter/material.dart';

/// 地図の上で読みやすいよう、背景と影をつけた土台
///
/// 地図に浮かべるボタン (戻る・現在地など) の見た目をそろえるのに使う。
class MapFloatingSurface extends StatelessWidget {
  /// [MapFloatingSurface] を作成する
  const MapFloatingSurface({
    required this.shape,
    required this.child,
    super.key,
  });

  /// 土台の形
  final ShapeBorder shape;

  /// 土台に載せる中身
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
