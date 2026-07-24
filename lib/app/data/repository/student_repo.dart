import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/student_detail_model.dart';

class StudentRepo extends BaseRepo {
  Future<StudentDetailModel> getStudentDetailsById(int studentId) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getStudentDetailsById(studentId),
      );
      return StudentDetailModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
