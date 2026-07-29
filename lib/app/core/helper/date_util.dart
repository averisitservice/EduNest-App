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
}
