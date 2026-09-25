import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/router.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/presentation/hook/use_coop_background_sync.dart';
import 'package:snampo/features/history/di/history_provider.dart';

void main() async {
  // runAppを呼び出す前にバインディングを初期化する.
  WidgetsFlutterBinding.ensureInitialized();
  // initStateの中には、書けないので、main関数の中で実行する.
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
  runApp(
    ProviderScope(
      overrides: [
        // 履歴画面を開いたときに、協力プレイの履歴も同期する
        historySyncProvider.overrideWith(
          (ref) => ref.read(syncCoopHistoryIfSignedInUseCaseProvider)(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// アプリケーションのルートウィジェット
class MyApp extends HookConsumerWidget {
  /// MyAppのコンストラクタ
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 起動時の匿名サインインなど。失敗してもソロプレイは影響を受けずに遊べる
    useCoopBackgroundSync(ref);
    return MaterialApp.router(
      title: 'スナんぽ',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 34, 255, 38),
        ),
        textTheme: GoogleFonts.sawarabiGothicTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
