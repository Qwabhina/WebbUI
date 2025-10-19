import 'package:flutter/material.dart';

/// Defines the behavior of the picker.
enum DateTimePickerMode {
  /// Allows selecting only a date.
  date,

  /// Allows selecting only a time.
  time,

  /// Allows selecting both a date and a time sequentially.
  dateTime,
}

/// Defines the time format for display.
enum TimeFormat {
  hhmm, // 24-hour format (14:30)
  hhmma, // 12-hour format (2:30 PM)
}

/// Defines validation states for the picker.
enum DateTimeValidationState {
  none,
  success,
  error,
}

/// Configuration for time constraints.
class TimeConstraints {
  final TimeOfDay? minTime;
  final TimeOfDay? maxTime;
  final int minuteInterval;

  const TimeConstraints({
    this.minTime,
    this.maxTime,
    this.minuteInterval = 1,
  });

  TimeConstraints copyWith({
    TimeOfDay? minTime,
    TimeOfDay? maxTime,
    int? minuteInterval,
  }) {
    return TimeConstraints(
      minTime: minTime ?? this.minTime,
      maxTime: maxTime ?? this.maxTime,
      minuteInterval: minuteInterval ?? this.minuteInterval,
    );
  }
}
