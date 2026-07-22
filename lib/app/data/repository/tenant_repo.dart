import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/tenant_model.dart';

class TenantRepo extends BaseRepo {
  Future<TenantModel> getTenantBySchoolCode(String schoolCode) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getTenantBySchoolCode(schoolCode),
      );
      return TenantModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
