import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/models/game_session.dart';
import 'package:snampo/repositories/game_session_repository.dart';

part 'game_session_controller.g.dart';

/// ゲームセッションリポジトリのプロバイダー
@riverpod
GameSessionRepository gameSessionRepository(Ref ref) {
  return GameSessionRepository();
}

/// ゲームセッションと写真を統合管理するコントローラー
@riverpod
class GameSessionController extends _$GameSessionController {
  @override
  Future<GameSession?> build() async {
    final repository = ref.read(gameSessionRepositoryProvider);
    return repository.getSavedSession();
  }

  /// ゲームセッションを保存する
  ///
  /// [session] は保存するゲームセッション
  Future<void> saveSession(GameSession session) async {
    final repository = ref.read(gameSessionRepositoryProvider);
    await repository.saveSession(session);
    // 状態を更新
    state = AsyncValue.data(session);
  }

  /// 指定されたインデックスのスポットの写真を保存する
  ///
  /// [sourcePath] は保存元の写真ファイルパス
  /// [spotIndex] はスポットのインデックス (0がmidpoints[0], 1がdestinationに対応)
  Future<void> saveSpotPhoto(int spotIndex, String sourcePath) async {
    final repository = ref.read(gameSessionRepositoryProvider);
    final updatedSession = await repository.savePhotoAndUpdateSession(
      sourcePath,
      spotIndex,
    );
    // 更新されたセッションで状態を更新
    state = AsyncValue.data(updatedSession);
  }

  /// ゲームセッションを削除する
  Future<void> clearSession() async {
    final repository = ref.read(gameSessionRepositoryProvider);
    await repository.clearSession();
    // 状態をクリア
    state = const AsyncValue.data(null);
  }
}

/// 中断中のゲームセッションがあるかをチェックするプロバイダー
@riverpod
Future<bool> hasSavedSession(Ref ref) async {
  final session = await ref.watch(gameSessionControllerProvider.future);
  return session != null && session.status == GameStatus.inProgress;
}
