import 'package:flutter/material.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'package:webb_ui/src/theme.dart';

/// A component for increasing or decreasing a number value within a defined range.
class WebbUINumberStepper extends StatefulWidget {
  final int initialValue;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;

  const WebbUINumberStepper({
    super.key,
    this.initialValue = 0,
    this.onChanged,
    this.min = 0,
    this.max = 100,
  });

  @override
  State<WebbUINumberStepper> createState() => _WebbUINumberStepperState();
}

class _WebbUINumberStepperState extends State<WebbUINumberStepper> {
  late int _value;

  @override
  void initState() {
    super.initState();
    // Ensure initial value respects min/max constraints
    _value = widget.initialValue.clamp(widget.min, widget.max);
  }

  // Use didUpdateWidget to handle external changes to initialValue, min, or max
  @override
  void didUpdateWidget(covariant WebbUINumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue ||
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max) {
      _value = widget.initialValue.clamp(widget.min, widget.max);
    }
  }

  void _increment() {
    if (_value < widget.max) {
      setState(() => _value++);
      widget.onChanged?.call(_value);
    }
  }

  void _decrement() {
    if (_value > widget.min) {
      setState(() => _value--);
      widget.onChanged?.call(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double touchTarget = webbTheme.accessibility.minTouchTargetSize;

    // Determine if the buttons should be enabled
    final bool canDecrement = _value > widget.min;
    final bool canIncrement = _value < widget.max;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // --- Decrement Button ---
        WebbUIIconButton(
          icon: Icons.remove,
          onPressed: canDecrement ? _decrement : null, // Disable if at min
        ),

        // --- Value Display ---
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: webbTheme.spacingGrid.spacing(0.5),
          ),
          child: Container(
            constraints: BoxConstraints(minWidth: touchTarget * 1.5),
            padding: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(1.5),
              vertical: webbTheme.spacingGrid.spacing(0.5),
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: webbTheme.colorPalette.neutralLight.withOpacity(0.9),
              border: Border.all(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.3),
                  width: 1),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            ),
            child: Text(
              '$_value',
              style: webbTheme.typography.bodyLarge.copyWith(
                color: webbTheme.colorPalette.neutralDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // --- Increment Button ---
        WebbUIIconButton(
          icon: Icons.add,
          onPressed: canIncrement ? _increment : null, // Disable if at max
        ),
      ],
    );
  }
}
