import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:edunest/app/UI/login/tenant_page.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:get/get.dart' hide Response;

class EdunestInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? sessionToken = await CommonService.getSessionToken();

    options.headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (sessionToken != null) "Authorization": "Bearer $sessionToken",
    };

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      try {
        response.data = jsonDecode(response.data);
      } catch (_) {}
    }
    return handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await CommonService.clearSharedPreferences();
      Get.offAll(() => const TenantPage());
    }
    return handler.next(err);
  }
}
