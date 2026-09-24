import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
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
    final coopSession = ref.watch(coopSessionStoreProvider).value;

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
                if (coopSession != null) ...[
                  BackToRoomButton(roomCode: coopSession.roomCode),
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
///
/// ルームがもう終わっていれば (結果を見る前に閉じた場合)、「結果を見る」として結果画面を開く。
/// 結果画面の「ホームへ戻る」で、このボタンは消える。
class BackToRoomButton extends ConsumerWidget {
  /// [BackToRoomButton] を作成する
  const BackToRoomButton({required this.roomCode, super.key});

  /// 参加中のルームのコード
  final RoomCode roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final room = ref.watch(coopRoomProvider(roomCode)).value;
    final hasEnded = room != null && room.hasEnded(DateTime.now());
    final style = theme.textTheme.headlineMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.secondary,
        foregroundColor: theme.colorScheme.onSecondary,
      ),
      onPressed: () => context.push(hasEnded ? '/coop/result' : '/coop/lobby'),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(hasEnded ? '結果を見る' : 'ルームに戻る', style: style),
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
