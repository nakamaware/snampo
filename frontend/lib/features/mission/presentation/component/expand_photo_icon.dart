import 'package:flutter/material.dart';

/// 拡大できる写真の角に出す印
class ExpandPhotoIcon extends StatelessWidget {
  /// [ExpandPhotoIcon] を作成する
  const ExpandPhotoIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          shape: BoxShape.circle,
        ),
        child: const Padding(
          padding: EdgeInsets.all(5),
          child: Icon(Icons.open_in_full, size: 14, color: Colors.white),
        ),
      ),
    );
  }
}
