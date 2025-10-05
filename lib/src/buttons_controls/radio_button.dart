import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIRadioButton<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;
  final String? label;

  const WebbUIRadioButton({
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          value: value,
          groupValue: groupValue,
          onChanged: onChanged,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return webbTheme.colorPalette.primary;
            }
            return webbTheme.colorPalette.neutralDark;
          }),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return webbTheme.interactionStates.pressedOverlay;
            }
            return null;
          }),
          focusColor: webbTheme.interactionStates.focusedBorder,
        ),
        if (label != null)
          Padding(
            padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
            child: Text(label!, style: webbTheme.typography.bodyMedium),
          ),
      ],
    );
  }
}
