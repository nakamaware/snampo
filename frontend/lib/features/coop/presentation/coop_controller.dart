import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snampo/features/coop/application/coop_backend.dart';
import 'package:snampo/features/coop/data/coop_firebase_options.dart';
import 'package:snampo/features/coop/data/firebase_coop_backend.dart';
import 'package:snampo/features/coop/domain/entity/coop_room.dart';
import 'package:snampo/features/coop/domain/value_object/nickname.dart';
import 'package:snampo/features/coop/domain/value_object/player_id.dart';

/// 今の協力セッション。ソロのときは null。
class CoopSession {
  /// [CoopSession] を作成する。
  const CoopSession({
    required this.room,
    required this.selfId,
    required this.nickname,
  });

  /// 参加中のルーム。
  final CoopRoom room;

  /// 自分の Auth `uid`。
  final PlayerId selfId;

  /// 自分が指定したニックネーム。
  final Nickname nickname;
}

/// 設定ファイルが無いときは null。ソロは Firebase を初期化しない。
final coopBackendProvider = Provider<CoopBackend?>((ref) {
  final options = coopFirebaseOptions;
  if (options == null) {
    return null;
  }
  return FirebaseCoopBackend(options: options);
});

/// ホストが SETUP で協力を選んだときのニックネーム。
class CoopHostDraftNotifier extends Notifier<Nickname?> {
  @override
  Nickname? build() => null;

  /// [nickname] をホスト作成に渡す。
  // ignore: use_setters_to_change_properties
  void setNickname(Nickname nickname) => state = nickname;

  /// ソロ開始、またはルーム作成後に消す。
  void clear() => state = null;
}

/// [CoopHostDraftNotifier] の provider。
final coopHostDraftProvider =
    NotifierProvider<CoopHostDraftNotifier, Nickname?>(
      CoopHostDraftNotifier.new,
    );

/// 参加中のルーム。
class CoopSessionNotifier extends Notifier<CoopSession?> {
  @override
  CoopSession? build() => null;

  /// [session] を現在の協力プレイにする。
  // ignore: use_setters_to_change_properties
  void setSession(CoopSession session) => state = session;

  /// 協力プレイを終える。
  void clear() => state = null;
}

/// [CoopSessionNotifier] の provider。
final coopSessionProvider = NotifierProvider<CoopSessionNotifier, CoopSession?>(
  CoopSessionNotifier.new,
);

/// 地点 index から発見者名。
class CoopDiscovererNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => const {};

  /// [names] で置き換える。
  void replace(Map<int, String> names) => state = Map.unmodifiable(names);
}

/// [CoopDiscovererNotifier] の provider。
final coopDiscovererProvider =
    NotifierProvider<CoopDiscovererNotifier, Map<int, String>>(
      CoopDiscovererNotifier.new,
    );

/// ルーム作成の二重実行を止める。
class CoopPublishGuard extends Notifier<bool> {
  @override
  bool build() => false;

  /// まだ始まっていなければ true。
  bool tryStart() {
    if (state) {
      return false;
    }
    state = true;
    return true;
  }

  /// 作成に失敗したとき、もう一度 SETUP から試せるようにする。
  void reset() => state = false;
}

/// [CoopPublishGuard] の provider。
final coopPublishGuardProvider = NotifierProvider<CoopPublishGuard, bool>(
  CoopPublishGuard.new,
);
