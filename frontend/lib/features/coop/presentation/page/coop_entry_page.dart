import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/config.dart';
import 'package:snampo/core/domain/radius.dart';
import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/component/nickname_sheet.dart';
import 'package:snampo/features/coop/presentation/hook/use_coop_sign_in.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

/// 「みんなで」: ルームを作るか、ルームに入るかを選ぶ画面
///
/// サインインと App Check のエラーは、ここで表示する (ソロには影響させない)。
class CoopEntryPage extends HookConsumerWidget {
  /// [CoopEntryPage] を作成する
  const CoopEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signIn = useCoopSignIn(ref);
    final isCreating = useState(false);

    Future<void> createRoom(String uid) async {
      final name = (await ref.read(nicknameStoreProvider.future)).nickname;
      if (!context.mounted) return;
      if (!await confirmLeaveCurrentRoom(context, ref)) return;
      isCreating.value = true;
      try {
        final room = await ref.read(createRoomUseCaseProvider)(
          uid: uid,
          nickname: name,
          settings: RoomSettings.random(radius: Radius(meters: 1000)),
        );
        ref
            .read(coopSessionStoreProvider.notifier)
            .enter(CoopSession(roomCode: room.code, uid: uid));
        if (context.mounted) {
          context.go('/coop/lobby');
        }
      } on Object {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ルームを作成できませんでした。再度お試しください')),
          );
        }
      } finally {
        if (context.mounted) isCreating.value = false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('みんなで')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (signIn.uid) {
            AsyncSnapshot(hasError: true, :final error) => _SignInErrorView(
              error: error,
              onRetry: signIn.retry,
            ),
            AsyncSnapshot(hasData: true, data: final uid?) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _NameTag(),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: isCreating.value ? null : () => createRoom(uid),
                  icon: const Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('ルームを作る'),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed:
                      isCreating.value
                          ? null
                          : () => context.push('/coop/join'),
                  icon: const Icon(Icons.login),
                  label: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('ルームに入る'),
                  ),
                ),
              ],
            ),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ),
      ),
    );
  }
}

/// 自分の名前の名札。タップすると名前を変えるシートを開く
///
/// 初めてならおまかせの名前が入っていて、何もしなくてもそのまま遊べる。
class _NameTag extends ConsumerWidget {
  const _NameTag();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final saved = ref.watch(nicknameStoreProvider).value;

    Future<void> edit() async {
      final current = await ref.read(nicknameStoreProvider.future);
      if (!context.mounted) return;
      final result = await showNicknameSheet(
        context,
        current: current,
        helperText: 'ルームのメンバーに表示されます',
      );
      if (result != null) {
        ref
            .read(nicknameStoreProvider.notifier)
            .save(result.nickname, isAuto: result.isAuto);
      }
    }

    final name = saved?.nickname.value ?? '';
    final isAuto = saved?.isAuto ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card.filled(
          margin: EdgeInsets.zero,
          color: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: saved == null ? null : edit,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'あなたの名前',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colors.secondaryContainer,
                        foregroundColor: colors.onSecondaryContainer,
                        child:
                            isAuto || name.isEmpty
                                ? const Icon(Icons.person)
                                : Text(
                                  String.fromCharCodes(name.runes.take(1)),
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: theme.textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isAuto) ...[
                              const SizedBox(height: 4),
                              const AutoNicknameBadge(),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: '名前を変える',
                        onPressed: saved == null ? null : edit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'ルームのメンバーに表示されます',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignInErrorView extends StatelessWidget {
  const _SignInErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDev = Env.flavor != 'prod';
    final authError =
        error is CoopAuthException
            ? error! as CoopAuthException
            : const CoopAuthException(CoopAuthFailure.other);
    final message = switch (authError.failure) {
      CoopAuthFailure.offline => 'オフラインのため、協力プレイに接続できません。電波の良い場所で再試行してください。',
      CoopAuthFailure.appCheck when isDev =>
        'App Check に拒否されました。設定画面のデバッグトークンを管理者に共有してください。',
      CoopAuthFailure.appCheck => 'この端末では協力プレイを利用できません。ひとりで遊ぶことはできます。',
      CoopAuthFailure.other => '協力プレイに接続できませんでした。ひとりで遊ぶことはできます。',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (authError.code != null) ...[
            const SizedBox(height: 8),
            Text(
              '(${authError.code})',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(onPressed: onRetry, child: const Text('再試行')),
          if (isDev && authError.failure == CoopAuthFailure.appCheck) ...[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/settings'),
              child: const Text('設定画面を開く'),
            ),
          ],
        ],
      ),
    );
  }
}
