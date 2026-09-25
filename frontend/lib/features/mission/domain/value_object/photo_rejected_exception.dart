/// 撮影を受け付けられなかった ([message] を利用者にそのまま表示する)
///
/// 撮影して採点したあとの処理 (協力プレイの発見の共有など) が投げ、撮影画面が理由を表示する。
/// 撮影は捨てられ、結果画面へは進まない (撮り直せる)。
class PhotoRejectedException implements Exception {
  /// [PhotoRejectedException] を作成する
  const PhotoRejectedException(this.message);

  /// 利用者に表示する理由
  final String message;

  @override
  String toString() => 'PhotoRejectedException($message)';
}
