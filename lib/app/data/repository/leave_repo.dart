import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/leave/leave_model.dart';
import 'package:intl/intl.dart';

class LeaveRepo extends BaseRepo {
  Future<List<LeaveModel>> getLeaveList() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getLeaveList());
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => LeaveModel.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<bool> submitLeave({
    required DateTime leaveDate,
    required String reason,
  }) async {
    try {
      await DioClient.getInstance().post(
        AppUrls.submitLeave(),
        data: {
          'leaveDate': DateFormat('yyyy-MM-dd').format(leaveDate),
          'reason': reason,
        },
      );
      return true;
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
