import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const WebbUIToggleSwitch({
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
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: webbTheme.colorPalette.success,
          inactiveThumbColor: webbTheme.colorPalette.neutralDark,
          inactiveTrackColor:
              webbTheme.colorPalette.neutralLight.withOpacity(0.5),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return webbTheme.interactionStates.pressedOverlay;
            }
            if (states.contains(WidgetState.hovered)) {
              return webbTheme.interactionStates.hoverOverlay;
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
