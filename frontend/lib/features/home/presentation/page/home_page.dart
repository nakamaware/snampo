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
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: 230,
                      child: Image.asset(
                        'images/snampo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (coopSession != null) ...[
                      BackToRoomButton(roomCode: coopSession.roomCode),
                      const SizedBox(height: 10),
                    ],
                    if (hasSavedMission) ...[
                      const ResumeButton(),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(
                      width: _playButtonWidth,
                      child: Column(
                        spacing: 12,
                        children: [
                          _PlayButton(
                            label: 'ひとりで',
                            icon: Icons.person,
                            path: '/setup',
                          ),
                          _PlayButton(
                            label: 'みんなで',
                            icon: Icons.group,
                            path: '/coop',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        textStyle: theme.textTheme.titleMedium,
                      ),
                      onPressed: () => context.push('/history'),
                      icon: const Icon(Icons.history),
                      label: const Text('履歴を見る'),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(top: 4, right: 4, child: SettingsIconButton()),
          ],
        ),
      ),
    );
  }
}

/// 「ひとりで」「みんなで」ボタンの幅
const double _playButtonWidth = 296;

/// 新しく遊び始めるボタン (「ひとりで」「みんなで」で同じ大きさ)
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.label,
    required this.icon,
    required this.path,
  });

  final String label;
  final IconData icon;

  /// 押したときに開く画面
  final String path;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(64),
        textStyle: Theme.of(context).textTheme.titleLarge,
      ),
      onPressed: () => context.push(path),
      icon: Icon(icon, size: 26),
      label: Text(label),
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
