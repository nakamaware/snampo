import 'package:snampo/core/domain/coordinate.dart';

/// 現在地を取得できない (端末の位置情報がオフ、または権限がない)
class LocationUnavailableException implements Exception {
  /// [LocationUnavailableException] を作成する
  const LocationUnavailableException([this.message]);

  /// 理由
  final String? message;

  @override
  String toString() => 'LocationUnavailableException($message)';
}

/// 位置情報サービスのインターフェース
///
/// 警告を抑制する理由:
/// - DIパターンでインターフェースとして使用されており、テスト時にモックに差し替えやすくするため
/// - 依存関係の逆転原則（DIP）に従い、アプリケーション層がデータ層の実装に依存しないようにするため
/// - 将来的にメソッドが追加される可能性があるため
// ignore: one_member_abstracts
abstract class ILocationService {
  /// 現在位置を取得する
  ///
  /// 高精度で現在位置を取得します。
  /// 端末の位置情報がオフ、または権限がなければ [LocationUnavailableException] を投げる。
  Future<Coordinate> getCurrentPosition();
}
