import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final bool isIndeterminate;

  const WebbUIProgressBar({
    super.key,
    required this.value,
    this.isIndeterminate = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return LinearProgressIndicator(
      value: isIndeterminate ? null : value,
      backgroundColor: webbTheme.colorPalette.neutralLight.withOpacity(0.3),
      valueColor: AlwaysStoppedAnimation<Color>(webbTheme.colorPalette.primary),
      minHeight: 4.0,
    );
  }
}
