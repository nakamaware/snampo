import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/config.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/presentation/component/confirm_dialog.dart';
import 'package:snampo/features/coop/presentation/component/coop_room_dialogs.dart';
import 'package:snampo/features/coop/presentation/component/leave_room_pop_scope.dart';
import 'package:snampo/features/coop/presentation/component/lobby_settings_card.dart';
import 'package:snampo/features/coop/presentation/component/mission_generating_overlay.dart';
import 'package:snampo/features/coop/presentation/component/room_info.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_store.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';

/// ロビー: メンバーを集め、ホストが設定を決めて開始する画面
///
/// 端末で進行中のルーム ([CoopSessionStore]) を表示する。「ルームに戻る」もここに来て、
/// ルームの状態に合わせて Mission 画面や結果画面へ移る。
class LobbyPage extends ConsumerWidget {
  /// [LobbyPage] を作成する
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(coopSessionStoreProvider);
    return sessionAsync.when(
      data:
          (session) =>
              session == null
                  ? const _MessageScaffold(message: '参加中のルームはありません')
                  : _Lobby(session: session),
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, _) => const _MessageScaffold(message: 'ルームを読み込めませんでした'),
    );
  }
}

class _Lobby extends HookConsumerWidget {
  const _Lobby({required this.session});

  final CoopSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = session.roomCode;
    final roomAsync = ref.watch(coopRoomProvider(code));
    final members = ref.watch(coopMembersProvider(code)).value ?? const [];
    final isReady = ref.watch(
      coopMissionStoreProvider(code).select((s) => s.isReady),
    );
    final prepareError = ref.watch(
      coopMissionStoreProvider(code).select((s) => s.prepareError),
    );
    final room = roomAsync.value;
    // ホストのこの端末で生成中か。generating のままホストがキルされた場合は、再度開始できる
    final isStartingHere = useState(false);

    // playing でミッションを端末に用意できたら、全員が Mission 画面へ一斉に遷移する
    useEffect(() {
      if (room == null || !isReady) return null;
      // 遊べる期限を過ぎたプレイは、Mission 画面と同じく結果画面へ移る
      final expired = !room.isPlayable(DateTime.now());
      final target = switch (room.status) {
        RoomStatus.playing when expired => '/coop/result',
        RoomStatus.playing => '/coop/mission',
        RoomStatus.finished => '/coop/result',
        _ => null,
      };
      if (target != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) context.go(target);
        });
      }
      return null;
    }, [room?.status, isReady]);

    if (roomAsync.hasError && room == null) {
      return _MessageScaffold(
        message: 'ルームに接続できませんでした。電波の良い場所で再試行してください。',
        onRetry: () => ref.invalidate(coopRoomProvider(code)),
      );
    }
    if (room == null) {
      return roomAsync.isLoading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _ClosedRoomScaffold(session: session, message: 'このルームは期限切れです');
    }
    if (!room.isPlayable(DateTime.now()) &&
        room.status != RoomStatus.finished) {
      return _ClosedRoomScaffold(session: session, message: 'このルームは期限切れです');
    }

    final isHost = room.isHost(session.uid);
    final isGenerating = room.status == RoomStatus.generating;
    final isStarted =
        room.status == RoomStatus.playing || room.status == RoomStatus.finished;

    return LeaveRoomPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ロビー'),
          actions: [
            TextButton(
              onPressed: () => leaveRoomWithConfirm(context, ref),
              child: const Text('ルームを抜ける'),
            ),
          ],
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RoomCodeCard(room: room),
                const SizedBox(height: 16),
                RoomMembersCard(
                  members: members,
                  hostId: room.hostId,
                  myUid: session.uid,
                ),
                const SizedBox(height: 16),
                LobbySettingsCard(
                  room: room,
                  editable: isHost && !isGenerating,
                ),
                const SizedBox(height: 16),
                if (room.generationError != null &&
                    room.status == RoomStatus.waiting)
                  _GenerationErrorCard(
                    isHost: isHost,
                    room: room,
                    showDetail: Env.isDev,
                  ),
                if (isStarted && prepareError != null)
                  _PrepareErrorCard(
                    onRetry:
                        () =>
                            ref
                                .read(coopMissionStoreProvider(code).notifier)
                                .retryPrepare(),
                  ),
                if (isHost && !isStarted)
                  FilledButton(
                    onPressed:
                        isStartingHere.value
                            ? null
                            : () async {
                              // generating のままなら、前回の生成が途中で止まった
                              // (ホストのアプリが落ちたなど) 可能性がある。二重に生成しない
                              // よう、やり直すかを確認する
                              if (isGenerating &&
                                  !await _confirmRestart(context)) {
                                return;
                              }
                              if (!context.mounted) return;
                              isStartingHere.value = true;
                              await _start(context, ref, room);
                              if (context.mounted) isStartingHere.value = false;
                            },
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('開始する'),
                    ),
                  )
                else if (!isStarted)
                  const Center(child: Text('ホストが開始するのを待っています')),
              ],
            ),
            if ((isGenerating && (!isHost || isStartingHere.value)) ||
                (isStarted && !isReady && prepareError == null))
              MissionGeneratingOverlay(
                message: isGenerating ? 'ミッション生成中' : 'ミッションを受け取っています',
              ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmRestart(BuildContext context) => showConfirmDialog(
    context,
    title: 'ミッションの生成をやり直しますか?',
    content:
        '前回の生成が途中で止まった可能性があります。'
        '生成中の場合は、しばらく待ってからやり直してください。',
    confirmLabel: 'やり直す',
  );

  Future<void> _start(BuildContext context, WidgetRef ref, Room room) async {
    try {
      await ref.read(startCoopMissionUseCaseProvider)(room);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ミッションの生成に失敗しました')));
      }
    }
  }
}

/// 開始後にミッションを受け取れなかったときの表示 (再試行できる)
class _PrepareErrorCard extends StatelessWidget {
  const _PrepareErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'ミッションを受け取れませんでした。電波の良い場所で再試行してください。',
              style: TextStyle(color: theme.colorScheme.onErrorContainer),
            ),
            const SizedBox(height: 8),
            FilledButton(onPressed: onRetry, child: const Text('再試行')),
          ],
        ),
      ),
    );
  }
}

class _GenerationErrorCard extends StatelessWidget {
  const _GenerationErrorCard({
    required this.isHost,
    required this.room,
    required this.showDetail,
  });

  final bool isHost;
  final Room room;

  /// 失敗の詳細を出すか (開発用のビルドだけ。長い例外の文字がそのまま入っている)
  final bool showDetail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          isHost
              ? 'ミッションの生成に失敗しました。設定を変えて再試行してください。'
                  '${showDetail ? '\n(${room.generationError})' : ''}'
              : 'ミッションの生成に失敗しました。ホストが再試行します。',
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}

class _ClosedRoomScaffold extends ConsumerWidget {
  const _ClosedRoomScaffold({required this.session, required this.message});

  final CoopSession session;
  final String message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('ロビー')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                ref.read(coopSessionStoreProvider.notifier).close();
                context.go('/');
              },
              child: const Text('ホームへ戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageScaffold extends StatelessWidget {
  const _MessageScaffold({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ロビー')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (onRetry != null)
                FilledButton(onPressed: onRetry, child: const Text('再試行')),
              TextButton(
                onPressed: () => context.go('/'),
                child: const Text('ホームへ戻る'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
