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
    final hasContinue = coopSession != null || hasSavedMission;
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
                      width: hasContinue ? 180 : 230,
                      child: Image.asset(
                        'images/snampo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: hasContinue ? 28 : 40),
                    if (hasContinue) ...[
                      ContinueCard(
                        roomCode: coopSession?.roomCode,
                        hasSavedMission: hasSavedMission,
                      ),
                      const SizedBox(height: 24),
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

/// 続きのカード (協力プレイ中のルームと、ソロの続き)
///
/// ルームがもう終わっていれば (結果を見る前に閉じた場合)、「結果を見る」として結果画面を開く。
/// 結果画面の「ホームへ戻る」で、ルームの行は消える。
class ContinueCard extends ConsumerWidget {
  /// [ContinueCard] を作成する
  const ContinueCard({
    required this.roomCode,
    required this.hasSavedMission,
    super.key,
  });

  /// 参加中のルームのコード (参加していなければ null)
  final RoomCode? roomCode;

  /// ソロの続きがあるか
  final bool hasSavedMission;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final roomCode = this.roomCode;
    final room =
        roomCode == null ? null : ref.watch(coopRoomProvider(roomCode)).value;
    final hasEnded = room != null && room.hasEnded(DateTime.now());

    return SizedBox(
      width: _playButtonWidth,
      child: Card.filled(
        margin: EdgeInsets.zero,
        color: colors.secondaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'つづきがあります',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            if (roomCode != null)
              _ContinueTile(
                icon: Icons.group,
                label: hasEnded ? 'ルーム $roomCode の結果を見る' : 'ルーム $roomCode に戻る',
                path: hasEnded ? '/coop/result' : '/coop/lobby',
              ),
            if (roomCode != null && hasSavedMission)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: colors.onSecondaryContainer.withValues(alpha: 0.12),
              ),
            if (hasSavedMission)
              const _ContinueTile(
                icon: Icons.person,
                label: 'ソロの続きをする',
                path: '/mission',
              ),
          ],
        ),
      ),
    );
  }
}

/// 続きのカードの 1 行
class _ContinueTile extends StatelessWidget {
  const _ContinueTile({
    required this.icon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final String label;

  /// 押したときに開く画面
  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: colors.secondary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      textColor: colors.onSecondaryContainer,
      iconColor: colors.onSurfaceVariant,
      onTap: () => context.push(path),
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
