import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/component/mission_settings_inputs.dart';

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
    final textStyle = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.secondary,
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RadiusSlider(
            radius: slidervalue,
            textStyle: textStyle,
            onChanged: (radius) => setState(() => slidervalue = radius),
          ),
          const SizedBox(height: 20),
          SubmitButton(radius: slidervalue),
        ],
      ),
    );
  }
}

/// ミッションを開始するための送信ボタンウィジェット。
class SubmitButton extends StatelessWidget {
  /// [SubmitButton] ウィジェットを作成します。
  ///
  /// [radius] はミッションの検索半径です。
  const SubmitButton({required this.radius, super.key});

  /// ミッションの検索半径。
  final Radius radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        context.push('/mission/random/${radius.meters}');
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text('GO', style: style),
      ),
    );
  }
}

/// 目的地を地図上で選択するウィジェット
class DestinationPickerWidget extends HookWidget {
  /// [DestinationPickerWidget] ウィジェットを作成します。
  const DestinationPickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final smallTextStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final selected = useState<Coordinate?>(null);
    final destination = selected.value;

    return Stack(
      children: [
        DestinationMap(
          destination: destination,
          onPick: (coordinate) => selected.value = coordinate,
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
                  destination == null
                      ? null
                      : () => context.push(
                        '/mission/destination/'
                        '${destination.latitude}/${destination.longitude}',
                      ),
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
