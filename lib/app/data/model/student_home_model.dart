class StudentHomeModel {
  final int studentId;
  final String studentName;
  final String photoUrl;
  final String displayClass;
  final String rollNo;
  final String academicYearName;

  final String todayStatus;

  final int presentDays;
  final int absentDays;
  final int lateDays;
  final double thisMonthPercent;
  final double averagePercent;

  const StudentHomeModel({
    required this.studentId,
    required this.studentName,
    required this.photoUrl,
    required this.displayClass,
    required this.rollNo,
    required this.academicYearName,
    required this.todayStatus,
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.thisMonthPercent,
    required this.averagePercent,
  });

  factory StudentHomeModel.fromJson(Map<String, dynamic> json) {
    return StudentHomeModel(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? "",
      photoUrl: json['photoUrl'] ?? "",
      displayClass: json['displayClass'] ?? "",
      rollNo: json['rollNo'] ?? "",
      academicYearName: json['academicYearName'] ?? "",
      todayStatus: json['todayStatus'] ?? "NOT_MARKED",
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      thisMonthPercent: (json['thisMonthPercent'] ?? 0).toDouble(),
      averagePercent: (json['averagePercent'] ?? 0).toDouble(),
    );
  }
}
