import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/hook/use_current_position.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('SETUP', style: textstyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [Tab(text: 'ランダム'), Tab(text: '目的地指定')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        // TODO: SliderWidgetとDestinationPickerWidgetをそれぞれ別ファイルに分離する
        children: const [SliderWidget(), DestinationPickerWidget()],
      ),
    );
  }
}

/// 半径を設定するためのスライダーウィジェット。
class SliderWidget extends StatefulWidget {
  /// [SliderWidget] ウィジェットを作成します。
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  Radius slidervalue = Radius(meters: 500); // Radius値オブジェクトを使用

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(slidervalue.meters / 1000).toStringAsFixed(1)} km',
            style: textstyle,
          ),
          Slider(
            value: slidervalue.meters.toDouble(),
            min: 500,
            max: 10000,
            divisions: 19,
            onChanged: (radius) {
              setState(() {
                slidervalue = Radius(meters: radius.toInt());
              });
            },
          ),
          const SizedBox(height: 20),
          SubmitButton(radius: slidervalue),
        ],
      ),
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
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, // ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
        // shape: RoundedRectangleBorder( // 形を変えるか否か
        //   borderRadius: BorderRadius.circular(10), // 角の丸み
        // ),
      ),
      onPressed: () {
        context.push('/mission/${widget.radius.meters}');
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text('GO', style: style),
      ),
    );
  }
}

/// 目的地を地図上で選択するウィジェット
class DestinationPickerWidget extends HookConsumerWidget {
  /// [DestinationPickerWidget] ウィジェットを作成します。
  const DestinationPickerWidget({super.key});

  /// デフォルト位置 (東京駅)
  static const LatLng _defaultPosition = LatLng(35.6812, 139.7671);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = useCurrentPosition(ref);
    final selectedDestination = useState<LatLng?>(null);
    final markers = useState<Set<Marker>>({});

    void updateMarker(LatLng position) {
      selectedDestination.value = position;
      markers.value = {
        Marker(markerId: const MarkerId('destination'), position: position),
      };
    }

    return currentPosition.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (_, __) => _buildMapContent(
            context,
            _defaultPosition,
            markers.value,
            selectedDestination.value,
            updateMarker,
          ),
      data:
          (coord) => _buildMapContent(
            context,
            LatLng(coord.latitude, coord.longitude),
            markers.value,
            selectedDestination.value,
            updateMarker,
          ),
    );
  }

  Widget _buildMapContent(
    BuildContext context,
    LatLng initialPosition,
    Set<Marker> markers,
    LatLng? selectedDestination,
    void Function(LatLng) updateMarker,
  ) {
    final theme = Theme.of(context);
    final smallTextStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: initialPosition,
            zoom: 14,
          ),
          onTap: updateMarker,
          markers: markers,
          myLocationEnabled: true, // 現在位置を表示
          tiltGesturesEnabled: false, // 傾きの変更を禁止
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.3),
              ),
              onPressed:
                  selectedDestination != null
                      ? () {
                        context.push(
                          '/mission/destination/${selectedDestination.latitude}/${selectedDestination.longitude}',
                        );
                      }
                      : null,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('GO', style: smallTextStyle),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
