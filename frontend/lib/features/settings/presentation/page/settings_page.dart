import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snampo/config.dart';
import 'package:snampo/core/di/firebase_provider.dart';
import 'package:snampo/core/domain/nickname.dart';
import 'package:snampo/features/settings/presentation/store/nickname_store.dart';

/// 設定画面 (ニックネーム / dev ビルドだけ App Check のデバッグトークン)
class SettingsPage extends HookConsumerWidget {
  /// [SettingsPage] を作成する
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(nicknameStoreProvider).value;
    final controller = useTextEditingController();
    useEffect(() {
      if (saved != null && controller.text.isEmpty) {
        controller.text = saved.value;
      }
      return null;
    }, [saved]);

    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('ニックネーム', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLength: Nickname.maxLength,
            decoration: const InputDecoration(
              hintText: '空欄なら自動で命名します',
              helperText: 'みんなで遊ぶときに、ほかのメンバーに表示されます',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              onPressed: () {
                final value = ref
                    .read(nicknameStoreProvider.notifier)
                    .save(controller.text);
                controller.text = value.value;
                FocusScope.of(context).unfocus();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('ニックネームを保存しました')));
              },
              child: const Text('保存'),
            ),
          ),
          if (Env.flavor != 'prod') ...[
            const Divider(height: 48),
            const _AppCheckDebugTokenSection(),
          ],
        ],
      ),
    );
  }
}

/// App Check のデバッグトークン (dev ビルドのみ)。コピーと共有ができる
class _AppCheckDebugTokenSection extends ConsumerWidget {
  const _AppCheckDebugTokenSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(appCheckDebugTokenProvider).value;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('App Check デバッグトークン', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        const Text('協力プレイを使うには、このトークンを管理者に共有し、Firebase コンソールに登録してもらってください。'),
        const SizedBox(height: 8),
        SelectableText(
          token ?? '読み込み中…',
          style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              onPressed:
                  token == null
                      ? null
                      : () async {
                        await Clipboard.setData(ClipboardData(text: token));
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('コピーしました')),
                          );
                        }
                      },
              icon: const Icon(Icons.copy),
              label: const Text('コピー'),
            ),
            TextButton.icon(
              onPressed:
                  token == null
                      ? null
                      : () => SharePlus.instance.share(
                        ShareParams(text: 'スナんぽ App Check デバッグトークン: $token'),
                      ),
              icon: const Icon(Icons.share),
              label: const Text('共有'),
            ),
          ],
        ),
      ],
    );
  }
}
