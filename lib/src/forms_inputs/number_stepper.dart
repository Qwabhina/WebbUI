import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

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
    _value = widget.initialValue;
  }

  void _increment() {
    if (_value < widget.max) {
      setState(() => _value++);
      if (widget.onChanged != null) widget.onChanged!(_value);
    }
  }

  void _decrement() {
    if (_value > widget.min) {
      setState(() => _value--);
      if (widget.onChanged != null) widget.onChanged!(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WebbUIIconButton(icon: Icons.remove, onPressed: _decrement),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(2)),
          child: Text('$_value', style: webbTheme.typography.bodyLarge),
        ),
        WebbUIIconButton(icon: Icons.add, onPressed: _increment),
      ],
    );
  }
}
