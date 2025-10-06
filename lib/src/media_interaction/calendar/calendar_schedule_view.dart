import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';
import 'package:webb_ui/src/theme.dart';

/// Displays a list of upcoming events starting from the focused date.
class CalendarScheduleView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Event> allEvents;

  const CalendarScheduleView({
    super.key,
    required this.focusedDate,
    required this.allEvents,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final neutralLight = webbTheme.colorPalette.neutralLight;
    final neutralDark = webbTheme.colorPalette.neutralDark;

    // 1. Filter and Sort Events: Only future events from today, sorted by start time
    final relevantEvents = allEvents
        .where((e) =>
            e.startTime.isAfter(focusedDate) ||
            CalendarUtils.normalizeDate(e.startTime) ==
                CalendarUtils.normalizeDate(focusedDate))
        .toList();

    relevantEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 2. Group by Day
    final Map<DateTime, List<Event>> groupedEvents = {};
    for (var event in relevantEvents) {
      final normalizedDate = CalendarUtils.normalizeDate(event.startTime);
      groupedEvents.putIfAbsent(normalizedDate, () => []).add(event);
    }

    final sortedDays = groupedEvents.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    if (relevantEvents.isEmpty) {
      return Center(
        child: Text(
          'No upcoming events scheduled.',
          style: webbTheme.typography.headlineMedium
              .copyWith(color: neutralDark.withOpacity(0.6)),
        ),
      );
    }

    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, dayIndex) {
        final day = sortedDays[dayIndex];
        final eventsForDay = groupedEvents[day]!;
        final isToday = CalendarUtils.normalizeDate(day) ==
            CalendarUtils.normalizeDate(DateTime.now());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: baseSpacing * 1.5, horizontal: baseSpacing * 2),
              color: isToday
                  ? webbTheme.colorPalette.primary.withOpacity(0.05)
                  : neutralLight,
              child: Text(
                isToday
                    ? 'TODAY, ${day.month}/${day.day}'
                    : '${_getDayName(day.weekday)}, ${day.month}/${day.day}/${day.year}',
                style: webbTheme.typography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isToday ? webbTheme.colorPalette.primary : neutralDark,
                ),
              ),
            ),

            // Events List
            ...eventsForDay.map((event) =>
                _ScheduleEventTile(event: event, webbTheme: webbTheme))
            // .toList(),
          ],
        );
      },
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}

class _ScheduleEventTile extends StatelessWidget {
  final Event event;
  final BuildContext webbTheme;

  const _ScheduleEventTile({required this.event, required this.webbTheme});

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final neutralDark = webbTheme.colorPalette.neutralDark;

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: baseSpacing * 2, vertical: baseSpacing * 0.5),
      padding: EdgeInsets.all(baseSpacing * 1.5),
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralLight,
        borderRadius: BorderRadius.circular(baseSpacing * 1),
        border: Border(left: BorderSide(color: event.color, width: 4)),
        boxShadow: webbTheme.elevation.getShadows(1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time
          SizedBox(
            width: baseSpacing * 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatTime(event.startTime),
                  style: webbTheme.typography.labelMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatTime(event.endTime),
                  style: webbTheme.typography.labelMedium
                      .copyWith(color: neutralDark.withOpacity(0.6)),
                ),
              ],
            ),
          ),
          SizedBox(width: baseSpacing * 2),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.subject,
                  style: webbTheme.typography.bodyLarge
                      .copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (event.notes != null)
                  Padding(
                    padding: EdgeInsets.only(top: baseSpacing * 0.5),
                    child: Text(
                      event.notes!,
                      style: webbTheme.typography.bodyMedium
                          .copyWith(color: neutralDark.withOpacity(0.8)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
