import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';
import 'package:webb_ui/src/theme.dart';

/// Renders a Week or Work Week calendar view with an hour-based timeline.
class CalendarWeekView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Event> events;
  final CalendarView viewType; // week or workweek
  final int firstDayOfWeek;
  final int firstHour; // e.g., 0
  final int lastHour; // e.g., 23

  const CalendarWeekView({
    super.key,
    required this.focusedDate,
    required this.events,
    required this.viewType,
    required this.firstDayOfWeek,
    this.firstHour = 8,
    this.lastHour = 20,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final headerStyle =
        webbTheme.typography.labelLarge.copyWith(fontWeight: FontWeight.bold);

    final startOfWeek =
        CalendarUtils.getStartOfWeek(focusedDate, firstDayOfWeek);
    final isWorkWeek = viewType == CalendarView.workweek;
    final daysToDisplay = isWorkWeek ? 5 : 7;
    final weekDays =
        CalendarUtils.getWeekDays(startOfWeek, days: daysToDisplay);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: IntrinsicHeight(
        child: Column(
          children: [
            // Header Row (Day Names and Dates)
            Row(
              children: [
                SizedBox(width: baseSpacing * 8), // Placeholder for Hour Column
                ...weekDays.map((day) => Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: baseSpacing),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: webbTheme.colorPalette.neutralDark
                                  .withOpacity(0.2)),
                          color: CalendarUtils.normalizeDate(day) ==
                                  CalendarUtils.normalizeDate(DateTime.now())
                              ? webbTheme.colorPalette.primary.withOpacity(0.1)
                              : webbTheme.colorPalette.neutralLight,
                        ),
                        child: Column(
                          children: [
                            Text(
                              _getWeekdayName(day.weekday),
                              style: headerStyle,
                            ),
                            Text(
                              '${day.month}/${day.day}',
                              style: webbTheme.typography.labelMedium,
                            ),
                          ],
                        ),
                      ),
                    ))
                // .toList(),
              ],
            ),

            // Timeline Body
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hour Column (Fixed Width)
                  SizedBox(
                    width: baseSpacing * 8,
                    child: _buildTimeColumn(context),
                  ),

                  // Event Columns
                  ...weekDays.map((day) => Expanded(
                        child: _buildDayEventsColumn(context, day),
                      ))
                  // .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeColumn(BuildContext context) {
    final webbTheme = context;
    final hoursInView = lastHour - firstHour + 1;
    return Column(
      children: List.generate(hoursInView, (i) {
        final hour = firstHour + i;
        return SizedBox(
          height: webbTheme.spacingGrid.baseSpacing * 12, // Height for one hour
          child: Padding(
            padding: EdgeInsets.only(
                right: webbTheme.spacingGrid.baseSpacing * 1,
                top: webbTheme.spacingGrid.baseSpacing * 1.5),
            child: Text(
              '${hour > 12 ? hour - 12 : hour == 0 ? 12 : hour} ${hour >= 12 ? 'PM' : 'AM'}',
              style: webbTheme.typography.bodyMedium.copyWith(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),
              textAlign: TextAlign.right,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDayEventsColumn(BuildContext context, DateTime day) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final dayEvents =
        CalendarUtils.getEventsForDay(day, events, (event) => event.startTime);
    final hoursInView = lastHour - firstHour + 1;
    final totalHeight = hoursInView * baseSpacing * 12;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          // Hour lines for the column
          ...List.generate(hoursInView, (i) {
            return Positioned(
              top: i * baseSpacing * 12,
              left: 0,
              right: 0,
              child: Divider(
                height: 1,
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                thickness: 1,
              ),
            );
          }),

          // Events
          ...dayEvents.map((event) {
            final start = event.startTime;
            final end = event.endTime;

            final startDuration = start.difference(
                DateTime(start.year, start.month, start.day, firstHour));
            final endDuration = end
                .difference(DateTime(end.year, end.month, end.day, firstHour));

            final top = (startDuration.inMinutes / 60) * (baseSpacing * 12);
            final height = (endDuration.inMinutes - startDuration.inMinutes) /
                60 *
                (baseSpacing * 12);

            // Clamp values
            final clampedTop = top.clamp(0.0, totalHeight - height);
            final clampedHeight =
                height.clamp(baseSpacing * 4, totalHeight - clampedTop);

            return Positioned(
              top: clampedTop,
              height: clampedHeight,
              left: baseSpacing * 0.5,
              right: baseSpacing * 0.5,
              child: _EventTile(event: event),
            );
          })
          // }).toList(),
        ],
      ),
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }
}

class _EventTile extends StatelessWidget {
  final Event event;

  const _EventTile({required this.event});

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final ampm = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Container(
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.9),
        borderRadius:
            BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 1),
        boxShadow: webbTheme.elevation.getShadows(1),
      ),
      padding: EdgeInsets.all(webbTheme.spacingGrid.baseSpacing * 1),
      child: Tooltip(
        message:
            '${event.subject}\n${_formatTime(event.startTime)} - ${_formatTime(event.endTime)}',
        child: Text(
          event.subject,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: webbTheme.typography.labelMedium
              .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
