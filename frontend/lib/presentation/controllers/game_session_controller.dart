import 'dart:io';

import 'package:path_provider/path_provider.dart';
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

/// 撮影した写真の状態を表すクラス
class CapturedPhotos {
  /// CapturedPhotosのコンストラクタ
  const CapturedPhotos({
    this.spot1PhotoPath,
    this.spot2PhotoPath,
  });

  /// Spot1の写真パス
  final String? spot1PhotoPath;

  /// Spot2の写真パス
  final String? spot2PhotoPath;

  /// 写真パスを更新した新しいCapturedPhotosを作成する
  CapturedPhotos copyWith({
    String? spot1PhotoPath,
    String? spot2PhotoPath,
  }) {
    return CapturedPhotos(
      spot1PhotoPath: spot1PhotoPath ?? this.spot1PhotoPath,
      spot2PhotoPath: spot2PhotoPath ?? this.spot2PhotoPath,
    );
  }
}

/// 撮影した写真を管理するコントローラー
@riverpod
class CapturedPhotosController extends _$CapturedPhotosController {
  @override
  CapturedPhotos build() {
    return const CapturedPhotos();
  }

  /// Spot1の写真を保存する
  Future<void> saveSpot1Photo(String sourcePath) async {
    final savedPath = await _savePhotoToDocuments(sourcePath, 'spot1');
    state = state.copyWith(spot1PhotoPath: savedPath);
    await _updateSession();
  }

  /// Spot2の写真を保存する
  Future<void> saveSpot2Photo(String sourcePath) async {
    final savedPath = await _savePhotoToDocuments(sourcePath, 'spot2');
    state = state.copyWith(spot2PhotoPath: savedPath);
    await _updateSession();
  }

  /// 保存されたセッションから写真状態を復元する
  void restoreFromSession(GameSession session) {
    state = CapturedPhotos(
      spot1PhotoPath: session.spot1PhotoPath,
      spot2PhotoPath: session.spot2PhotoPath,
    );
  }

  /// 写真状態をリセットする
  void reset() {
    state = const CapturedPhotos();
  }

  /// 写真をドキュメントディレクトリに保存する
  Future<String> _savePhotoToDocuments(String sourcePath, String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final extension = sourcePath.split('.').last;
    final fileName = 'snampo_${name}_${DateTime.now().millisecondsSinceEpoch}'
        '.$extension';
    final destPath = '${directory.path}/$fileName';

    final sourceFile = File(sourcePath);
    await sourceFile.copy(destPath);

    return destPath;
  }

  /// セッションを更新する
  Future<void> _updateSession() async {
    final repository = ref.read(gameSessionRepositoryProvider);
    final session = await repository.getSavedSession();
    if (session != null) {
      final updatedSession = session.copyWith(
        spot1PhotoPath: state.spot1PhotoPath,
        spot2PhotoPath: state.spot2PhotoPath,
      );
      await repository.saveSession(updatedSession);
    }
  }
}
