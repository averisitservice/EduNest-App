class TimetableModel {
  final String displayClass;
  final List<DaySchedule> days;

  const TimetableModel({required this.displayClass, required this.days});

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'] as List? ?? [];
    return TimetableModel(
      displayClass: json['displayClass'] ?? "",
      days: rawDays.map((e) => DaySchedule.fromJson(e)).toList(),
    );
  }
}

class DaySchedule {
  final String dayName;
  final List<Period> periods;

  const DaySchedule({required this.dayName, required this.periods});

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    final rawPeriods = json['periods'] as List? ?? [];
    return DaySchedule(
      dayName: json['dayName'] ?? "",
      periods: rawPeriods.map((e) => Period.fromJson(e)).toList(),
    );
  }
}

class Period {
  final String slotName;
  final String startTime;
  final String endTime;
  final bool isBreak;
  final String subjectName;
  final String teacherName;

  const Period({
    required this.slotName,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    required this.subjectName,
    required this.teacherName,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      slotName: json['slotName'] ?? "",
      startTime: json['startTime'] ?? "",
      endTime: json['endTime'] ?? "",
      isBreak: json['isBreak'] ?? false,
      subjectName: json['subjectName'] ?? "",
      teacherName: json['teacherName'] ?? "",
    );
  }
}
