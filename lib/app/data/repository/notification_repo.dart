import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';

class NotificationRepo extends BaseRepo {
  Future<void> registerDeviceToken(String fcmToken, String platform) async {
    try {
      await DioClient.getInstance().post(
        AppUrls.registerDeviceToken(),
        data: {"fcmToken": fcmToken, "platform": platform},
      );
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<void> unregisterDeviceToken(String fcmToken) async {
    try {
      await DioClient.getInstance().delete(
        AppUrls.unregisterDeviceToken(),
        data: {"fcmToken": fcmToken},
      );
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
