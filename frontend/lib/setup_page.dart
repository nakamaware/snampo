import 'package:flutter/material.dart';
import 'package:snampo/mission_page.dart';

class SetupPage extends StatelessWidget {
  const SetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETUP',
          style: textstyle,),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: const SliderWidget(),
    );
  }
}

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  double slidervalue = 0.5;

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
            '$slidervalue km',
            style: textstyle,),
          Slider(
            value: slidervalue,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            onChanged: (radius) {
              setState(() {
                slidervalue = radius;
              });
            }
          ),
          const SizedBox(height: 20,),
          SubmitButton(radius: slidervalue),
        ],
      ),
    );
  }
}

class SubmitButton extends StatefulWidget {
  final double radius;
  const SubmitButton({
    required this.radius,
    super.key,
  });

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
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) =>
            MissionPage(radius:widget.radius),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text('GO', style: style),
      ),
    );
  }
}