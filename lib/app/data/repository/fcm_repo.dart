import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';

class FcmRepo extends BaseRepo {
  Future<void> saveFcmToken(String fcmToken) async {
    try {
      await DioClient.getInstance().post(
        AppUrls.saveFcmToken(),
        data: {
          "fcmToken": fcmToken,
          "deviceId": await _getDeviceId(),
          "platform": Platform.operatingSystem,
        },
      );
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        return (await deviceInfo.androidInfo).id;
      } else if (Platform.isIOS) {
        return (await deviceInfo.iosInfo).identifierForVendor ?? '-';
      }
    } catch (_) {}
    return '-';
  }

  Future<void> deleteFcmToken(String fcmToken) async {
    try {
      await DioClient.getInstance().delete(
        AppUrls.deleteFcmToken(),
        queryParameters: {"fcmToken": fcmToken},
      );
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
