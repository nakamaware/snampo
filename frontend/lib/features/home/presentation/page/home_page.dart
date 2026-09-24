import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/presentation/store/persisted_mission_provider.dart';

/// アプリケーションのトップページ
class HomePage extends ConsumerWidget {
  /// HomePageのコンストラクタ
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedMissionAsync = ref.watch(
      persistedMissionProvider(MissionSessionKind.solo),
    );
    final hasSavedMission = savedMissionAsync.value != null;
    final hasCoopSession = ref.watch(coopSessionStoreProvider).value != null;

    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: Image.asset('images/snampo.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                if (hasCoopSession) ...[
                  const BackToRoomButton(),
                  const SizedBox(height: 10),
                ],
                if (hasSavedMission) ...[
                  const ResumeButton(),
                  const SizedBox(height: 10),
                ],
                const StartButton(),
                const SizedBox(height: 10),
                const CoopButton(),
                const SizedBox(height: 10),
                const HistoryButton(),
              ],
            ),
          ),
          const Positioned(bottom: 20, right: 20, child: InfoIconButton()),
          const Positioned(top: 48, right: 12, child: SettingsIconButton()),
        ],
      ),
    );
  }
}

/// 保存されたミッションを再開するボタン
class ResumeButton extends StatelessWidget {
  /// [ResumeButton] を作成する
  const ResumeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
      onPressed: () => context.push('/mission'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('再開 (ソロ)', style: style),
      ),
    );
  }
}

/// 協力プレイ中のルームに戻るボタン (アプリのキルや電波断のあと)
class BackToRoomButton extends StatelessWidget {
  /// [BackToRoomButton] を作成する
  const BackToRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
      onPressed: () => context.push('/coop/lobby'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('ルームに戻る', style: style),
      ),
    );
  }
}

/// 「みんなで」 (協力プレイ) ボタン
class CoopButton extends StatelessWidget {
  /// [CoopButton] を作成する
  const CoopButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () => context.push('/coop'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('みんなで', style: style),
      ),
    );
  }
}

/// 設定画面を開くアイコン
class SettingsIconButton extends StatelessWidget {
  /// [SettingsIconButton] を作成する
  const SettingsIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings),
      color: Theme.of(context).colorScheme.primary,
      tooltip: '設定',
      onPressed: () => context.push('/settings'),
    );
  }
}

/// 「ひとりで」 (ソロ) ボタンウィジェット
class StartButton extends StatelessWidget {
  /// StartButtonのコンストラクタ
  const StartButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary, //ボタンの背景色
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      onPressed: () {
        context.push('/setup');
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('ひとりで', style: style),
      ),
    );
  }
}

/// 履歴ボタンウィジェット
class HistoryButton extends StatelessWidget {
  /// HistoryButtonのコンストラクタ
  const HistoryButton({super.key});

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
        shape: RoundedRectangleBorder(
          // 形を変えるか否か
          borderRadius: BorderRadius.circular(10), // 角の丸み
        ),
      ),
      onPressed: () => context.push('/history'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('履歴', style: style),
      ),
    );
  }
}

/// ライセンスのアイコンウィジェット
class InfoIconButton extends StatelessWidget {
  /// InfoIconButtonのコンストラクタ
  const InfoIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: const Icon(Icons.info),
      color: theme.colorScheme.primary,
      onPressed: () {
        showLicensePage(context: context);
      },
    );
  }
}
