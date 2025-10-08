import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUISlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;

  const WebbUISlider({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Slider(
      value: value,
      onChanged: onChanged,
      min: min,
      max: max,
      activeColor: webbTheme.colorPalette.primary,
      inactiveColor: webbTheme.colorPalette.neutralLight.withOpacity(0.5),
      thumbColor: Colors.white,
      overlayColor:
          WidgetStateProperty.all(webbTheme.interactionStates.hoverOverlay),
      focusNode: FocusNode(), // For focused border if needed
    );
  }
}
