import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/login_response_model.dart';

class AuthRepo extends BaseRepo {
  Future<LoginResponseModel> login(String username, String password) async {
    try {
      var res = await DioClient.getInstance().post(
        AppUrls.login(),
        data: {"username": username, "password": password},
      );
      return LoginResponseModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<String> forgotPassword(String email) async {
    try {
      var res = await DioClient.getInstance().post(
        AppUrls.forgotPassword(),
        data: {"email": email},
      );
      return res.data['data'] ?? 'A new password has been sent to your email.';
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
