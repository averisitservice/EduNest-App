import 'package:edunest/app/core/base/base_repo.dart';
import 'package:edunest/app/core/network/dio_client.dart';
import 'package:edunest/app/core/network/error_helper.dart';
import 'package:edunest/app/core/utils/app_urls.dart';
import 'package:edunest/app/data/model/exam_schedule_model.dart';
import 'package:edunest/app/data/model/homework_model.dart';
import 'package:edunest/app/data/model/timetable_model.dart';
import 'package:intl/intl.dart';

class FeaturesRepo extends BaseRepo {
  Future<ExamsModel> getStudentExams() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getStudentExams());
      return ExamsModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<List<HomeworkModelItem>> getStudentHomework({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getStudentHomework(),
        queryParameters: {
          if (fromDate != null) 'fromDate': DateFormat('yyyy-MM-dd').format(fromDate),
          if (toDate != null) 'toDate': DateFormat('yyyy-MM-dd').format(toDate),
        },
      );
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => HomeworkModelItem.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<List<HomeworkModelItem>> getStudentNotes() async {
    try {
      var res = await DioClient.getInstance().get(AppUrls.getStudentNotes());
      final list = res.data['data'] as List? ?? [];
      return list.map((e) => HomeworkModelItem.fromJson(e)).toList();
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<HomeworkDetailModel> getHomeworkDetail(int homeworkId) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getStudentHomeworkDetail(homeworkId),
      );
      return HomeworkDetailModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHelper.toApiException(e);
    }
  }

  Future<HomeworkDetailModel> getNoteDetail(int noteId) async {
    try {
      var res = await DioClient.getInstance().get(
        AppUrls.getStudentNoteDetail(noteId),
      );
      return HomeworkDetailModel.fromJson(res.data['data']);
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
