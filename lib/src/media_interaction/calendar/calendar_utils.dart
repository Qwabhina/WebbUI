// Note: This file must be imported where it's used.

import 'calendar_definitions.dart';

/// Helper class for common calendar date calculations.
class CalendarUtils {
  /// Normalizes a date to midnight (00:00:00).
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Calculates the start of the week for a given date, based on the preferred first day of the week.
  static DateTime getStartOfWeek(DateTime date, int firstDayOfWeek) {
    // Dart's DateTime.weekday: 1 (Mon) - 7 (Sun)
    // firstDayOfWeek: 1 (Mon) - 7 (Sun)
    final int diff = (date.weekday - firstDayOfWeek + 7) % 7;
    return normalizeDate(date.subtract(Duration(days: diff)));
  }

  /// Gets a list of days in a week starting from startOfWeek.
  static List<DateTime> getWeekDays(DateTime startOfWeek, {int days = 7}) {
    return List.generate(
        days, (index) => startOfWeek.add(Duration(days: index)));
  }

  /// Filters events to find those occurring on a specific day.
  static List<Event> getEventsForDay(DateTime day, List<Event> allEvents,
      DateTime Function(Event) startTimeGetter) {
    final normalizedDay = normalizeDate(day);
    return allEvents
        .where(
            (event) => normalizeDate(startTimeGetter(event)) == normalizedDay)
        .toList();
  }

  // --- CUSTOM DATE FORMATTING FUNCTIONS (Replacing 'intl' package) ---

  /// Formats date to display month and year (e.g., "October 2025").
  static String formatDateMonthYear(DateTime date) {
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
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Formats date to display full day, month, date, and year (e.g., "Mon, Oct 6, 2025").
  static String formatDateFull(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, $month ${date.day}, ${date.year}';
  }

  /// Formats a date range for week view headers (e.g., "10/6/2025 - 10/12/2025").
  static String formatDateRange(DateTime start, DateTime end) {
    final startString = '${start.month}/${start.day}/${start.year}';
    final endString = '${end.month}/${end.day}/${end.year}';
    return '$startString - $endString';
  }
  // /// Normalizes a DateTime to midnight (start of the day).
  // static DateTime normalizeDate(DateTime date) {
  //   return DateTime(date.year, date.month, date.day);
  // }

  // /// Gets the start of the week for a given date, respecting the firstDayOfWeek (1=Mon, 7=Sun).
  // static DateTime getStartOfWeek(DateTime date, int firstDayOfWeek) {
  //   final normalized = normalizeDate(date);
  //   // Dart's weekday: 1=Mon, ..., 7=Sun.
  //   // Calculate the difference in days needed to move back to the start of the week.
  //   int currentDayOfWeek = normalized.weekday;
  //   int diff = currentDayOfWeek - firstDayOfWeek;

  //   if (diff < 0) {
  //     // If firstDayOfWeek is Sun (7) and currentDay is Mon (1), diff is 1 - 7 = -6.
  //     // We need to move back 6 days.
  //     diff += 7;
  //   }

  //   return normalized.subtract(Duration(days: diff));
  // }

  // /// Gets a list of dates for a week starting from `startOfWeekDate`.
  // static List<DateTime> getWeekDays(DateTime startOfWeekDate, {int days = 7}) {
  //   final List<DateTime> daysList = [];
  //   for (int i = 0; i < days; i++) {
  //     daysList.add(startOfWeekDate.add(Duration(days: i)));
  //   }
  //   return daysList;
  // }

  // /// Filters events to find those that overlap with a specific 24-hour day.
  // // Note: For multi-day events, this check is simplified. A proper calendar would check date ranges.
  // static List<T> getEventsForDay<T extends dynamic>(
  //     DateTime day, List<T> allEvents, Function(T) getStartTime) {
  //   final normalizedDay = normalizeDate(day);
  //   final nextDay = normalizedDay.add(const Duration(days: 1));

  //   return allEvents.where((event) {
  //     final startTime = getStartTime(event);
  //     // Check if event starts on this day or spans across it
  //     return startTime.isBefore(nextDay) &&
  //         startTime
  //             .isAfter(normalizedDay.subtract(const Duration(milliseconds: 1)));
  //   }).toList();
  // }
}
