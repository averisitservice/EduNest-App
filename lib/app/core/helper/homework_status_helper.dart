import 'package:edunest/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeworkStatus {
  final String label;
  final Color textColor;
  final Color bgColor;

  const HomeworkStatus({
    required this.label,
    required this.textColor,
    required this.bgColor,
  });
}

class HomeworkStatusHelper {
  static HomeworkStatus? forDueDate(String dueDateStr) {
    if (dueDateStr.isEmpty) return null;

    DateTime dueDate;
    try {
      dueDate = DateTime.parse(dueDateStr).toLocal();
    } catch (_) {
      return null;
    }

    final today = DateTime.now();
    final todayDateOnly = DateTime(today.year, today.month, today.day);
    final dueDateOnly = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final difference = dueDateOnly.difference(todayDateOnly).inDays;

    if (difference < 0) {
      return const HomeworkStatus(
        label: 'Due Completed',
        textColor: AppColors.notificationGreenIcon,
        bgColor: AppColors.notificationGreenBg,
      );
    }
    if (difference == 0) {
      return const HomeworkStatus(
        label: 'Due Today',
        textColor: AppColors.notificationRedIcon,
        bgColor: AppColors.notificationRedBg,
      );
    }
    if (difference == 1) {
      return const HomeworkStatus(
        label: 'Due Tomorrow',
        textColor: AppColors.notificationAmberIcon,
        bgColor: AppColors.notificationAmberBg,
      );
    }
    return null;
  }

  static String formatDueDate(String dueDateStr) {
    if (dueDateStr.isEmpty) return 'No due date';
    try {
      final dt = DateTime.parse(dueDateStr).toLocal();
      return 'Due ${DateFormat('dd MMM yyyy').format(dt)}';
    } catch (_) {
      return 'Due $dueDateStr';
    }
  }
}
