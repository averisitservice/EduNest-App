enum HomeworkFilterType { thisWeek, thisMonth, customRange }

class HomeworkFilter {
  final HomeworkFilterType type;
  final DateTime? fromDate;
  final DateTime? toDate;

  const HomeworkFilter({required this.type, this.fromDate, this.toDate});

  bool matches(String dueDateStr) {
    DateTime dueDate;
    try {
      dueDate = DateTime.parse(dueDateStr).toLocal();
    } catch (_) {
      return true;
    }
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);

    switch (type) {
      case HomeworkFilterType.thisWeek:
        final today = DateTime.now();
        final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        final end = start.add(const Duration(days: 6));
        return !dueDateOnly.isBefore(start) && !dueDateOnly.isAfter(end);
      case HomeworkFilterType.thisMonth:
        final today = DateTime.now();
        return dueDateOnly.year == today.year && dueDateOnly.month == today.month;
      case HomeworkFilterType.customRange:
        if (fromDate == null || toDate == null) return true;
        final start = DateTime(fromDate!.year, fromDate!.month, fromDate!.day);
        final end = DateTime(toDate!.year, toDate!.month, toDate!.day);
        return !dueDateOnly.isBefore(start) && !dueDateOnly.isAfter(end);
    }
  }
}
