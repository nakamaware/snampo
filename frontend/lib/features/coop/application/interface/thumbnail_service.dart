/// 撮影した写真からサムネ (長辺 480px 程度の JPEG) を作る
// ignore: one_member_abstracts
abstract class IThumbnailService {
  /// サムネを作って端末に保存し、そのパスを返す
  Future<String> createThumbnail(String photoPath);
}
