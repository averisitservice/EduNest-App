enum HomeworkFilterType { thisWeek, thisMonth, customRange }

class HomeworkFilter {
  final HomeworkFilterType type;
  final DateTime? fromDate;
  final DateTime? toDate;

  const HomeworkFilter({required this.type, this.fromDate, this.toDate});

  factory HomeworkFilter.lastSevenDays() {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return HomeworkFilter(
      type: HomeworkFilterType.customRange,
      fromDate: todayOnly.subtract(const Duration(days: 6)),
      toDate: todayOnly,
    );
  }

  (DateTime?, DateTime?) get dateRange {
    switch (type) {
      case HomeworkFilterType.thisWeek:
        final today = DateTime.now();
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 6));
        return (start, end);
      case HomeworkFilterType.thisMonth:
        final today = DateTime.now();
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 0);
        return (start, end);
      case HomeworkFilterType.customRange:
        return (fromDate, toDate);
    }
  }
}
