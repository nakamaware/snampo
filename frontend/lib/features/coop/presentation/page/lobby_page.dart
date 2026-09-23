import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';
import 'package:snampo/features/coop/domain/entity/coop_session.dart';
import 'package:snampo/features/coop/domain/entity/room.dart';
import 'package:snampo/features/coop/domain/entity/room_member.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/presentation/page/coop_dialogs_page.dart';
import 'package:snampo/features/coop/presentation/store/coop_mission_controller.dart';
import 'package:snampo/features/coop/presentation/store/coop_room_streams.dart';
import 'package:snampo/features/coop/presentation/store/coop_session_store.dart';
import 'package:snampo/features/mission/domain/value_object/coordinate.dart';
import 'package:snampo/features/mission/domain/value_object/radius.dart';
import 'package:snampo/features/mission/presentation/hook/use_current_position.dart';

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
      coopMissionControllerProvider(code).select((s) => s.isReady),
    );
    final room = roomAsync.value;
    // ホストのこの端末で生成中か。generating のままホストがキルされた場合は、再度開始できる
    final isStartingHere = useState(false);

    // playing でミッションを端末に用意できたら、全員が Mission 画面へ一斉に遷移する
    useEffect(() {
      if (room == null || !isReady) return null;
      final target = switch (room.status) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('ロビー'),
        actions: [
          TextButton(
            onPressed: () => _leave(context, ref),
            child: const Text('ルームを抜ける'),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _RoomCodeCard(room: room),
              const SizedBox(height: 16),
              _MembersCard(
                members: members,
                hostId: room.hostId,
                myUid: session.uid,
              ),
              const SizedBox(height: 16),
              _SettingsCard(room: room, editable: isHost && !isGenerating),
              const SizedBox(height: 16),
              if (room.generationError != null &&
                  room.status == RoomStatus.waiting)
                _GenerationErrorCard(isHost: isHost, room: room),
              if (isHost && !isStarted)
                FilledButton(
                  onPressed:
                      isStartingHere.value
                          ? null
                          : () async {
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
              (isStarted && !isReady))
            _GeneratingOverlay(
              message: isGenerating ? 'ミッション生成中' : 'ミッションを受け取っています',
            ),
        ],
      ),
    );
  }

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

  Future<void> _leave(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('ルームを抜けますか?'),
            content: const Text('抜けた時点までの進捗は履歴に残ります。'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('キャンセル'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('抜ける'),
              ),
            ],
          ),
    );
    if (confirmed != true) return;
    await leaveCoopRoom(ref, session.roomCode, session.uid);
    if (context.mounted) context.go('/');
  }
}

class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final code = room.code.value;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('ルームコード', style: theme.textTheme.labelLarge),
            SelectableText(
              code,
              style: theme.textTheme.displaySmall?.copyWith(letterSpacing: 6),
            ),
            const SizedBox(height: 8),
            QrImageView(
              data: room.code.toQrPayload(),
              size: 180,
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ルームコードをコピーしました')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('コピー'),
                ),
                TextButton.icon(
                  onPressed:
                      () => SharePlus.instance.share(
                        ShareParams(text: 'スナんぽで一緒に遊ぼう! ルームコード: $code'),
                      ),
                  icon: const Icon(Icons.share),
                  label: const Text('共有'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.members,
    required this.hostId,
    required this.myUid,
  });

  final List<RoomMember> members;
  final String hostId;
  final String myUid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 重複した名前には、表示するときだけ入室順に番号を付ける
    final names = displayNicknames([
      for (final m in members) (uid: m.uid, nickname: m.nickname),
    ]);
    final activeCount = members.where((m) => !m.hasLeft).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'メンバー $activeCount / ${Room.maxActiveMembers} 人',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final member in members)
              ListTile(
                dense: true,
                leading: Icon(
                  member.uid == hostId ? Icons.star : Icons.person,
                  color: member.hasLeft ? theme.colorScheme.outline : null,
                ),
                title: Text(
                  [
                    names[member.uid] ?? member.nickname,
                    if (member.uid == myUid) '(あなた)',
                    if (member.hasLeft) '(抜けました)',
                  ].join(' '),
                  style:
                      member.hasLeft
                          ? TextStyle(color: theme.colorScheme.outline)
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ミッションの設定。ホストは編集でき、メンバーはリアルタイムで閲覧のみ
class _SettingsCard extends HookConsumerWidget {
  const _SettingsCard({required this.room, required this.editable});

  final Room room;
  final bool editable;

  Future<void> _update(
    BuildContext context,
    WidgetRef ref,
    RoomSettings settings,
  ) async {
    try {
      await ref
          .read(roomRepositoryProvider)
          .updateSettings(room.code, settings);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('設定を変更できませんでした')));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = room.settings;
    // スライダー操作中の値 (離したときに保存する)
    final draftMeters = useState<int?>(null);
    final meters = switch (settings) {
      RoomSettingsRandom(:final radius) => draftMeters.value ?? radius.meters,
      RoomSettingsDestination() => null,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ミッションの設定', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('ランダム')),
                ButtonSegment(value: true, label: Text('目的地指定')),
              ],
              selected: {settings is RoomSettingsDestination},
              onSelectionChanged:
                  !editable
                      ? null
                      : (selection) async {
                        final toDestination = selection.first;
                        if (toDestination ==
                            settings is RoomSettingsDestination) {
                          return;
                        }
                        if (!toDestination) {
                          await _update(
                            context,
                            ref,
                            RoomSettings.random(radius: Radius(meters: 1000)),
                          );
                        }
                        // 目的地指定は地図をタップしてピンを置いたときに保存する
                        else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('地図をタップして目的地を選んでください'),
                            ),
                          );
                        }
                      },
            ),
            const SizedBox(height: 16),
            if (meters != null) ...[
              Text(
                '${(meters / 1000).toStringAsFixed(1)} km',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium,
              ),
              Slider(
                value: meters.toDouble(),
                min: 500,
                max: 10000,
                divisions: 19,
                onChanged:
                    editable ? (v) => draftMeters.value = v.toInt() : null,
                onChangeEnd:
                    editable
                        ? (v) async {
                          await _update(
                            context,
                            ref,
                            RoomSettings.random(
                              radius: Radius(meters: v.toInt()),
                            ),
                          );
                          draftMeters.value = null;
                        }
                        : null,
              ),
            ],
            if (meters == null || editable)
              _DestinationMap(
                destination: switch (settings) {
                  RoomSettingsDestination(:final destination) => destination,
                  RoomSettingsRandom() => null,
                },
                editable: editable,
                onPick:
                    (coordinate) => _update(
                      context,
                      ref,
                      RoomSettings.destination(destination: coordinate),
                    ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 目的地指定モードの地図 (ピンを表示する。ホストはタップで目的地を選べる)
class _DestinationMap extends HookConsumerWidget {
  const _DestinationMap({
    required this.destination,
    required this.editable,
    required this.onPick,
  });

  static const _defaultPosition = LatLng(35.6812, 139.7671);

  final Coordinate? destination;
  final bool editable;
  final ValueChanged<Coordinate> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = useCurrentPosition(ref);
    final pin = destination;
    final initial =
        pin != null
            ? LatLng(pin.latitude, pin.longitude)
            : current.whenOrNull(
                  data: (c) => LatLng(c.latitude, c.longitude),
                ) ??
                _defaultPosition;
    if (current.isLoading && pin == null) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return SizedBox(
      height: 240,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: initial, zoom: 14),
          myLocationEnabled: true,
          tiltGesturesEnabled: false,
          // ListView の中でも地図を操作できるようにする
          gestureRecognizers: const {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
          onTap:
              editable
                  ? (latLng) => onPick(
                    Coordinate(
                      latitude: latLng.latitude,
                      longitude: latLng.longitude,
                    ),
                  )
                  : null,
          markers: {
            if (pin != null)
              Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(pin.latitude, pin.longitude),
              ),
          },
        ),
      ),
    );
  }
}

class _GenerationErrorCard extends StatelessWidget {
  const _GenerationErrorCard({required this.isHost, required this.room});

  final bool isHost;
  final Room room;

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
              ? 'ミッションの生成に失敗しました。設定を変えて再試行してください。\n'
                  '(${room.generationError})'
              : 'ミッションの生成に失敗しました。ホストが再試行します。',
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }
}

/// ミッション生成中のローディング演出 (Tips で待ち時間を補う)
class _GeneratingOverlay extends HookWidget {
  const _GeneratingOverlay({required this.message});

  static const _tips = [
    'スポットの写真と同じ場所・同じ向きで撮ると高評価!',
    '誰かがスポットを見つけると、全員の画面でクリアになります',
    '手分けして探すと早く見つかるかも',
    '電波が途切れても、復帰したら発見を送信します',
    '途中で抜けても、見つけたスポットは履歴に残ります',
  ];

  final String message;

  @override
  Widget build(BuildContext context) {
    final tipIndex = useState(0);
    useEffect(() {
      final timer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => tipIndex.value = (tipIndex.value + 1) % _tips.length,
      );
      return timer.cancel;
    }, const []);
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surface.withValues(alpha: 0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LoadingAnimationWidget.staggeredDotsWave(
                color: theme.colorScheme.primary,
                size: 80,
              ),
              const SizedBox(height: 16),
              Text(message, style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  'Tips: ${_tips[tipIndex.value]}',
                  key: ValueKey(tipIndex.value),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
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
                ref.read(coopSessionStoreProvider.notifier).clear();
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
