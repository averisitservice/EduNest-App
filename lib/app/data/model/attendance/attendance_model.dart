class AttendanceRecordItem {
  final DateTime attendanceDate;
  final String day;
  final String status;

  const AttendanceRecordItem({
    required this.attendanceDate,
    required this.day,
    required this.status,
  });

  factory AttendanceRecordItem.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordItem(
      attendanceDate: DateTime.parse(json['attendanceDate']),
      day: json['day'] ?? '',
      status: json['status'] ?? 'NOT_MARKED',
    );
  }
}

class AttendanceSummaryModel {
  final int presentDays;
  final int absentDays;
  final int lateDays;
  final int totalDays;
  final double percent;
  final List<AttendanceRecordItem> records;

  const AttendanceSummaryModel({
    required this.presentDays,
    required this.absentDays,
    required this.lateDays,
    required this.totalDays,
    required this.percent,
    required this.records,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    final list = json['records'] as List? ?? [];
    return AttendanceSummaryModel(
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      lateDays: json['lateDays'] ?? 0,
      totalDays: json['totalDays'] ?? 0,
      percent: (json['percent'] ?? 0).toDouble(),
      records: list.map((e) => AttendanceRecordItem.fromJson(e)).toList(),
    );
  }
}
