import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snampo/features/mission/domain/entity/photo_judge_rank.dart';

/// 見本の向き (真上の点線) と撮った向き (針) を、左右 90 度の半円で見せる
///
/// 90 度を超えてずれると Miss になるので、そのときは針を端で止めて [missColor] にする。
class HeadingDial extends StatelessWidget {
  /// [HeadingDial] を作成する
  const HeadingDial({
    required this.headingErrorDegrees,
    required this.color,
    required this.missColor,
    this.width = 150,
    super.key,
  });

  /// 向きのずれ (度。正なら右、負なら左)
  final double headingErrorDegrees;

  /// 針の色
  final Color color;

  /// 90 度を超えたときの針の色
  final Color missColor;

  /// 幅 (高さは幅から決まる)
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.labelSmall?.copyWith(
      fontSize: 10,
      color: theme.colorScheme.outline,
    );
    final radius = width / 2 - 17;
    final isOver = headingErrorDegrees.abs() > photoJudgeHeadingLimitDegrees;
    return SizedBox(
      width: width,
      height: radius + 32,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _DialPainter(
                degrees: headingErrorDegrees.clamp(
                  -photoJudgeHeadingLimitDegrees,
                  photoJudgeHeadingLimitDegrees,
                ),
                radius: radius,
                needleColor: isOver ? missColor : color,
                trackColor: theme.colorScheme.surfaceContainerHighest,
                tickColor: theme.colorScheme.outlineVariant,
                referenceColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            width: 34,
            child: Text('左90°', textAlign: TextAlign.center, style: labelStyle),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            width: 34,
            child: Text('右90°', textAlign: TextAlign.center, style: labelStyle),
          ),
        ],
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.degrees,
    required this.radius,
    required this.needleColor,
    required this.trackColor,
    required this.tickColor,
    required this.referenceColor,
  });

  final double degrees;
  final double radius;
  final Color needleColor;
  final Color trackColor;
  final Color tickColor;
  final Color referenceColor;

  /// 真上を 0 度とし、時計回りを正とした角度の点
  Offset _point(Offset center, double deg, double r) {
    final rad = deg * math.pi / 180;
    return center + Offset(math.sin(rad) * r, -math.cos(rad) * r);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, radius + 10);
    final rect = Rect.fromCircle(center: center, radius: radius);
    // 真上を 0 度とする角度を、Canvas の角度 (右を 0、時計回り) に直す
    double toCanvas(double deg) => (deg - 90) * math.pi / 180;

    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    if (degrees.abs() >= 1) {
      canvas.drawArc(
        rect,
        toCanvas(math.min(0, degrees)),
        degrees.abs() * math.pi / 180,
        false,
        Paint()
          ..color = needleColor.withValues(alpha: 0.28)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 12,
      );
    }
    final tick =
        Paint()
          ..color = tickColor
          ..strokeWidth = 1.2;
    for (var deg = -90.0; deg <= 90; deg += 30) {
      canvas.drawLine(
        _point(center, deg, radius + 7),
        _point(center, deg, radius + (deg % 90 == 0 ? 1 : 3)),
        tick,
      );
    }
    // 見本の向き (点線)
    final reference =
        Paint()
          ..color = referenceColor
          ..strokeWidth = 1.5;
    const dash = 3.0;
    for (var d = 0.0; d < radius + 6; d += dash * 2) {
      canvas.drawLine(
        center.translate(0, -d),
        center.translate(0, -math.min(d + dash, radius + 6)),
        reference,
      );
    }
    // 撮った向き (針)
    canvas
      ..drawLine(
        center,
        _point(center, degrees, radius - 4),
        Paint()
          ..color = needleColor
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round,
      )
      ..drawCircle(center, 5.5, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(_DialPainter old) =>
      old.degrees != degrees ||
      old.radius != radius ||
      old.needleColor != needleColor ||
      old.trackColor != trackColor;
}
