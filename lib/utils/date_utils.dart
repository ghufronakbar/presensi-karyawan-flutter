import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class DateTimeUtils {
  /// Format date to string with the default date format
  static String formatDate(DateTime date) {
    return DateFormat(AppConstants.dateFormat).format(date);
  }
  
  /// Format time to string with the default time format
  static String formatTime(DateTime time) {
    return DateFormat(AppConstants.timeFormat).format(time);
  }
  
  /// Format date and time to string with the default date time format
  static String formatDateTime(DateTime dateTime) {
    return DateFormat(AppConstants.dateTimeFormat).format(dateTime);
  }
  
  /// Format date with custom format
  static String formatCustom(DateTime date, String format) {
    return DateFormat(format).format(date);
  }
  
  /// Parse string to DateTime with default date format
  static DateTime? parseDate(String dateStr) {
    try {
      return DateFormat(AppConstants.dateFormat).parse(dateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse string to DateTime with default time format
  static DateTime? parseTime(String timeStr) {
    try {
      return DateFormat(AppConstants.timeFormat).parse(timeStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse string to DateTime with default date time format
  static DateTime? parseDateTime(String dateTimeStr) {
    try {
      return DateFormat(AppConstants.dateTimeFormat).parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Parse string to DateTime with custom format
  static DateTime? parseCustom(String dateStr, String format) {
    try {
      return DateFormat(format).parse(dateStr);
    } catch (e) {
      return null;
    }
  }
  
  /// Get current date time formatted as string
  static String getCurrentDateTime() {
    return formatDateTime(DateTime.now());
  }
  
  /// Get current date formatted as string
  static String getCurrentDate() {
    return formatDate(DateTime.now());
  }
  
  /// Get current time formatted as string
  static String getCurrentTime() {
    return formatTime(DateTime.now());
  }
  
  /// Get readable time difference (e.g. "2 hours ago", "1 day ago")
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} tahun yang lalu';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} bulan yang lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }
  
  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
  
  /// Get first day of the month
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// Get last day of the month
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  /// Get list of days in a week starting from Sunday
  static List<DateTime> getDaysInWeek(DateTime date) {
    final firstDayOfWeek = date.subtract(Duration(days: date.weekday % 7));
    return List.generate(
      7, 
      (index) => firstDayOfWeek.add(Duration(days: index)),
    );
  }
  
  /// Get list of months in the year
  static List<DateTime> getMonthsInYear(int year) {
    return List.generate(
      12, 
      (index) => DateTime(year, index + 1, 1),
    );
  }
  
  /// Format duration to string (e.g. "2h 30m")
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
} 