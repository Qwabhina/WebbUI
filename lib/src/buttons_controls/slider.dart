import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUISlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final bool disabled;

  const WebbUISlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: webbTheme.typography.bodyMedium.copyWith(
              color: disabled
                  ? webbTheme.interactionStates.disabledColor
                  : webbTheme.colorPalette.neutralDark,
            ),
          ),
          SizedBox(height: webbTheme.spacingGrid.spacing(1)),
        ],
        Slider(
          value: value,
          onChanged: disabled ? null : onChanged,
          onChangeEnd: disabled ? null : onChangeEnd,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: disabled
              ? webbTheme.interactionStates.disabledColor
              : webbTheme.colorPalette.primary,
          inactiveColor: webbTheme.colorPalette.neutralLight.withOpacity(
            disabled ? 0.2 : 0.5,
          ),
          thumbColor: Colors.white,
          overlayColor: WidgetStateProperty.all(
            webbTheme.interactionStates.hoverOverlay,
          ),
        ),
      ],
    );
  }
}
