import 'package:flutter/material.dart';
import 'package:snampo/main.dart';


// resultpageに遷移する時にバグるので要修正
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleTextstyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final textstyleLarge = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.primary,
    );
    final textstyleMid = theme.textTheme.bodyLarge!.copyWith(
      color: theme.colorScheme.primary,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'RESULT',
          style: titleTextstyle,
        ),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GOAL!!',
              style: textstyleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Congratulations!',
              style: textstyleMid,
            ),
            SizedBox(
              height: 20,
            ),
            HomeButton(),
          ],
        ),
      ),
    );
  }
}

class HomeButton extends StatelessWidget {
  const HomeButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textstyle = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, //ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => MyApp()),
        // );
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text('ホーム', style: textstyle),
      ),
    );
  }
}
