extension DateTimeFormatter on DateTime {
  /// Formats the date as YYYY-MM-DD.
  String get formattedDate {
    final year = this.year.toString();
    final month = this.month.toString().padLeft(2, '0');
    final day = this.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  /// Formats the time as HH:MM (24-hour).
  String get formattedTime {
    final hour = this.hour.toString().padLeft(2, '0');
    final minute = this.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats the date and time as YYYY-MM-DD HH:MM.
  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }
}
