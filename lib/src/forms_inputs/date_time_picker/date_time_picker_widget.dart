import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'date_time_picker_definitions.dart';
import 'date_time_picker_utils.dart';

/// A theme-aware component that allows users to select a date, a time, or both.
class WebbUIDateTimePicker extends StatefulWidget {
  /// The initial date and time to be displayed. Defaults to now.
  final DateTime? initialDateTime;

  /// The mode of the picker, determining if it picks date, time, or both.
  final DateTimePickerMode mode;

  /// Callback that returns the selected date and time.
  final ValueChanged<DateTime>? onDateTimeChanged;

  /// The text label displayed above the picker input.
  final String? label;

  /// The earliest allowable date.
  final DateTime? firstDate;

  /// The latest allowable date.
  final DateTime? lastDate;

  const WebbUIDateTimePicker({
    super.key,
    this.initialDateTime,
    this.onDateTimeChanged,
    this.label,
    this.firstDate,
    this.lastDate,
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  State<WebbUIDateTimePicker> createState() => _WebbUIDateTimePickerState();
}

class _WebbUIDateTimePickerState extends State<WebbUIDateTimePicker> {
  late DateTime? _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  String _getFormattedValue() {
    if (_selectedDateTime == null) {
      switch (widget.mode) {
        case DateTimePickerMode.date:
          return 'Select Date';
        case DateTimePickerMode.time:
          return 'Select Time';
        case DateTimePickerMode.dateTime:
          return 'Select Date & Time';
      }
    }

    switch (widget.mode) {
      case DateTimePickerMode.date:
        return _selectedDateTime!.formattedDate;
      case DateTimePickerMode.time:
        return _selectedDateTime!.formattedTime;
      case DateTimePickerMode.dateTime:
        return _selectedDateTime!.formattedDateTime;
    }
  }

  IconData _getIcon() {
    switch (widget.mode) {
      case DateTimePickerMode.time:
        return Icons.access_time_outlined;
      case DateTimePickerMode.date:
      case DateTimePickerMode.dateTime:
      default:
        return Icons.calendar_month_outlined;
    }
  }

  // --- Picker Logic ---

  Future<void> _showPicker(BuildContext context) async {
    // 1. Get the theme and current selection BEFORE any async gaps.
    final webbTheme = context;
    final currentSelection =
        _selectedDateTime ?? widget.initialDateTime ?? DateTime.now();

    DateTime datePart = currentSelection; // Initialize datePart safely
    TimeOfDay timePart = TimeOfDay.fromDateTime(
      currentSelection,
    ); // Initialize timePart safely

    // Helper to apply consistent theming to both pickers' builders.
    Widget pickerThemeBuilder(Widget child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).brightness == Brightness.light
              ? ColorScheme.light(
                  primary: webbTheme.colorPalette.primary,
                  onPrimary: webbTheme.colorPalette.neutralLight,
                  onSurface: webbTheme.colorPalette.neutralDark,
                )
              : ColorScheme.dark(
                  primary: webbTheme.colorPalette.primary,
                  onPrimary: webbTheme.colorPalette.neutralDark,
                  surface: webbTheme.colorPalette.neutralDark,
                  onSurface: webbTheme.colorPalette.neutralLight,
                ),
        ),
        child: child,
      );
    }

    // 1. Pick Date (if required)
    if (widget.mode == DateTimePickerMode.date ||
        widget.mode == DateTimePickerMode.dateTime) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: currentSelection,
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2101),
        builder: (context, child) =>
            pickerThemeBuilder(child!), // Use local helper
      );

      // Check mounted state before processing the result
      if (!mounted) return;
      if (pickedDate == null) return; // User cancelled

      datePart = pickedDate;
    }

    // 2. Pick Time (if required)
    if (widget.mode == DateTimePickerMode.time ||
        widget.mode == DateTimePickerMode.dateTime) {
      final pickedTime = await showTimePicker(
        context: context, // This is now a safe use of context
        initialTime: TimeOfDay.fromDateTime(currentSelection),
        builder: (context, child) =>
            pickerThemeBuilder(child!), // Use local helper
      );

      // Check mounted state before processing the result
      if (!mounted) return;
      if (pickedTime == null) return; // User cancelled

      timePart = pickedTime;
    }

    // 3. Combine and update state
    final finalDateTime = DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      timePart.hour,
      timePart.minute,
    );

    setState(() {
      _selectedDateTime = finalDateTime;
    });

    widget.onDateTimeChanged?.call(finalDateTime);
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
            child: Text(widget.label!, style: webbTheme.typography.labelMedium),
          ),
        InkWell(
          onTap: () => _showPicker(context),
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(2),
              vertical: webbTheme.spacingGrid.spacing(1),
            ),
            decoration: BoxDecoration(
              color: webbTheme.colorPalette.neutralLight.withOpacity(0.1),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
              border: Border.all(
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getFormattedValue(),
                  style: webbTheme.typography.bodyMedium.copyWith(
                    color: _selectedDateTime == null
                        ? webbTheme.colorPalette.neutralDark.withOpacity(0.5)
                        : webbTheme.colorPalette.neutralDark,
                  ),
                ),
                Icon(
                  _getIcon(),
                  color: webbTheme.colorPalette.primary,
                  size: webbTheme.iconTheme.mediumSize,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
