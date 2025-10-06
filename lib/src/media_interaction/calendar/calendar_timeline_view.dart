import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';
import 'package:webb_ui/src/theme.dart';

/// Renders events horizontally across a timeline for days (resources).
class CalendarTimelineView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Event> events;
  final CalendarView viewType;
  final int firstHour;
  final int lastHour;

  const CalendarTimelineView({
    super.key,
    required this.focusedDate,
    required this.events,
    required this.viewType,
    this.firstHour = 8,
    this.lastHour = 20,
  });

  // Calculate the days to display based on view type
  List<DateTime> _getTimelineDays(int firstDayOfWeek) {
    switch (viewType) {
      case CalendarView.timelineDay:
        return [focusedDate];
      case CalendarView.timelineWeek:
        final startOfWeek =
            CalendarUtils.getStartOfWeek(focusedDate, firstDayOfWeek);
        return CalendarUtils.getWeekDays(startOfWeek, days: 7);
      case CalendarView.timelineWorkweek:
        final startOfWeek =
            CalendarUtils.getStartOfWeek(focusedDate, firstDayOfWeek);
        return CalendarUtils.getWeekDays(startOfWeek, days: 5);
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final headerStyle =
        webbTheme.typography.labelMedium.copyWith(fontWeight: FontWeight.bold);

    // Assuming firstDayOfWeek is 7 (Sun) for simplification, but can be passed down.
    final timelineDays = _getTimelineDays(7);
    final hours =
        lastHour - firstHour; // Number of hours represented on the timeline
    const hourWidth = 100.0; // Width allocated per hour

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          // Timeline Header (Hours)
          Container(
            height: baseSpacing * 5,
            decoration: BoxDecoration(
              color: webbTheme.colorPalette.neutralLight,
              border: Border(
                  bottom: BorderSide(
                      color:
                          webbTheme.colorPalette.neutralDark.withOpacity(0.2))),
            ),
            child: Row(
              children: [
                const SizedBox(
                    width: 120), // Placeholder for Day/Resource Column
                ...List.generate(hours + 1, (i) {
                  final hour = firstHour + i;
                  if (hour > lastHour) return const SizedBox.shrink();

                  return Container(
                    width: hourWidth,
                    alignment: Alignment.center,
                    child: Text(
                      '${hour > 12 ? hour - 12 : hour == 0 ? 12 : hour} ${hour >= 12 ? 'PM' : 'AM'}',
                      style: headerStyle,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Timeline Body (Days/Tracks)
          Expanded(
            child: ListView.builder(
              itemCount: timelineDays.length,
              itemBuilder: (context, index) {
                final day = timelineDays[index];
                final dayEvents = CalendarUtils.getEventsForDay(
                    day, events, (event) => event.startTime);
                final isToday = CalendarUtils.normalizeDate(day) ==
                    CalendarUtils.normalizeDate(DateTime.now());

                return _TimelineDayRow(
                  day: day,
                  events: dayEvents,
                  isToday: isToday,
                  firstHour: firstHour,
                  lastHour: lastHour,
                  hourWidth: hourWidth,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDayRow extends StatelessWidget {
  final DateTime day;
  final List<Event> events;
  final bool isToday;
  final int firstHour;
  final int lastHour;
  final double hourWidth;

  const _TimelineDayRow({
    required this.day,
    required this.events,
    required this.isToday,
    required this.firstHour,
    required this.lastHour,
    required this.hourWidth,
  });

  String _formatDayName(DateTime day) {
    final date = '${day.month}/${day.day}';
    if (day.weekday == 6 || day.weekday == 7) {
      return 'Wknd $date';
    }
    return '${day.day} $date';
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final totalTimelineWidth = (lastHour - firstHour + 1) * hourWidth;

    return Container(
      height: baseSpacing * 8, // Fixed height for each day track
      decoration: BoxDecoration(
        color: isToday
            ? webbTheme.colorPalette.primary.withOpacity(0.05)
            : webbTheme.colorPalette.neutralLight,
        border: Border(
            bottom: BorderSide(
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          // Day/Resource Label
          Container(
            width: 120,
            padding: EdgeInsets.symmetric(horizontal: baseSpacing),
            alignment: Alignment.centerLeft,
            child: Text(
              _formatDayName(day),
              style: webbTheme.typography.labelLarge.copyWith(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: webbTheme.colorPalette.neutralDark,
              ),
            ),
          ),

          // Timeline Events Stack
          SizedBox(
            width: totalTimelineWidth,
            child: Stack(
              children: [
                // Vertical Hour Separators
                ...List.generate(lastHour - firstHour + 1, (i) {
                  return Positioned(
                    left: i * hourWidth,
                    top: 0,
                    bottom: 0,
                    child: VerticalDivider(
                      color:
                          webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                      width: 1,
                      thickness: 1,
                    ),
                  );
                }),

                // Events
                ...events.map((event) {
                  final start = event.startTime;
                  final end = event.endTime;

                  // Calculate position in hours relative to firstHour
                  final startOffset =
                      start.hour + start.minute / 60.0 - firstHour;
                  final durationHours = end.difference(start).inMinutes / 60.0;

                  // Calculate pixel positions
                  final left = startOffset * hourWidth;
                  final width = durationHours * hourWidth;

                  // Clamp width and position to visible timeline
                  final clampedLeft = left.clamp(0.0, totalTimelineWidth);
                  final clampedWidth = width.clamp(
                      baseSpacing * 4, totalTimelineWidth - clampedLeft);

                  // We only display events that fall within the time range
                  if (left < totalTimelineWidth && (left + width) > 0) {
                    return Positioned(
                      left: clampedLeft,
                      top: baseSpacing,
                      bottom: baseSpacing,
                      width: clampedWidth,
                      child: _TimelineEventTile(event: event),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                // }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineEventTile extends StatelessWidget {
  final Event event;

  const _TimelineEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;

    return Container(
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(baseSpacing * 0.5),
        boxShadow: webbTheme.elevation.getShadows(1),
      ),
      padding: EdgeInsets.symmetric(horizontal: baseSpacing * 0.75),
      alignment: Alignment.centerLeft,
      child: Tooltip(
        message:
            '${event.subject}\n${event.startTime.hour}:${event.startTime.minute.toString().padLeft(2, '0')} - ${event.endTime.hour}:${event.endTime.minute.toString().padLeft(2, '0')}',
        child: Text(
          event.subject,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: webbTheme.typography.labelMedium
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
