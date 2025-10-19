import 'package:flutter/material.dart';

import 'date_time_picker_definitions.dart';

extension DateTimeFormatter on DateTime {
  /// Formats the date as YYYY-MM-DD.
  String get formattedDate {
    final year = this.year.toString();
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Formats the date in a more readable format (e.g., "Jan 15, 2024")
  String get formattedDateReadable {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[month - 1]} $day, $year';
  }

  /// Formats the time as HH:MM (24-hour format).
  String get formattedTime24 {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats the time as HH:MM AM/PM (12-hour format).
  String get formattedTime12 {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    final minuteStr = minute.toString().padLeft(2, '0');
    return '$displayHour:$minuteStr $period';
  }

  /// Formats the date and time based on format.
  String formattedDateTime(TimeFormat format) {
    final timeString =
        format == TimeFormat.hhmm ? formattedTime24 : formattedTime12;
    return '$formattedDate $timeString';
  }

  /// Formats for display in a more user-friendly way
  String formattedDisplay(DateTimePickerMode mode, TimeFormat timeFormat) {
    switch (mode) {
      case DateTimePickerMode.date:
        return formattedDateReadable;
      case DateTimePickerMode.time:
        return timeFormat == TimeFormat.hhmm
            ? formattedTime24
            : formattedTime12;
      case DateTimePickerMode.dateTime:
        final timeString =
            timeFormat == TimeFormat.hhmm ? formattedTime24 : formattedTime12;
        return '$formattedDateReadable $timeString';
    }
  }

  /// Checks if this date is within the given range.
  bool isWithinRange(DateTime? firstDate, DateTime? lastDate) {
    if (firstDate != null && isBefore(firstDate)) return false;
    if (lastDate != null && isAfter(lastDate)) return false;
    return true;
  }

  /// Creates a new DateTime with the same date but different time.
  DateTime withTime(TimeOfDay time) {
    return DateTime(year, month, day, time.hour, time.minute);
  }

  /// Creates a new DateTime with the same time but different date.
  DateTime withDate(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Gets the day of week as a string (e.g., "Monday")
  String get dayOfWeek {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    // DateTime.weekday returns 1-7 where 1 is Monday
    return days[weekday - 1];
  }

  /// Gets the day of week as an abbreviation (e.g., "Mon")
  String get dayOfWeekShort {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Gets the month name (e.g., "January")
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  /// Gets the month abbreviation (e.g., "Jan")
  String get monthNameShort {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}

extension TimeOfDayExtension on TimeOfDay {
  /// Converts TimeOfDay to DateTime (using today's date).
  DateTime toDateTime() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  /// Formats TimeOfDay based on format.
  String format(TimeFormat format) {
    if (format == TimeFormat.hhmm) {
      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    } else {
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour % 12 == 0 ? 12 : hour % 12;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Checks if this time is within the given constraints.
  bool isWithinConstraints(TimeConstraints constraints) {
    if (constraints.minTime != null && _compareTo(constraints.minTime!) < 0) {
      return false;
    }
    if (constraints.maxTime != null && _compareTo(constraints.maxTime!) > 0) {
      return false;
    }
    return true;
  }

  /// Checks if minute is valid for the given interval
  bool isValidForInterval(int minuteInterval) {
    return minute % minuteInterval == 0;
  }

  /// Rounds to the nearest valid minute for the given interval
  TimeOfDay roundToNearestInterval(int minuteInterval) {
    if (minuteInterval <= 1) return this;

    final roundedMinute = (minute / minuteInterval).round() * minuteInterval;
    if (roundedMinute >= 60) {
      return TimeOfDay(hour: hour + 1, minute: 0);
    }
    return TimeOfDay(hour: hour, minute: roundedMinute);
  }

  int _compareTo(TimeOfDay other) {
    if (hour < other.hour) return -1;
    if (hour > other.hour) return 1;
    if (minute < other.minute) return -1;
    if (minute > other.minute) return 1;
    return 0;
  }
}

/// Utility class for common date/time operations
class DateTimeUtils {
  /// Returns a list of years for a year picker
  static List<int> generateYears({int startYear = 1900, int endYear = 2100}) {
    return List.generate(endYear - startYear + 1, (index) => startYear + index);
  }

  /// Returns a list of months (1-12)
  static List<int> get months => List.generate(12, (index) => index + 1);

  /// Returns a list of days in a month (1-31)
  static List<int> getDaysInMonth(int year, int month) {
    final lastDay = DateTime(year, month + 1, 0).day;
    return List.generate(lastDay, (index) => index + 1);
  }

  /// Returns a list of hours for a time picker
  static List<int> get hours24 => List.generate(24, (index) => index);

  static List<int> get hours12 => List.generate(12, (index) => index + 1);

  /// Returns a list of minutes for a time picker with interval
  static List<int> getMinutesWithInterval(int interval) {
    final minutes = <int>[];
    for (int i = 0; i < 60; i += interval) {
      minutes.add(i);
    }
    return minutes;
  }

  /// Checks if a year is a leap year
  static bool isLeapYear(int year) {
    return (year % 4 == 0) && ((year % 100 != 0) || (year % 400 == 0));
  }

  /// Gets the number of days in a month
  static int daysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Creates a DateTime from individual components with validation
  static DateTime? createDateTime(int year, int month, int day,
      [int hour = 0, int minute = 0]) {
    try {
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return null;
    }
  }
}
