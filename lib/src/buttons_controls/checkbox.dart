import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUICheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final String? label;

  const WebbUICheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          checkColor: Colors.white,
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return webbTheme.colorPalette.primary;
            }
            return webbTheme.colorPalette.neutralLight;
          }),
          side: BorderSide(color: webbTheme.colorPalette.neutralDark),
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
