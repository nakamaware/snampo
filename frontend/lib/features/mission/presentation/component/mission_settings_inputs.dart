import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/mission/presentation/hook/use_current_position.dart';

/// ミッションの設定の入力部品 (Setup 画面と、協力プレイのロビーで使う)

/// 半径 (ランダムモード) を選ぶスライダー
///
/// [onChanged] が null なら閲覧のみ。
class RadiusSlider extends StatelessWidget {
  /// [RadiusSlider] を作成する
  const RadiusSlider({
    required this.radius,
    this.onChanged,
    this.onChangeEnd,
    this.textStyle,
    super.key,
  });

  /// 選んでいる半径
  final Radius radius;

  /// スライダーを動かしている間に呼ぶ
  final ValueChanged<Radius>? onChanged;

  /// スライダーを離したときに呼ぶ
  final ValueChanged<Radius>? onChangeEnd;

  /// 半径の表示のスタイル
  final TextStyle? textStyle;

  static const _min = 500;
  static const _max = 10000;
  static const _step = 500;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final onChangeEnd = this.onChangeEnd;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${(radius.meters / 1000).toStringAsFixed(1)} km',
          style: textStyle,
        ),
        Slider(
          value: radius.meters.toDouble(),
          min: _min.toDouble(),
          max: _max.toDouble(),
          divisions: (_max - _min) ~/ _step,
          onChanged:
              onChanged == null
                  ? null
                  : (v) => onChanged(Radius(meters: v.toInt())),
          onChangeEnd:
              onChangeEnd == null
                  ? null
                  : (v) => onChangeEnd(Radius(meters: v.toInt())),
        ),
      ],
    );
  }
}

/// 目的地 (目的地指定モード) を地図で選ぶ
///
/// 選んだ目的地にピンを表示する。[onPick] が null なら閲覧のみ。
class DestinationMap extends HookConsumerWidget {
  /// [DestinationMap] を作成する
  const DestinationMap({
    required this.destination,
    this.onPick,
    this.insideScrollable = false,
    super.key,
  });

  /// 選んでいる目的地
  final Coordinate? destination;

  /// 地図をタップして目的地を選んだときに呼ぶ
  final ValueChanged<Coordinate>? onPick;

  /// スクロールする画面の中に置くか (true なら地図の操作を優先する)
  final bool insideScrollable;

  /// デフォルト位置 (東京駅)
  static const _defaultPosition = LatLng(35.6812, 139.7671);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = useCurrentPosition(ref);
    final pin = destination;
    if (pin == null && currentPosition.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final initial =
        pin != null
            ? LatLng(pin.latitude, pin.longitude)
            : currentPosition.whenOrNull(
                  data: (c) => LatLng(c.latitude, c.longitude),
                ) ??
                _defaultPosition;
    final onPick = this.onPick;

    return RepaintBoundary(
      child: GoogleMap(
        key: ValueKey('map_${initial.latitude}_${initial.longitude}'),
        initialCameraPosition: CameraPosition(target: initial, zoom: 14),
        onTap:
            onPick == null
                ? null
                : (latLng) => onPick(
                  Coordinate(
                    latitude: latLng.latitude,
                    longitude: latLng.longitude,
                  ),
                ),
        markers: {
          if (pin != null)
            Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(pin.latitude, pin.longitude),
            ),
        },
        myLocationEnabled: true, // 現在位置を表示
        tiltGesturesEnabled: false, // 傾きの変更を禁止
        gestureRecognizers:
            insideScrollable
                ? const {
                  Factory<OneSequenceGestureRecognizer>(
                    EagerGestureRecognizer.new,
                  ),
                }
                : const {},
      ),
    );
  }
}
