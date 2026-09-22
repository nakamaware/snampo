import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/coop/presentation/coop_controller.dart';
import 'package:snampo/features/coop/presentation/coop_mission_binder.dart';

/// `clears` を監視してローカル進捗へ反映する。
class CoopClearListener extends ConsumerStatefulWidget {
  /// [CoopClearListener] を作成する。
  const CoopClearListener({super.key});

  @override
  ConsumerState<CoopClearListener> createState() => _CoopClearListenerState();
}

class _CoopClearListenerState extends ConsumerState<CoopClearListener> {
  ProviderSubscription<CoopSession?>? _sessionListen;
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    // ホストはミッション画面のあとでセッションを置く。init 時点の null では足りない。
    _sessionListen = ref.listenManual(coopSessionProvider, (_, _) {
      _attach();
    }, fireImmediately: true);
  }

  void _attach() {
    unawaited(_subscription?.cancel());
    _subscription = null;
    if (!mounted) {
      return;
    }
    final session = ref.read(coopSessionProvider);
    final backend = ref.read(coopBackendProvider);
    if (session == null || backend == null) {
      return;
    }
    _subscription = backend.watchClears(session.room.roomCode).listen((clears) {
      if (!mounted) {
        return;
      }
      unawaited(syncCoopClears(ref, clears: clears));
    });
  }

  @override
  void dispose() {
    _sessionListen?.close();
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
