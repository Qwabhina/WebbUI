import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';

class WebbUITimePicker extends StatelessWidget {
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay>? onTimeSelected;
  final String? label;

  const WebbUITimePicker({
    super.key,
    this.initialTime,
    this.onTimeSelected,
    this.label,
  });

  Future<void> _showPicker(BuildContext context) async {
    final webbTheme = context;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
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
    if (picked != null && onTimeSelected != null) {
      onTimeSelected!(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebbUIButton(
      label: label ?? 'Select Time',
      onPressed: () => _showPicker(context),
      variant: WebbUIButtonVariant.secondary,
      icon: Icons.access_time,
    );
  }
}
