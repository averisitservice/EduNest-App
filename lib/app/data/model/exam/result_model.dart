class StudentResultsModel {
  final double overallPercentage;
  final num overallObtained;
  final int overallMax;
  final List<SubjectResultItem> subjects;
  final List<ExamResultItem> exams;

  const StudentResultsModel({
    required this.overallPercentage,
    required this.overallObtained,
    required this.overallMax,
    required this.subjects,
    required this.exams,
  });

  factory StudentResultsModel.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List? ?? [];
    final rawExams = json['exams'] as List? ?? [];
    return StudentResultsModel(
      overallPercentage: (json['overallPercentage'] ?? 0).toDouble(),
      overallObtained: json['overallObtained'] ?? 0,
      overallMax: json['overallMax'] ?? 0,
      subjects: rawSubjects.map((e) => SubjectResultItem.fromJson(e)).toList(),
      exams: rawExams.map((e) => ExamResultItem.fromJson(e)).toList(),
    );
  }
}

class SubjectResultItem {
  final int subjectId;
  final String subjectName;
  final num obtained;
  final int max;
  final double percentage;

  const SubjectResultItem({
    required this.subjectId,
    required this.subjectName,
    required this.obtained,
    required this.max,
    required this.percentage,
  });

  factory SubjectResultItem.fromJson(Map<String, dynamic> json) {
    return SubjectResultItem(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? "",
      obtained: json['obtained'] ?? 0,
      max: json['max'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class ExamResultItem {
  final int examId;
  final String examName;
  final String? examDate;
  final num obtained;
  final int max;
  final double percentage;
  final String grade;
  final String result;

  const ExamResultItem({
    required this.examId,
    required this.examName,
    required this.examDate,
    required this.obtained,
    required this.max,
    required this.percentage,
    required this.grade,
    required this.result,
  });

  factory ExamResultItem.fromJson(Map<String, dynamic> json) {
    return ExamResultItem(
      examId: json['examId'] ?? 0,
      examName: json['examName'] ?? "",
      examDate: json['examDate'],
      obtained: json['obtained'] ?? 0,
      max: json['max'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      grade: json['grade'] ?? "-",
      result: json['result'] ?? "",
    );
  }
}

class ReportCardModel {
  final int studentId;
  final String studentName;
  final String? rollNo;
  final String examName;
  final int maxMarksPerSubject;
  final int passMarks;
  final List<ReportCardSubjectMark> subjects;
  final num totalObtained;
  final int totalMax;
  final double percentage;
  final String overallGrade;
  final String result;

  const ReportCardModel({
    required this.studentId,
    required this.studentName,
    required this.rollNo,
    required this.examName,
    required this.maxMarksPerSubject,
    required this.passMarks,
    required this.subjects,
    required this.totalObtained,
    required this.totalMax,
    required this.percentage,
    required this.overallGrade,
    required this.result,
  });

  factory ReportCardModel.fromJson(Map<String, dynamic> json) {
    final rawSubjects = json['subjects'] as List? ?? [];
    return ReportCardModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? "",
      rollNo: json['rollNo'],
      examName: json['examName'] ?? "",
      maxMarksPerSubject: json['maxMarksPerSubject'] ?? 0,
      passMarks: json['passMarks'] ?? 0,
      subjects: rawSubjects.map((e) => ReportCardSubjectMark.fromJson(e)).toList(),
      totalObtained: json['totalObtained'] ?? 0,
      totalMax: json['totalMax'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      overallGrade: json['overallGrade'] ?? "-",
      result: json['result'] ?? "",
    );
  }
}

class ReportCardSubjectMark {
  final int subjectId;
  final String subjectName;
  final num? marksObtained;
  final String grade;
  final bool passed;

  const ReportCardSubjectMark({
    required this.subjectId,
    required this.subjectName,
    required this.marksObtained,
    required this.grade,
    required this.passed,
  });

  factory ReportCardSubjectMark.fromJson(Map<String, dynamic> json) {
    return ReportCardSubjectMark(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? "",
      marksObtained: json['marksObtained'],
      grade: json['grade'] ?? "-",
      passed: json['passed'] ?? false,
    );
  }
}
