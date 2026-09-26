import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/core/domain/mission_session_kind.dart';
import 'package:snampo/core/domain/room_code.dart';
import 'package:snampo/features/coop/application/usecase/join_room_use_case.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/component/join_and_enter_room.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/coop/presentation/store/left_coop_room_store.dart';
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
    final rejoinCode = _rejoinableRoomCode(ref, inRoom: coopSession != null);
    final hasContinue =
        coopSession != null || rejoinCode != null || hasSavedMission;
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
                        rejoinCode: rejoinCode,
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

/// 抜けたルームのうち、まだ遊べて入り直せるルームのコード
///
/// 参加中のルームがあるとき、ルームを読み込めていないとき、ルームが終わったときは null。
RoomCode? _rejoinableRoomCode(WidgetRef ref, {required bool inRoom}) {
  final left = ref.watch(leftCoopRoomStoreProvider).value;
  if (inRoom || left == null) {
    return null;
  }
  final room = ref.watch(coopRoomProvider(left.roomCode)).value;
  if (room == null || room.hasEnded(DateTime.now())) {
    return null;
  }
  return left.roomCode;
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

/// 続きのカード (協力プレイ中のルーム、抜けたがまだ入り直せるルーム、ソロの続き)
///
/// ルームがもう終わっていれば (結果を見る前に閉じた場合)、「結果を見る」として結果画面を開く。
/// 結果画面の「ホームへ戻る」で、ルームの行は消える。
class ContinueCard extends ConsumerWidget {
  /// [ContinueCard] を作成する
  const ContinueCard({
    required this.roomCode,
    required this.rejoinCode,
    required this.hasSavedMission,
    super.key,
  });

  /// 参加中のルームのコード (参加していなければ null)
  final RoomCode? roomCode;

  /// 抜けたが、まだ入り直せるルームのコード (なければ null)
  final RoomCode? rejoinCode;

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
            if (rejoinCode case final code?) _RejoinTile(roomCode: code),
            if ((roomCode != null || rejoinCode != null) && hasSavedMission)
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

/// 抜けたルームに入り直す行 (コードを入れずに、同じ人として戻る)
class _RejoinTile extends HookConsumerWidget {
  const _RejoinTile({required this.roomCode});

  final RoomCode roomCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final isJoining = useState(false);

    Future<void> rejoin() async {
      // 入れると、この行は「ルームに戻る」に変わって消えるので、先に取っておく
      final router = GoRouter.of(context);
      final messenger = ScaffoldMessenger.of(context);
      final name = await ensureNickname(context, ref);
      if (name == null || !context.mounted) return;
      isJoining.value = true;
      String? error;
      try {
        final result = await joinAndEnterRoom(
          ref,
          code: roomCode,
          nickname: name,
        );
        switch (result) {
          case JoinRoomJoined():
            router.go('/coop/lobby');
          case JoinRoomFailed(error: final e):
            error = joinRoomErrorMessage(e);
        }
      } on Object {
        error = joinRoomNetworkErrorMessage;
      } finally {
        if (context.mounted) isJoining.value = false;
      }
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text(error)));
      }
    }

    return ListTile(
      leading: Icon(Icons.group, color: colors.secondary),
      title: Text('ルーム $roomCode'),
      subtitle: const Text('抜けたルームにまた入る'),
      trailing:
          isJoining.value
              ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
              : const Icon(Icons.chevron_right),
      textColor: colors.onSecondaryContainer,
      iconColor: colors.onSurfaceVariant,
      onTap: isJoining.value ? null : rejoin,
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
