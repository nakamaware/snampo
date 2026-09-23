import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/config.dart';
import 'package:snampo/features/coop/application/interface/coop_auth_service.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/hook/use_coop_sign_in.dart';
import 'package:snampo/features/coop/presentation/page/coop_dialogs_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
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
    final nickname = ref.watch(nicknameStoreProvider).value;

    Future<void> createRoom(String uid) async {
      final name = await ensureNickname(context, ref);
      if (name == null || !context.mounted) return;
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
            .enter(CoopSession(roomCode: room.code.value, uid: uid));
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
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(nickname ?? 'ニックネーム未設定'),
                  trailing: TextButton(
                    onPressed: () async {
                      final input = await showNicknameDialog(
                        context,
                        initialValue: nickname ?? '',
                      );
                      if (input != null) {
                        ref.read(nicknameStoreProvider.notifier).save(input);
                      }
                    },
                    child: const Text('変更'),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: isCreating.value ? null : () => createRoom(uid),
                  icon: const Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('ルームを作る'),
                  ),
                ),
                const SizedBox(height: 16),
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
