import 'package:flutter/material.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';
import 'package:webb_ui/src/theme.dart';

/// Displays a scrollable list of events for a single, selected day.
class CalendarAgendaView extends StatelessWidget {
  final DateTime selectedDate;
  final List<Event> allEvents;

  const CalendarAgendaView({
    super.key,
    required this.selectedDate,
    required this.allEvents,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final neutralDark = webbTheme.colorPalette.neutralDark;

    // Filter and sort events for the selected day
    final dayEvents = CalendarUtils.getEventsForDay(
        selectedDate, allEvents, (event) => event.startTime);
    dayEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

    final dateString =
        '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}';
    final isToday = CalendarUtils.normalizeDate(selectedDate) ==
        CalendarUtils.normalizeDate(DateTime.now());

    return Container(
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralLight.withOpacity(0.95),
        borderRadius: BorderRadius.circular(baseSpacing * 1.5),
        border: Border.all(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Agenda Header
          Padding(
            padding: EdgeInsets.all(baseSpacing * 1.5),
            child: Text(
              isToday
                  ? 'TODAY\'S AGENDA ($dateString)'
                  : 'AGENDA FOR $dateString',
              style: webbTheme.typography.headlineMedium.copyWith(fontSize: 18),
            ),
          ),

          Expanded(
            child: dayEvents.isEmpty
                ? Center(
                    child: Text(
                      'No events on this day.',
                      style: webbTheme.typography.bodyLarge
                          .copyWith(color: neutralDark.withOpacity(0.6)),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: dayEvents.length,
                    itemBuilder: (context, index) {
                      final event = dayEvents[index];
                      return _AgendaEventTile(
                          event: event, webbTheme: webbTheme);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _AgendaEventTile extends StatelessWidget {
  final Event event;
  final BuildContext webbTheme;

  const _AgendaEventTile({required this.event, required this.webbTheme});

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
      padding: EdgeInsets.symmetric(
          vertical: baseSpacing * 1, horizontal: baseSpacing * 1.5),
      margin: EdgeInsets.symmetric(horizontal: baseSpacing * 1),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: neutralDark.withOpacity(0.1))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Color Indicator
          Container(
            margin: EdgeInsets.only(
                right: baseSpacing * 1.5, top: baseSpacing * 0.5),
            width: 5,
            height: webbTheme.typography.bodyLarge.fontSize,
            decoration: BoxDecoration(
              color: event.color,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),

          // Time
          SizedBox(
            width: baseSpacing * 12, // Ensure time column is wide enough
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
                  style: webbTheme.typography.labelLarge
                      .copyWith(color: neutralDark.withOpacity(0.6)),
                ),
              ],
            ),
          ),

          // Subject
          Expanded(
            child: Text(
              event.subject,
              style:
                  webbTheme.typography.bodyLarge.copyWith(color: neutralDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
