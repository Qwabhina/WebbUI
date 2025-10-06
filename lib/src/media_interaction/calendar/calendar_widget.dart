import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'calendar_month_view.dart';
import 'calendar_week_view.dart';
import 'calendar_schedule_view.dart';
import 'calendar_timeline_view.dart';
import 'calendar_agenda_view.dart';
import 'calendar_definitions.dart';
import 'calendar_utils.dart';

/// The main component that manages the calendar state, navigation, and view rendering.
class CalendarWidget extends StatefulWidget {
  final List<Event> events;
  final CalendarView initialView;
  final int firstDayOfWeek; // 1 (Mon) to 7 (Sun)

  const CalendarWidget({
    super.key,
    required this.events,
    this.initialView = CalendarView.month,
    this.firstDayOfWeek = 1, // Default to Monday
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late DateTime _focusedDate;
  late CalendarView _currentView;
  late DateTime _selectedDate; // Used primarily by MonthView to feed AgendaView

  // Mock Events for demonstration (replace with widget.events in production)
  final List<Event> _mockEvents = [
    Event(
      id: 'e1',
      subject: 'Team Sync Up',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now().add(const Duration(minutes: 30)),
      color: Colors.blue.shade400,
    ),
    Event(
      id: 'e2',
      subject: 'Project Review - Phase 1',
      startTime: CalendarUtils.normalizeDate(
              DateTime.now().add(const Duration(days: 3)))
          .add(const Duration(hours: 10, minutes: 0)),
      endTime: CalendarUtils.normalizeDate(
              DateTime.now().add(const Duration(days: 3)))
          .add(const Duration(hours: 12, minutes: 0)),
      color: Colors.green.shade400,
    ),
    Event(
      id: 'e3',
      subject: 'Weekly Report Deadline',
      startTime: CalendarUtils.normalizeDate(
              DateTime.now().add(const Duration(days: 10)))
          .add(const Duration(hours: 14, minutes: 0)),
      endTime: CalendarUtils.normalizeDate(
              DateTime.now().add(const Duration(days: 10)))
          .add(const Duration(hours: 15, minutes: 0)),
      color: Colors.red.shade400,
      notes: 'Final push for Q3 numbers.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _focusedDate = CalendarUtils.normalizeDate(DateTime.now());
    _currentView = widget.initialView;
    _selectedDate = _focusedDate;
  }

  /// Handles navigation between months, weeks, or days.
  void _handleDateNavigation(int delta) {
    setState(() {
      switch (_currentView) {
        case CalendarView.month:
          _focusedDate =
              DateTime(_focusedDate.year, _focusedDate.month + delta, 1);
          break;
        case CalendarView.week:
        case CalendarView.workweek:
        case CalendarView.timelineWeek:
        case CalendarView.timelineWorkweek:
          _focusedDate = _focusedDate.add(Duration(days: 7 * delta));
          break;
        case CalendarView.day:
        case CalendarView.timelineDay:
        case CalendarView.schedule:
          _focusedDate = _focusedDate.add(Duration(days: delta));
          _selectedDate =
              _focusedDate; // Update selected date for Day/Schedule views
          break;
      }
    });
  }

  /// Handles selecting a specific date (used by MonthView for Agenda/Day switch).
  void _handleDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      // When a date is selected in Month View, switch to Day View or Agenda View
      if (_currentView == CalendarView.month) {
        _currentView = CalendarView.day; // Switch to Day view upon selection
        _focusedDate = date;
      }
    });
  }

  /// Renders the appropriate calendar body based on the current view.
  Widget _buildCalendarBody(BuildContext context) {
    final effectiveEvents = widget.events.isEmpty ? _mockEvents : widget.events;

    switch (_currentView) {
      case CalendarView.month:
        return Row(
          children: [
            // Left: Month Grid
            Expanded(
              flex: 3,
              child: CalendarMonthView(
                focusedDate: _focusedDate,
                events: effectiveEvents,
                onDateSelected: _handleDateSelected,
                firstDayOfWeek: widget.firstDayOfWeek,
              ),
            ),
            // Right: Agenda View for the current month's start/selected date
            Expanded(
              flex: 1,
              child: Padding(
                padding:
                    EdgeInsets.only(left: context.spacingGrid.baseSpacing * 2),
                child: CalendarAgendaView(
                  selectedDate:
                      _focusedDate, // Show agenda for the start of the focused month
                  allEvents: effectiveEvents,
                ),
              ),
            ),
          ],
        );

      case CalendarView.week:
      case CalendarView.workweek:
        return CalendarWeekView(
          focusedDate: _focusedDate,
          events: effectiveEvents,
          viewType: _currentView,
          firstDayOfWeek: widget.firstDayOfWeek,
        );

      case CalendarView.day:
        // A simple Day view implementation would use CalendarWeekView with 1 day:
        return Center(
            child: Text(
                'Day View for ${CalendarUtils.formatDateFull(_focusedDate)} - Implementation not detailed here, using Schedule View as substitute.',
                style: context.typography.bodyLarge));
      // return CalendarDayView(...); // If a dedicated DayView existed

      case CalendarView.schedule:
        return CalendarScheduleView(
          focusedDate: _focusedDate,
          allEvents: effectiveEvents,
        );

      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkweek:
        return CalendarTimelineView(
          focusedDate: _focusedDate,
          events: effectiveEvents,
          viewType: _currentView,
        );
    }
  }

  /// Renders the calendar header with navigation and view switching.
  Widget _buildHeader(BuildContext context) {
    final webbTheme = context;
    final baseSpacing = webbTheme.spacingGrid.baseSpacing;
    final bodyLarge =
        webbTheme.typography.bodyLarge.copyWith(fontWeight: FontWeight.bold);
    final primaryColor = webbTheme.colorPalette.primary;
    final iconSize = webbTheme.iconTheme.mediumSize;

    // Determine the title based on the current view using custom utilities
    String title;
    switch (_currentView) {
      case CalendarView.month:
        // FIXED: Using custom formatter
        title = CalendarUtils.formatDateMonthYear(_focusedDate);
        break;
      case CalendarView.week:
      case CalendarView.workweek:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkweek:
        final startOfWeek =
            CalendarUtils.getStartOfWeek(_focusedDate, widget.firstDayOfWeek);
        final endOfWeek = startOfWeek.add(Duration(
            days: _currentView == CalendarView.workweek ||
                    _currentView == CalendarView.timelineWorkweek
                ? 4
                : 6));
        // FIXED: Using custom formatter
        title = CalendarUtils.formatDateRange(startOfWeek, endOfWeek);
        break;
      case CalendarView.day:
      case CalendarView.schedule:
      case CalendarView.timelineDay:
        // FIXED: Using custom formatter
        title = CalendarUtils.formatDateFull(_focusedDate);
        break;
    }

    return Padding(
      padding: EdgeInsets.all(baseSpacing * 2),
      child: Row(
        children: [
          // Current Date/Range Title
          Text(title, style: webbTheme.typography.displayMedium),

          const Spacer(),

          // Today Button
          TextButton(
            onPressed: () => setState(() {
              _focusedDate = CalendarUtils.normalizeDate(DateTime.now());
              _selectedDate = _focusedDate;
            }),
            style: TextButton.styleFrom(
              foregroundColor: primaryColor,
              backgroundColor: primaryColor.withOpacity(0.1),
              padding: EdgeInsets.symmetric(
                  horizontal: baseSpacing * 2, vertical: baseSpacing * 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(baseSpacing)),
            ),
            child:
                Text('Today', style: bodyLarge.copyWith(color: primaryColor)),
          ),
          SizedBox(width: baseSpacing * 2),

          // Navigation Buttons
          Row(
            children: [
              _NavigationButton(
                icon: Icons.chevron_left,
                onPressed: () => _handleDateNavigation(-1),
                iconSize: iconSize,
                theme: webbTheme,
              ),
              _NavigationButton(
                icon: Icons.chevron_right,
                onPressed: () => _handleDateNavigation(1),
                iconSize: iconSize,
                theme: webbTheme,
              ),
            ],
          ),
          SizedBox(width: baseSpacing * 2),

          // View Selector Dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: baseSpacing),
            decoration: BoxDecoration(
              color: webbTheme.colorPalette.neutralLight,
              borderRadius: BorderRadius.circular(baseSpacing),
              border: Border.all(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CalendarView>(
                value: _currentView,
                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                style: bodyLarge,
                onChanged: (CalendarView? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _currentView = newValue;
                    });
                  }
                },
                items: CalendarView.values
                    .map<DropdownMenuItem<CalendarView>>((CalendarView value) {
                  return DropdownMenuItem<CalendarView>(
                    value: value,
                    child: Text(
                      value
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('timeline', 'Timeline '),
                      style: bodyLarge.copyWith(fontSize: 14),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildCalendarBody(context),
        ),
      ],
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double iconSize;
  final BuildContext theme;

  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.iconSize,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border.all(color: theme.colorPalette.neutralDark.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(theme.spacingGrid.baseSpacing),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 1.0),
      child: IconButton(
        icon: Icon(icon, color: theme.colorPalette.neutralDark, size: iconSize),
        onPressed: onPressed,
        splashRadius: iconSize,
        padding: EdgeInsets.all(theme.spacingGrid.baseSpacing),
      ),
    );
  }
}
