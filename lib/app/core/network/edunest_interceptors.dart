import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:edunest/app/core/services/common_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

class EdunestInterceptors extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final String? userSessionToken = await CommonService.getSessionToken();

    options.headers.addAll({
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (userSessionToken != null) "Authorization": "Bearer $userSessionToken",
    });

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data is String) {
      try {
        response.data = jsonDecode(response.data as String);
      } catch (_) {}
    }
    handler.next(response);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final ApiErrorDetails parsedError = _parseApiException(err);

    if (err.response?.statusCode == 401) {
      await CommonService.clearSharedPreferences();
      Get.offAll(() => {print("hello")});
      _displayErrorModalDialog(parsedError.title, parsedError.message);
      return handler.next(err);
    }

    _displayErrorModalDialog(parsedError.title, parsedError.message);
    handler.next(err);
  }

  ApiErrorDetails _parseApiException(DioException apiException) {
    String errorTitle = "Error";
    String errorMessage = "An unexpected error occurred. Please try again.";

    switch (apiException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        errorTitle = "Connection Timeout";
        errorMessage =
            "The server is taking too long to respond. Please check your internet connection.";
        break;

      case DioExceptionType.connectionError:
        errorTitle = "No Internet Connection";
        errorMessage =
            "Unable to connect to the server. Please check your network settings and try again.";
        break;

      case DioExceptionType.badResponse:
        final int? httpStatusCode = apiException.response?.statusCode;
        errorTitle = _getHeaderTitleForStatusCode(httpStatusCode);
        errorMessage =
            _extractErrorMessageFromPayload(apiException.response?.data) ??
            _getDefaultErrorMessageForStatusCode(httpStatusCode);
        break;

      case DioExceptionType.cancel:
        errorTitle = "Request Cancelled";
        errorMessage = "The API request was cancelled.";
        break;

      case DioExceptionType.badCertificate:
        errorTitle = "Security Error";
        errorMessage = "Invalid security certificate detected.";
        break;

      case DioExceptionType.unknown:
      default:
        if (apiException.message != null && apiException.message!.isNotEmpty) {
          errorMessage = apiException.message!;
        }
        break;
    }

    return ApiErrorDetails(title: errorTitle, message: errorMessage);
  }

  String _getHeaderTitleForStatusCode(int? httpStatusCode) {
    switch (httpStatusCode) {
      case 400:
        return "Invalid Request";
      case 401:
        return "Session Expired";
      case 403:
        return "Access Denied";
      case 404:
        return "Not Found";
      case 422:
        return "Validation Error";
      case 500:
      case 502:
      case 503:
      case 504:
        return "Server Error";
      default:
        return "API Error";
    }
  }

  String _getDefaultErrorMessageForStatusCode(int? httpStatusCode) {
    switch (httpStatusCode) {
      case 400:
        return "Bad request. Please check your input and try again.";
      case 401:
        return "Your session has expired. Please login again.";
      case 403:
        return "You do not have permission to perform this action.";
      case 404:
        return "The requested resource could not be found.";
      case 422:
        return "Please check the provided information and try again.";
      case 500:
      case 502:
      case 503:
      case 504:
        return "The server encountered an error. Please try again later.";
      default:
        return "Something went wrong ($httpStatusCode). Please try again.";
    }
  }

  String? _extractErrorMessageFromPayload(dynamic rawResponseData) {
    if (rawResponseData == null) return null;

    dynamic jsonPayload = rawResponseData;
    if (jsonPayload is String) {
      try {
        jsonPayload = jsonDecode(jsonPayload);
      } catch (_) {
        return jsonPayload;
      }
    }

    if (jsonPayload is Map) {
      if (jsonPayload["errors"] is List &&
          (jsonPayload["errors"] as List).isNotEmpty) {
        final dynamic firstErrorItem = jsonPayload["errors"][0];
        if (firstErrorItem is Map && firstErrorItem.containsKey("msg")) {
          return firstErrorItem["msg"].toString();
        }
        if (firstErrorItem is String) {
          return firstErrorItem;
        }
      }
      if (jsonPayload.containsKey("message") &&
          jsonPayload["message"] != null) {
        return jsonPayload["message"].toString();
      }
      if (jsonPayload.containsKey("error") && jsonPayload["error"] != null) {
        return jsonPayload["error"].toString();
      }
      if (jsonPayload.containsKey("msg") && jsonPayload["msg"] != null) {
        return jsonPayload["msg"].toString();
      }
      if (jsonPayload.containsKey("detail") && jsonPayload["detail"] != null) {
        return jsonPayload["detail"].toString();
      }
    }

    return null;
  }

  void _displayErrorModalDialog(String dialogTitle, String dialogMessage) {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 6,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade600,
                  size: 36.0,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                dialogTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                dialogMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    if (Get.isDialogOpen == true) {
                      Get.back();
                    }
                  },
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

class ApiErrorDetails {
  final String title;
  final String message;

  const ApiErrorDetails({required this.title, required this.message});
}
