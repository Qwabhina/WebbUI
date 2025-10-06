import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';
import 'package:webb_ui/src/theme.dart';

/// Renders a single-day calendar view with an hour-based timeline.
class CalendarDayView extends StatelessWidget {
  final DateTime focusedDate;
  final List<Event> events;
  final int firstHour; // e.g., 0
  final int lastHour; // e.g., 23

  const CalendarDayView({
    super.key,
    required this.focusedDate,
    required this.events,
    this.firstHour = 8,
    this.lastHour = 20,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // final primaryColor = webbTheme.colorPalette.primary;
    final bodyMedium = webbTheme.typography.bodyMedium;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;

    final todayEvents = CalendarUtils.getEventsForDay(
        focusedDate, events, (event) => event.startTime);
    final hoursInView = lastHour - firstHour + 1;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Timeline
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hour Column (Fixed Width)
              SizedBox(
                width: baseSpacing * 8,
                child: Column(
                  children: List.generate(
                    hoursInView,
                    (i) {
                      final hour = firstHour + i;
                      return SizedBox(
                        height: baseSpacing * 12, // Height for one hour
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: baseSpacing * 1, top: baseSpacing * 1.5),
                          child: Text(
                            '${hour > 12 ? hour - 12 : hour == 0 ? 12 : hour} ${hour >= 12 ? 'PM' : 'AM'}',
                            style: bodyMedium.copyWith(
                                color: webbTheme.colorPalette.neutralDark
                                    .withOpacity(0.6)),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Event Column
              Expanded(
                child: Stack(
                  children: [
                    // Hour lines
                    ...List.generate(hoursInView, (i) {
                      return Positioned(
                        top: i * baseSpacing * 12,
                        left: 0,
                        right: 0,
                        child: Divider(
                          height: 1,
                          color: webbTheme.colorPalette.neutralDark
                              .withOpacity(0.1),
                          thickness: 1,
                          indent: baseSpacing * 0.5,
                        ),
                      );
                    }),

                    // Events
                    ...todayEvents.map((event) {
                      final start = event.startTime;
                      final end = event.endTime;

                      // Calculate position based on time difference from firstHour
                      final startDuration = start.difference(DateTime(
                          start.year, start.month, start.day, firstHour));
                      final endDuration = end.difference(
                          DateTime(end.year, end.month, end.day, firstHour));

                      // final totalMinutes = (lastHour - firstHour + 1) * 60;
                      final totalHeight = hoursInView * baseSpacing * 12;

                      final top =
                          (startDuration.inMinutes / 60) * (baseSpacing * 12);
                      final height =
                          (endDuration.inMinutes - startDuration.inMinutes) /
                              60 *
                              (baseSpacing * 12);

                      // Clamp values to prevent events from extending outside view
                      final clampedTop = top.clamp(0.0, totalHeight - height);
                      final clampedHeight = height.clamp(
                          baseSpacing * 4, totalHeight - clampedTop);

                      return Positioned(
                        top: clampedTop,
                        height: clampedHeight,
                        left: baseSpacing * 1,
                        right: baseSpacing * 1,
                        child: _EventTile(event: event),
                      );
                    }),
                    // }).toList(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: baseSpacing * 4), // Padding at the bottom
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Event event;

  const _EventTile({required this.event});

  String _formatTime(DateTime time) {
    // Basic time formatting
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
