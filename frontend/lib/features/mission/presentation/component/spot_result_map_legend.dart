import 'package:flutter/material.dart';

/// スポット結果の地図の凡例 (ピンと丸の色の意味)
class SpotResultMapLegend extends StatelessWidget {
  /// [SpotResultMapLegend] を作成する
  const SpotResultMapLegend({required this.hasStreetView, super.key});

  /// 見本を撮った場所 (黄色のピン) があるか
  final bool hasStreetView;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    Widget item(Color color, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 9, color: color),
        const SizedBox(width: 3),
        Text(label, style: style),
      ],
    );
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          child: Wrap(
            spacing: 10,
            children: [
              item(const Color(0xFFD93025), 'スポット'),
              if (hasStreetView) item(const Color(0xFFE8B400), '見本の場所'),
              item(Theme.of(context).colorScheme.primary, '撮った場所'),
            ],
          ),
        ),
      ),
    );
  }
}
