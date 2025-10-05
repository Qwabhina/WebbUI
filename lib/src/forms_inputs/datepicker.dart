import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIDatePicker extends StatelessWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime>? onDateSelected;
  final String? label;

  const WebbUIDatePicker({
    super.key,
    this.initialDate,
    this.onDateSelected,
    this.label,
  });

  Future<void> _showPicker(BuildContext context) async {
    final webbTheme = context;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: webbTheme.colorPalette.primary,
            onPrimary: Colors.white,
            onSurface: webbTheme.colorPalette.neutralDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebbUIButton(
      label: label ?? 'Select Date',
      onPressed: () => _showPicker(context),
      variant: WebbUIButtonVariant.secondary,
      icon: Icons.calendar_today,
    );
  }
}
