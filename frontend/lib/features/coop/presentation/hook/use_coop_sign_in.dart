import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:snampo/features/coop/di/coop_provider.dart';

/// 協力プレイのサインイン状態と再試行
typedef CoopSignIn = ({AsyncSnapshot<String> uid, void Function() retry});

/// 画面を開いたとき (「みんなで」を押したとき) にサインインを試し、失敗したら再試行できるようにする
CoopSignIn useCoopSignIn(WidgetRef ref) {
  final attempt = useState(0);
  final future = useMemoized(
    () => ref.read(coopAuthServiceProvider).ensureSignedIn(),
    [attempt.value],
  );
  final snapshot = useFuture(future);
  return (uid: snapshot, retry: () => attempt.value++);
}
