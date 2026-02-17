import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/store/mission_store.dart';

/// ミッションパラメータを設定するためのセットアップページウィジェット。
class SetupPage extends StatelessWidget {
  /// [SetupPage] ウィジェットを作成します。
  const SetupPage({super.key});

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
      ),
      body: const SliderWidget(),
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
class SubmitButton extends ConsumerWidget {
  /// [SubmitButton] ウィジェットを作成します。
  ///
  /// [radius] はミッションの検索半径です。
  const SubmitButton({required this.radius, super.key});

  /// ミッションの検索半径。
  final Radius radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ref.read(missionStoreProvider.notifier).startNewMission(radius);
        context.push('/mission');
      },
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text('GO', style: style),
      ),
    );
  }
}
