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
        return Icons.access_time_outlined;
      case DateTimePickerMode.date:
      case DateTimePickerMode.dateTime:
      default:
        return Icons.calendar_month_outlined;
    }
  }

  Color _getBorderColor(BuildContext context) {
    final webbTheme = context;

    if (widget.disabled) {
      return webbTheme.interactionStates.disabledColor;
    }

    if (widget.validationState == DateTimeValidationState.error) {
      return webbTheme.colorPalette.error;
    }

    if (widget.validationState == DateTimeValidationState.success) {
      return webbTheme.colorPalette.success;
    }

    return webbTheme.colorPalette.neutralDark.withOpacity(0.3);
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    final webbTheme = context;

    if (widget.disabled) {
      return Icon(
        _getIcon(),
        color: webbTheme.interactionStates.disabledColor,
        size: webbTheme.iconTheme.mediumSize,
      );
    }

    if (widget.validationState == DateTimeValidationState.error) {
      return Icon(
        Icons.error_outline,
        color: webbTheme.colorPalette.error,
        size: webbTheme.iconTheme.mediumSize,
      );
    }

    if (widget.validationState == DateTimeValidationState.success) {
      return Icon(
        Icons.check_circle,
        color: webbTheme.colorPalette.success,
        size: webbTheme.iconTheme.mediumSize,
      );
    }

    return Icon(
      _getIcon(),
      color: webbTheme.colorPalette.primary,
      size: webbTheme.iconTheme.mediumSize,
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
    final webbTheme = context;
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'Selected time is outside allowed range',
          style: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.onSurface,
          ),
        ),
        backgroundColor: webbTheme.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDateConstraintError() {
    final webbTheme = context;
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          'Selected date is outside allowed range',
          style: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.onSurface,
          ),
        ),
        backgroundColor: webbTheme.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
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
                  EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
              child: Row(
                children: [
                  Text(
                    widget.label!,
                    style: webbTheme.typography.labelMedium.copyWith(
                      color: widget.disabled
                          ? webbTheme.interactionStates.disabledColor
                          : webbTheme.colorPalette.neutralDark,
                    ),
                  ),
                  if (widget.required)
                    Padding(
                      padding: EdgeInsets.only(
                          left: webbTheme.spacingGrid.spacing(0.5)),
                      child: Text(
                        '*',
                        style: webbTheme.typography.labelMedium.copyWith(
                          color: webbTheme.colorPalette.error,
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
                BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: webbTheme.spacingGrid.spacing(2),
                vertical: webbTheme.spacingGrid.spacing(1.5),
              ),
              decoration: BoxDecoration(
                color: widget.disabled
                    ? webbTheme.colorPalette.neutralDark.withOpacity(0.05)
                    : webbTheme.colorPalette.surface,
                borderRadius:
                    BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _getFormattedValue(),
                      style: webbTheme.typography.bodyMedium.copyWith(
                        color: _selectedDateTime == null || widget.disabled
                            ? webbTheme.colorPalette.neutralDark
                                .withOpacity(0.5)
                            : webbTheme.colorPalette.neutralDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (suffixIcon != null)
                    Padding(
                      padding: EdgeInsets.only(
                          left: webbTheme.spacingGrid.spacing(1)),
                      child: suffixIcon,
                    ),
                ],
              ),
            ),
          ),

          // Helper Text & Error Text
          if (widget.helperText != null || widget.errorText != null)
            Padding(
              padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(0.5)),
              child: Text(
                widget.errorText ?? widget.helperText!,
                style: webbTheme.typography.labelMedium.copyWith(
                  color: widget.errorText != null
                      ? webbTheme.colorPalette.error
                      : webbTheme.colorPalette.neutralDark.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
