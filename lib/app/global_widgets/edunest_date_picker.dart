import 'package:edunest/app/core/values/app_colors.dart';
import 'package:flutter/material.dart';

class EdunestDatePicker {
  static Future<DateTime?> pick(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    final now = DateTime.now();
    final effectiveFirst = firstDate ?? DateTime(2020);
    final effectiveLast = lastDate ?? DateTime(now.year + 5);
    var effectiveInitial = initialDate ?? now;
    if (effectiveInitial.isBefore(effectiveFirst)) {
      effectiveInitial = effectiveFirst;
    } else if (effectiveInitial.isAfter(effectiveLast)) {
      effectiveInitial = effectiveLast;
    }

    return showDatePicker(
      context: context,
      initialDate: effectiveInitial,
      firstDate: effectiveFirst,
      lastDate: effectiveLast,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(
              context,
            ).colorScheme.copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
  }
}
