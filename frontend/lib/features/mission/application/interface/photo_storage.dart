/// 写真ストレージのインターフェース
///
/// 警告を抑制する理由:
/// - DIパターンでインターフェースとして使用されており、テスト時にモックに差し替えやすくするため
/// - 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにするため
abstract class IPhotoStorage {
  /// 写真を永続ディレクトリに保存し、保存先パスを返す
  ///
  /// [sourcePath] は保存元の写真ファイルパス
  /// [checkpointIndex] はチェックポイントのインデックス
  Future<String> savePhoto(String sourcePath, int checkpointIndex);

  /// 写真ファイルを削除する
  ///
  /// [path] は削除する写真ファイルのパス
  Future<void> deletePhoto(String path);
}
