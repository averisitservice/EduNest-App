class ExamsModel {
  final List<ExamItem> upcoming;
  final List<ExamItem> past;

  const ExamsModel({required this.upcoming, required this.past});

  factory ExamsModel.fromJson(Map<String, dynamic> json) {
    final rawUpcoming = json['upcoming'] as List? ?? [];
    final rawPast = json['past'] as List? ?? [];
    return ExamsModel(
      upcoming: rawUpcoming.map((e) => ExamItem.fromJson(e)).toList(),
      past: rawPast.map((e) => ExamItem.fromJson(e)).toList(),
    );
  }
}

class ExamItem {
  final String examName;
  final String subjectName;
  final String examDate;
  final String startTime;
  final String endTime;
  final int maxMarks;
  final String status;

  const ExamItem({
    required this.examName,
    required this.subjectName,
    required this.examDate,
    required this.startTime,
    required this.endTime,
    required this.maxMarks,
    required this.status,
  });

  factory ExamItem.fromJson(Map<String, dynamic> json) {
    return ExamItem(
      examName: json['examName'] ?? "",
      subjectName: json['subjectName'] ?? "",
      examDate: json['examDate'] ?? "",
      startTime: json['startTime'] ?? "",
      endTime: json['endTime'] ?? "",
      maxMarks: json['maxMarks'] ?? 0,
      status: json['status'] ?? "Upcoming",
    );
  }
}
