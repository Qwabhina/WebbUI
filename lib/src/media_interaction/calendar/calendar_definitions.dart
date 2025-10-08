import 'package:flutter/material.dart';

// /// Represents a scheduled event or appointment.
// class Event {
//   final String subject;
//   final DateTime startTime;
//   final DateTime endTime;
//   final String? notes;
//   final Color color;
//   final String? recurrenceRule; // Supports recurring events

//   const Event({
//     required this.subject,
//     required this.startTime,
//     required this.endTime,
//     this.notes,
//     this.color = Colors.blue,
//     this.recurrenceRule,
//   });
// }

/// Defines the available calendar display modes.
enum CalendarView {
  month,
  week,
  workweek,
  day,
  schedule,
  timelineDay,
  timelineWeek,
  timelineWorkweek,
}

/// Represents a calendar event.
class Event {
  final String id;
  final String subject;
  final DateTime startTime;
  final DateTime endTime;
  final Color color;
  final String? notes;

  const Event({
    required this.id,
    required this.subject,
    required this.startTime,
    required this.endTime,
    required this.color,
    this.notes,
  });
}

/// A custom controller for programmatically managing the calendar state (navigation and views).
class WebbUICalendarController extends ChangeNotifier {
  CalendarView _currentView = CalendarView.month;
  DateTime _focusedDate = DateTime.now();

  CalendarView get currentView => _currentView;
  DateTime get focusedDate => _focusedDate;

  /// Changes the currently displayed calendar view.
  void setView(CalendarView view) {
    if (_currentView != view) {
      _currentView = view;
      notifyListeners();
    }
  }

  /// Navigates to the next period (day, week, or month, depending on the current view).
  void next() {
    _focusedDate = _calculateNextDate(_focusedDate, _currentView);
    notifyListeners();
  }

  /// Navigates to the previous period.
  void previous() {
    _focusedDate = _calculatePreviousDate(_focusedDate, _currentView);
    notifyListeners();
  }

  /// Navigates to a specific date.
  void navigateTo(DateTime date) {
    _focusedDate = date;
    notifyListeners();
  }

  DateTime _calculateNextDate(DateTime date, CalendarView view) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    switch (view) {
      case CalendarView.day:
      case CalendarView.schedule:
      case CalendarView.timelineDay:
        return normalizedDate.add(const Duration(days: 1));
      case CalendarView.week:
      case CalendarView.timelineWeek:
        return normalizedDate.add(const Duration(days: 7));
      case CalendarView.workweek:
      case CalendarView.timelineWorkweek:
        return normalizedDate.add(const Duration(days: 7)); // Jumps one week
      case CalendarView.month:
      default:
        // Safely jump to next month by using the 1st day of the next month
        return DateTime(normalizedDate.year, normalizedDate.month + 1, 1);
    }
  }

  DateTime _calculatePreviousDate(DateTime date, CalendarView view) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    switch (view) {
      case CalendarView.day:
      case CalendarView.schedule:
      case CalendarView.timelineDay:
        return normalizedDate.subtract(const Duration(days: 1));
      case CalendarView.week:
      case CalendarView.timelineWeek:
        return normalizedDate.subtract(const Duration(days: 7));
      case CalendarView.workweek:
      case CalendarView.timelineWorkweek:
        return normalizedDate
            .subtract(const Duration(days: 7)); // Jumps one week back
      case CalendarView.month:
      default:
        // Safely jump to previous month by using the 1st day of the previous month
        return DateTime(normalizedDate.year, normalizedDate.month - 1, 1);
    }
  }
}
