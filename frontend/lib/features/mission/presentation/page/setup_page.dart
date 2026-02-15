import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snampo/features/mission/di/mission_provider.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';

/// ミッションパラメータを設定するためのセットアップページウィジェット。
class SetupPage extends StatefulWidget {
  /// [SetupPage] ウィジェットを作成します。
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _currentIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: 'ランダム'), Tab(text: '目的地指定')],
            ),
          ),
          Expanded(
            // TabBarView を使わず IndexedStack も使わず、
            // アクティブなタブだけをツリーに乗せることで
            // GoogleMap を同時に2つ保持しないようにする
            child:
                _currentIndex == 0
                    ? const SliderWidget(key: ValueKey(0))
                    : const DestinationPickerWidget(key: ValueKey(1)),
          ),
        ],
      ),
    );
  }
}

/// 半径を設定するためのスライダーウィジェット。
class SliderWidget extends ConsumerStatefulWidget {
  /// [SliderWidget] ウィジェットを作成します。
  const SliderWidget({super.key});

  @override
  ConsumerState<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends ConsumerState<SliderWidget> {
  Radius _radius = Radius(meters: 500);
  LatLng _center = const LatLng(35.6812, 139.7671);
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(currentPositionProvider, (_, next) {
      if (next.hasValue) {
        final pos = next.value!;
        final latLng = LatLng(pos.latitude, pos.longitude);
        setState(() => _center = latLng);
        _mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      }
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('散歩の範囲', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    (_radius.meters / 1000).toStringAsFixed(1),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'km',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _radius.meters.toDouble(),
                min: 500,
                max: 10000,
                divisions: 19,
                onChanged: (value) {
                  setState(() => _radius = Radius(meters: value.toInt()));
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 13),
            onMapCreated: (controller) => _mapController = controller,
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: _center,
                radius: _radius.meters.toDouble(),
                fillColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                strokeColor: theme.colorScheme.primary,
                strokeWidth: 2,
              ),
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            tiltGesturesEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: SubmitButton(radius: _radius),
        ),
      ],
    );
  }
}

/// ミッションを開始するための送信ボタンウィジェット。
class SubmitButton extends StatefulWidget {
  /// [SubmitButton] ウィジェットを作成します。
  ///
  /// [radius] はミッションの検索半径です。
  const SubmitButton({required this.radius, super.key});

  /// ミッションの検索半径。
  final Radius radius;

  @override
  State<SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: const StadiumBorder(),
        ),
        onPressed: () => context.push('/mission/${widget.radius.meters}'),
        child: Text(
          'はじめる',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

/// 目的地を地図上で選択するウィジェット
class DestinationPickerWidget extends ConsumerStatefulWidget {
  /// [DestinationPickerWidget] ウィジェットを作成します。
  const DestinationPickerWidget({super.key});

  @override
  ConsumerState<DestinationPickerWidget> createState() =>
      _DestinationPickerWidgetState();
}

class _DestinationPickerWidgetState
    extends ConsumerState<DestinationPickerWidget> {
  LatLng? _selectedDestination;
  Set<Marker> _markers = {};

  /// デフォルト位置 (東京駅)
  static const LatLng _defaultPosition = LatLng(35.6812, 139.7671);

  void _updateMarker(LatLng position) {
    _selectedDestination = position;
    _markers = {
      Marker(markerId: const MarkerId('destination'), position: position),
    };
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentPosition = ref.watch(currentPositionProvider);

    return currentPosition.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => _buildMapContent(_defaultPosition),
      data:
          (coord) => _buildMapContent(LatLng(coord.latitude, coord.longitude)),
    );
  }

  Widget _buildMapContent(LatLng initialPosition) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 14,
          ),
          onTap: _updateMarker,
          markers: _markers,
          myLocationEnabled: true, // 現在位置を表示
          tiltGesturesEnabled: false, // 傾きの変更を禁止
        ),
        Positioned(
          bottom: 24,
          left: 24,
          right: 24,
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const StadiumBorder(),
              elevation: 4,
            ),
            onPressed:
                _selectedDestination != null
                    ? () {
                      context.push(
                        '/mission/destination/${_selectedDestination!.latitude}/${_selectedDestination!.longitude}',
                      );
                    }
                    : null,
            child: Text(
              'はじめる',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
