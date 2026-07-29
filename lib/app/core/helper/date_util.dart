import 'package:edunest/app/core/utils/app_constants.dart';
import 'package:intl/intl.dart';

class DateUtil {
  static String getDay(String? value, {String fallback = '--'}) {
    if (value == null || value.isEmpty) return fallback;
    try {
      final DateTime dateTime = DateTime.parse(value).toLocal();
      return DateFormat(AppConstants.dayFormat).format(dateTime);
    } catch (_) {
      return fallback;
    }
  }

  static String getMonth(String? value, {String fallback = ''}) {
    if (value == null || value.isEmpty) return fallback;
    try {
      final DateTime dateTime = DateTime.parse(value).toLocal();
      return DateFormat(AppConstants.monthFormat).format(dateTime);
    } catch (_) {
      return fallback;
    }
  }

  static String getYear(String? value, {String fallback = ''}) {
    if (value == null || value.isEmpty) return fallback;
    try {
      final DateTime dateTime = DateTime.parse(value).toLocal();
      return DateFormat(AppConstants.yearFormat).format(dateTime);
    } catch (_) {
      return fallback;
    }
  }

  static String getTime(String? value, {String fallback = ''}) {
    if (value == null || value.isEmpty) return fallback;
    try {
      final parts = value.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? parts[1] : '00';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final ampm = hour >= 12 ? 'pm' : 'am';
      return '${hour12.toString().padLeft(2, '0')}:$minute $ampm';
    } catch (_) {
      return fallback.isNotEmpty ? fallback : value;
    }
  }
}
