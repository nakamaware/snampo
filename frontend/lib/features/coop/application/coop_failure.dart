/// 協力プレイの操作が失敗した理由。
sealed class CoopFailure implements Exception {
  /// [CoopFailure] を作成する。
  const CoopFailure();
}

/// ルームが無い。
class CoopRoomNotFound extends CoopFailure {
  /// [CoopRoomNotFound] を作成する。
  const CoopRoomNotFound();
}

/// ルームの 24 時間を過ぎている。
class CoopRoomExpired extends CoopFailure {
  /// [CoopRoomExpired] を作成する。
  const CoopRoomExpired();
}

/// コードの発行に失敗した。
class CoopRoomCodeExhausted extends CoopFailure {
  /// [CoopRoomCodeExhausted] を作成する。
  const CoopRoomCodeExhausted();
}
