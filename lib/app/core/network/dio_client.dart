import 'package:dio/dio.dart';
import 'package:edunest/app/core/network/edunest_interceptors.dart';

class DioClient {
  static Dio getInstance() {
    final dio = Dio();

    dio.interceptors.clear();
    dio.interceptors.add(EdunestInterceptors());

    return dio;
  }
}
