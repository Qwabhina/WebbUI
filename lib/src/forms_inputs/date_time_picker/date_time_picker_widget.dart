import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'date_time_picker_definitions.dart';
import 'date_time_picker_utils.dart';

class WebbUIDateTimePicker extends StatefulWidget {
  final DateTime? initialDateTime;
  final DateTimePickerMode mode;
  final ValueChanged<DateTime>? onDateTimeChanged;
  final String? label;
  final String? helperText;
  final String? errorText;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final TimeConstraints timeConstraints;
  final TimeFormat timeFormat;
  final DateTimeValidationState validationState;
  final bool disabled;
  final bool required;

  const WebbUIDateTimePicker({
    super.key,
    this.initialDateTime,
    this.onDateTimeChanged,
    this.label,
    this.helperText,
    this.errorText,
    this.firstDate,
    this.lastDate,
    this.timeConstraints = const TimeConstraints(),
    this.timeFormat = TimeFormat.hhmm,
    this.validationState = DateTimeValidationState.none,
    this.disabled = false,
    this.required = false,
    this.mode = DateTimePickerMode.dateTime,
  });

  @override
  State<WebbUIDateTimePicker> createState() => _WebbUIDateTimePickerState();
}

class _WebbUIDateTimePickerState extends State<WebbUIDateTimePicker> {
  late DateTime? _selectedDateTime;
  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void didUpdateWidget(WebbUIDateTimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDateTime != oldWidget.initialDateTime) {
      setState(() {
        _selectedDateTime = widget.initialDateTime;
      });
    }
  }

  String _getFormattedValue() {
    if (_selectedDateTime == null) {
      return _getPlaceholderText();
    }
    return _selectedDateTime!.formattedDisplay(widget.mode, widget.timeFormat);
  }

  String _getPlaceholderText() {
    switch (widget.mode) {
      case DateTimePickerMode.date:
        return 'Select Date';
      case DateTimePickerMode.time:
        return 'Select Time';
      case DateTimePickerMode.dateTime:
        return 'Select Date & Time';
    }
  }

  IconData _getIcon() {
    switch (widget.mode) {
      case DateTimePickerMode.time:
        // return Icons.access_time_outlined;
        return FluentIcons.clock_20_regular;
      case DateTimePickerMode.date:
      case DateTimePickerMode.dateTime:
      default:
        // return Icons.calendar_month_outlined;
        return FluentIcons.calendar_month_20_regular;
    }
  }

  Color _getBorderColor(BuildContext context) {
    
    if (widget.disabled) {
      return context.interactionStates.disabledColor;
    }

    if (widget.validationState == DateTimeValidationState.error) {
      return context.colorPalette.error;
    }

    if (widget.validationState == DateTimeValidationState.success) {
      return context.colorPalette.success;
    }

    return context.colorPalette.neutralDark.withOpacity(0.3);
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.disabled) {
      return Icon(
        _getIcon(),
        color: context.interactionStates.disabledColor,
        size: context.iconTheme.mediumSize,
      );
    }

    if (widget.validationState == DateTimeValidationState.error) {
      return Icon(
        Icons.error_outline,
        color: context.colorPalette.error,
        size: context.iconTheme.mediumSize,
      );
    }

    if (widget.validationState == DateTimeValidationState.success) {
      return Icon(
        Icons.check_circle,
        color: context.colorPalette.success,
        size: context.iconTheme.mediumSize,
      );
    }

    return Icon(
      _getIcon(),
      color: context.colorPalette.primary,
      size: context.iconTheme.mediumSize,
    );
  }

  Future<void> _showPicker() async {
    if (widget.disabled) return;

    DateTime? pickedDate;
    TimeOfDay? pickedTime;

    // Handle Date Picking
    if (widget.mode == DateTimePickerMode.date ||
        widget.mode == DateTimePickerMode.dateTime) {
      pickedDate = await _showDatePicker();
      if (pickedDate == null) return; // User cancelled
    }

    // Handle Time Picking
    if (widget.mode == DateTimePickerMode.time ||
        widget.mode == DateTimePickerMode.dateTime) {
      pickedTime = await _showTimePicker();
      if (pickedTime == null) return; // User cancelled
    }

    // Combine date and time
    final finalDateTime = _combineDateTime(
      pickedDate ?? _selectedDateTime ?? DateTime.now(),
      pickedTime ?? TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
    );

    // Validate constraints
    if (!_validateDateTime(finalDateTime)) {
      return;
    }

    if (mounted) {
      setState(() => _selectedDateTime = finalDateTime);
      widget.onDateTimeChanged?.call(finalDateTime);
    }
  }

  Future<DateTime?> _showDatePicker() async {
    final currentDate = _selectedDateTime ?? DateTime.now();

    return await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: widget.firstDate ?? DateTime(1900),
      lastDate: widget.lastDate ?? DateTime(2101),
      builder: (context, child) => _buildThemedPicker(context, child!),
    );
  }

  Future<TimeOfDay?> _showTimePicker() async {
    final currentTime =
        TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now());

    return await showTimePicker(
      context: context,
      initialTime: currentTime
          .roundToNearestInterval(widget.timeConstraints.minuteInterval),
      builder: (context, child) => _buildThemedPicker(context, child!),
    );
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  bool _validateDateTime(DateTime dateTime) {
    // Validate date range
    if (!dateTime.isWithinRange(widget.firstDate, widget.lastDate)) {
      _showDateConstraintError();
      return false;
    }

    // Validate time constraints
    final time = TimeOfDay.fromDateTime(dateTime);
    if (!time.isWithinConstraints(widget.timeConstraints)) {
      _showTimeConstraintError();
      return false;
    }

    return true;
  }

  Widget _buildThemedPicker(BuildContext dialogContext, Widget child) {
    final dialogTheme = dialogContext;
    return Theme(
      data: Theme.of(dialogContext).copyWith(
        colorScheme: ColorScheme.light(
          primary: dialogTheme.colorPalette.primary,
          onPrimary: dialogTheme.colorPalette.onPrimary,
          surface: dialogTheme.colorPalette.surface,
          onSurface: dialogTheme.colorPalette.onSurface,
        ),
        dialogBackgroundColor: dialogTheme.colorPalette.surface,
      ),
      child: child,
    );
  }

  void _showTimeConstraintError() {
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'Selected time is outside allowed range',
          style: context.typography.bodyMedium.copyWith(
            color: context.colorPalette.onSurface,
          ),
        ),
        backgroundColor: context.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDateConstraintError() {
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'Selected date is outside allowed range',
          style: context.typography.bodyMedium.copyWith(
            color: context.colorPalette.onSurface,
          ),
        ),
        backgroundColor: context.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(context);
    final suffixIcon = _buildSuffixIcon(context);

    return Semantics(
      button: true,
      enabled: !widget.disabled,
      label: widget.label ?? _getPlaceholderText(),
      value:
          _selectedDateTime?.formattedDisplay(widget.mode, widget.timeFormat) ??
              '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          if (widget.label != null)
            Padding(
              padding:
                  EdgeInsets.only(bottom: context.spacingGrid.spacing(1)),
              child: Row(
                children: [
                  Text(
                    widget.label!,
                    style: context.typography.labelMedium.copyWith(
                      color: widget.disabled
                          ? context.interactionStates.disabledColor
                          : context.colorPalette.neutralDark,
                    ),
                  ),
                  if (widget.required)
                    Padding(
                      padding: EdgeInsets.only(
                          left: context.spacingGrid.spacing(0.5)),
                      child: Text(
                        '*',
                        style: context.typography.labelMedium.copyWith(
                          color: context.colorPalette.error,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Picker Input
          InkWell(
            onTap: _showPicker,
            borderRadius:
                BorderRadius.circular(context.spacingGrid.baseSpacing),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.spacingGrid.spacing(2),
                vertical: context.spacingGrid.spacing(1.5),
              ),
              decoration: BoxDecoration(
                color: widget.disabled
                    ? context.colorPalette.neutralDark.withOpacity(0.05)
                    : context.colorPalette.surface,
                borderRadius:
                    BorderRadius.circular(context.spacingGrid.baseSpacing),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getFormattedValue(),
                      style: context.typography.bodyMedium.copyWith(
                        color: _selectedDateTime == null || widget.disabled
                            ? context.colorPalette.neutralDark
                                .withOpacity(0.5)
                            : context.colorPalette.neutralDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (suffixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: context.spacingGrid.spacing(1)),
                      child: suffixIcon,
                    ),
                ],
              ),
            ),
          ),

          // Helper Text & Error Text
          if (widget.helperText != null || widget.errorText != null)
            Padding(
              padding: EdgeInsets.only(top: context.spacingGrid.spacing(0.5)),
              child: Text(
                widget.errorText ?? widget.helperText!,
                style: context.typography.labelMedium.copyWith(
                  color: widget.errorText != null
                      ? context.colorPalette.error
                      : context.colorPalette.neutralDark.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
