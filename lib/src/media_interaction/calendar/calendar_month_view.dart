import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'package:webb_ui/src/theme.dart';

/// Renders the primary month view grid.
class CalendarMonthView extends StatefulWidget {
  final DateTime focusedDate;
  final List<Event> events; // Renamed to Event
  final ValueChanged<DateTime> onDateSelected;
  final int firstDayOfWeek; // 1 (Monday) to 7 (Sunday)

  const CalendarMonthView({
    super.key,
    required this.focusedDate,
    required this.events,
    required this.onDateSelected,
    this.firstDayOfWeek = 7, // Default to Sunday (7 in Dart)
  });

  @override
  State<CalendarMonthView> createState() => _CalendarMonthViewState();
}

class _CalendarMonthViewState extends State<CalendarMonthView> {
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.focusedDate;
  }

  @override
  void didUpdateWidget(covariant CalendarMonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When month changes, update the selected day context
    if (widget.focusedDate.month != oldWidget.focusedDate.month) {
      _selectedDay = widget.focusedDate;
    }
  }

  void _handleDayTap(DateTime date) {
    setState(() {
      _selectedDay = date;
    });
    widget.onDateSelected(date);
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final primaryColor = webbTheme.colorPalette.primary;

    final DateTime firstDayOfMonth =
        DateTime(widget.focusedDate.year, widget.focusedDate.month, 1);
    final int daysInMonth =
        DateTime(widget.focusedDate.year, widget.focusedDate.month + 1, 0).day;

    // Calculate the start offset of the first day (0-6 where 0 is the custom first day of week)
    int firstWeekday = firstDayOfMonth.weekday;
    int offset = (firstWeekday - widget.firstDayOfWeek + 7) % 7;

    final List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    final List<String> orderedWeekdays = [
      ...weekdays.sublist(widget.firstDayOfWeek - 1),
      ...weekdays.sublist(0, widget.firstDayOfWeek - 1)
    ];

    int day = 1;
    final List<Widget> dayWidgets = [];

    // Add empty cells for the starting offset
    for (int i = 0; i < offset; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // Add days of the month
    for (int i = 0; i < daysInMonth; i++) {
      final currentDay =
          DateTime(widget.focusedDate.year, widget.focusedDate.month, day);
      final bool isSelected = currentDay.day == _selectedDay?.day &&
          currentDay.month == _selectedDay?.month;
      final bool isToday = currentDay.year == DateTime.now().year &&
          currentDay.month == DateTime.now().month &&
          currentDay.day == DateTime.now().day;

      final dayAppointments = widget.events
          .where((a) => // check .events
              a.startTime.year == currentDay.year &&
              a.startTime.month == currentDay.month &&
              a.startTime.day == currentDay.day)
          .toList();

      dayWidgets.add(Expanded(
        child: GestureDetector(
          onTap: () => _handleDayTap(currentDay),
          child: Container(
            margin: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor.withOpacity(0.2) : null,
              border:
                  isToday ? Border.all(color: primaryColor, width: 1.5) : null,
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.spacing(1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$day', style: webbTheme.typography.bodyMedium),
                if (dayAppointments.isNotEmpty)
                  Container(
                    width: webbTheme.spacingGrid.spacing(1),
                    height: webbTheme.spacingGrid.spacing(1),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dayAppointments.first.color.withOpacity(0.8),
                    ),
                  )
              ],
            ),
          ),
        ),
      ));
      day++;

      // Start new row every 7 days (or at the end of the initial offset row)
      if ((dayWidgets.length % 7 == 0) && dayWidgets.isNotEmpty) {
        dayWidgets.add(const SizedBox(height: 5)); // Spacer
      }
    }

    // Add remaining empty cells for the last row
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // Convert flat list into rows of 7
    final List<Widget> calendarRows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      calendarRows.add(Row(children: dayWidgets.sublist(i, i + 7)));
    }

    return Column(
      children: [
        // Weekdays Header
        Padding(
          padding:
              EdgeInsets.symmetric(vertical: webbTheme.spacingGrid.spacing(1)),
          child: Row(
            children: orderedWeekdays
                .map((day) => Expanded(
                      child: Text(day,
                          textAlign: TextAlign.center,
                          style: webbTheme.typography.labelMedium),
                    ))
                .toList(),
          ),
        ),
        // Day Grid
        Expanded(
          child: Column(
            children: calendarRows,
          ),
        ),
      ],
    );
  }
}
