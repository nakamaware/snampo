import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';
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
  final _nickname = TextEditingController();
  var _coop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nickname.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nickname.dispose();
    super.dispose();
  }

  Nickname? get _hostNickname {
    if (!_coop) {
      return null;
    }
    if (!Nickname.canCreate(_nickname.text)) {
      return null;
    }
    return Nickname(_nickname.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('SETUP', style: textStyle),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: const [Tab(text: 'ランダム'), Tab(text: '目的地指定')],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('ソロ')),
                ButtonSegment(value: true, label: Text('協力')),
              ],
              selected: {_coop},
              onSelectionChanged: (value) {
                setState(() => _coop = value.first);
              },
            ),
          ),
          if (_coop)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _nickname,
                decoration: const InputDecoration(labelText: 'ニックネーム'),
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SliderWidget(hostNickname: _hostNickname, coop: _coop),
                DestinationPickerWidget(
                  hostNickname: _hostNickname,
                  coop: _coop,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 半径を設定するためのスライダーウィジェット。
class SliderWidget extends StatefulWidget {
  /// [SliderWidget] ウィジェットを作成します。
  const SliderWidget({required this.coop, this.hostNickname, super.key});

  /// 協力モードか。
  final bool coop;

  /// 協力のとき、有効なニックネーム。
  final Nickname? hostNickname;

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  Radius slidervalue = Radius(meters: 500); // Radius値オブジェクトを使用

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${(slidervalue.meters / 1000).toStringAsFixed(1)} km',
            style: textStyle,
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
          SubmitButton(
            radius: slidervalue,
            coop: widget.coop,
            hostNickname: widget.hostNickname,
          ),
        ],
      ),
    );
  }
}

/// ミッションを開始するための送信ボタンウィジェット。
class SubmitButton extends ConsumerWidget {
  /// [SubmitButton] ウィジェットを作成します。
  ///
  /// [radius] はミッションの検索半径です。
  const SubmitButton({
    required this.radius,
    required this.coop,
    this.hostNickname,
    super.key,
  });

  /// ミッションの検索半径。
  final Radius radius;

  /// 協力モードか。
  final bool coop;

  /// 協力のとき、有効なニックネーム。
  final Nickname? hostNickname;

  void _start(BuildContext context, WidgetRef ref) {
    if (coop && hostNickname == null) {
      return;
    }
    if (coop) {
      if (ref.read(coopBackendProvider) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Firebase の設定ファイルがまだありません')),
        );
        return;
      }
      ref.read(coopHostDraftProvider.notifier).setNickname(hostNickname!);
    } else {
      ref.read(coopHostDraftProvider.notifier).clear();
    }
    context.push('/mission/random/${radius.meters}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final enabled = !coop || hostNickname != null;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: enabled ? () => _start(context, ref) : null,
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
  const DestinationPickerWidget({
    required this.coop,
    this.hostNickname,
    super.key,
  });

  /// 協力モードか。
  final bool coop;

  /// 協力のとき、有効なニックネーム。
  final Nickname? hostNickname;

  /// デフォルト位置 (東京駅)
  static const LatLng _defaultPosition = LatLng(35.6812, 139.7671);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPosition = useCurrentPosition(ref);

    return currentPosition.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:
          (_, __) => _MapContent(
            initialPosition: _defaultPosition,
            coop: coop,
            hostNickname: hostNickname,
          ),
      data:
          (coord) => _MapContent(
            initialPosition: LatLng(coord.latitude, coord.longitude),
            coop: coop,
            hostNickname: hostNickname,
          ),
    );
  }
}

/// 地図と目的地選択の UI を担当するウィジェット。
///
/// 状態を子ウィジェットに閉じ込めることで、タップ時の再ビルド範囲を
/// 親の [DestinationPickerWidget] まで広げずに済む。
class _MapContent extends ConsumerStatefulWidget {
  const _MapContent({
    required this.initialPosition,
    required this.coop,
    this.hostNickname,
  });

  final LatLng initialPosition;
  final bool coop;
  final Nickname? hostNickname;

  @override
  ConsumerState<_MapContent> createState() => _MapContentState();
}

class _MapContentState extends ConsumerState<_MapContent> {
  LatLng? _selectedDestination;

  Set<Marker> get _markers =>
      _selectedDestination != null
          ? {
            Marker(
              markerId: const MarkerId('destination'),
              position: _selectedDestination!,
            ),
          }
          : {};

  void _onMapTap(LatLng position) {
    setState(() => _selectedDestination = position);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final smallTextStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Stack(
      children: [
        RepaintBoundary(
          child: GoogleMap(
            key: ValueKey(
              'map_${widget.initialPosition.latitude}_${widget.initialPosition.longitude}',
            ),
            initialCameraPosition: CameraPosition(
              target: widget.initialPosition,
              zoom: 14,
            ),
            onTap: _onMapTap,
            markers: _markers,
            myLocationEnabled: true, // 現在位置を表示
            tiltGesturesEnabled: false, // 傾きの変更を禁止
          ),
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
                  _selectedDestination != null &&
                          (!widget.coop || widget.hostNickname != null)
                      ? () {
                        if (widget.coop) {
                          if (ref.read(coopBackendProvider) == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Firebase の設定ファイルがまだありません'),
                              ),
                            );
                            return;
                          }
                          ref
                              .read(coopHostDraftProvider.notifier)
                              .setNickname(widget.hostNickname!);
                        } else {
                          ref.read(coopHostDraftProvider.notifier).clear();
                        }
                        context.push(
                          '/mission/destination/${_selectedDestination!.latitude}/${_selectedDestination!.longitude}',
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
