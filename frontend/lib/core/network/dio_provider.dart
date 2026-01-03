import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:snampo/config.dart';

part 'dio_provider.g.dart';

/// Dioインスタンスを提供するプロバイダー
@riverpod
Dio dio(DioRef ref) {
  return Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
}
