import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/school_contact_model.dart';
import 'package:edunest/app/data/model/student_detail_model.dart';
import 'package:edunest/app/data/model/student_home_model.dart';
import 'package:edunest/app/data/model/timetable_model.dart';

class ProfileRepo extends BaseRepo {
  Future<StudentHomeModel> getStudentHome() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getStudentHome());
      return StudentHomeModel.fromJson(res.data['data']);
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

  Future<SchoolContactModel> getSchoolContact() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getSchoolContact());
      return SchoolContactModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

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
