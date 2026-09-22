import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';

/// ホストに数字 6 桁と QR を見せる。
class CoopRoomPage extends ConsumerWidget {
  /// [CoopRoomPage] を作成する。
  const CoopRoomPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(coopSessionProvider);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('ルーム')),
        body: const Center(child: Text('ルームがありません')),
      );
    }
    final code = session.room.roomCode.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ルーム'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(code, style: theme.textTheme.displayMedium),
            const SizedBox(height: 16),
            QrImageView(data: code, size: 220),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
              },
              child: const Text('コードをコピー'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('探索を始める'),
            ),
          ],
        ),
      ),
    );
  }
}
