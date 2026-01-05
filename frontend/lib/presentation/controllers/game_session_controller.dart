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

/// 中断中のゲームセッションがあるかをチェックするプロバイダー
@riverpod
Future<bool> hasSavedSession(Ref ref) async {
  final repository = ref.read(gameSessionRepositoryProvider);
  return repository.hasSavedSession();
}

/// 保存されたゲームセッションを取得するプロバイダー
@riverpod
Future<GameSession?> savedSession(Ref ref) async {
  final repository = ref.read(gameSessionRepositoryProvider);
  return repository.getSavedSession();
}
