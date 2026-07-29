import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/exam_schedule_model.dart';
import 'package:edunest/app/data/model/timetable_model.dart';

class FeaturesRepo extends BaseRepo {
  Future<ExamsModel> getStudentExams() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getStudentExams());
      return ExamsModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<TimetableModel> getStudentTimetable({String? day}) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getStudentTimetable(),
        queryParameters: (day != null && day.isNotEmpty) ? {'day': day} : null,
      );
      return TimetableModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }
}
