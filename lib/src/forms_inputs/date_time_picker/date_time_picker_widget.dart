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
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.initialDateTime;
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

    if (widget.validationState == DateTimeValidationState.error ||
        (widget.required && _hasBeenTouched && _selectedDateTime == null)) {
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

    if (widget.validationState == DateTimeValidationState.error ||
        (widget.required && _hasBeenTouched && _selectedDateTime == null)) {
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

  Future<void> _showPicker(BuildContext context) async {
    if (widget.disabled) return;

    setState(() => _hasBeenTouched = true);

    final currentSelection = _selectedDateTime ?? DateTime.now();

    DateTime datePart = currentSelection;
    TimeOfDay timePart = TimeOfDay.fromDateTime(currentSelection);

    // Date Picker
    if (widget.mode == DateTimePickerMode.date || 
        widget.mode == DateTimePickerMode.dateTime) {
      final pickedDate = await showDatePicker(
        context: context,
        initialDate: currentSelection,
        firstDate: widget.firstDate ?? DateTime(1900),
        lastDate: widget.lastDate ?? DateTime(2101),
        builder: (dialogContext, child) =>
            _buildThemedPicker(dialogContext, child!),
      );

      if (!mounted) return;
      if (pickedDate == null) return;

      datePart = pickedDate;
    }

    // Time Picker
    if (widget.mode == DateTimePickerMode.time || 
        widget.mode == DateTimePickerMode.dateTime) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: timePart,
        builder: (dialogContext, child) =>
            _buildThemedPicker(dialogContext, child!),
      );

      if (!mounted) return;
      if (pickedTime == null) return;

      // Validate time constraints
      if (!pickedTime.isWithinConstraints(widget.timeConstraints)) {
        if (mounted) {
          _showTimeConstraintError(context);
        }
        return;
      }

      timePart = pickedTime;
    }

    final finalDateTime = DateTime(
      datePart.year,
      datePart.month,
      datePart.day,
      timePart.hour,
      timePart.minute,
    );

    // Validate date range
    if (!finalDateTime.isWithinRange(widget.firstDate, widget.lastDate)) {
      if (mounted) {
        _showDateConstraintError(context);
      }
      return;
    }

    if (mounted) {
      setState(() => _selectedDateTime = finalDateTime);
      widget.onDateTimeChanged?.call(finalDateTime);
    }
  }

  Widget _buildThemedPicker(BuildContext dialogContext, Widget child) {
    final dialogWebbTheme = dialogContext;
    return Theme(
      data: Theme.of(dialogContext).copyWith(
        colorScheme: Theme.of(dialogContext).colorScheme.copyWith(
              primary: dialogWebbTheme.colorPalette.primary,
              onPrimary: dialogWebbTheme.colorPalette.onPrimary,
              surface: dialogWebbTheme.colorPalette.surface,
              onSurface: dialogWebbTheme.colorPalette.onSurface,
            ),
      ),
      child: child,
    );
  }

  void _showTimeConstraintError(BuildContext context) {
    final webbTheme = context;
    ScaffoldMessenger.of(context).showSnackBar(
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

  void _showDateConstraintError(BuildContext context) {
    final webbTheme = context;
    ScaffoldMessenger.of(context).showSnackBar(
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
            child: Row(
              children: [
                Text(widget.label!, style: webbTheme.typography.labelMedium),
                if (widget.required)
                  Padding(
                    padding: EdgeInsets.only(
                        left: webbTheme.spacingGrid.spacing(0.5)),
                    child: Text('*',
                        style: webbTheme.typography.labelMedium.copyWith(
                          color: webbTheme.colorPalette.error,
                        )),
                  ),
              ],
            ),
          ),

        // Picker Input
        InkWell(
          onTap: () => _showPicker(context),
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
                          ? webbTheme.colorPalette.neutralDark.withOpacity(0.5)
                          : webbTheme.colorPalette.neutralDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (suffixIcon != null)
                  Padding(
                    padding:
                        EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
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
    );
  }
}
