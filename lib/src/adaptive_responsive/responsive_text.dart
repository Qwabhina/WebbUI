import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIResponsiveText extends StatelessWidget {
  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  const WebbUIResponsiveText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;
    TextStyle effectiveStyle = style ?? webbTheme.typography.bodyLarge;
    double fontSize = effectiveStyle.fontSize ?? 16.0;

    if (width < 600) {
      fontSize = fontSize * 0.9; // Slightly smaller on mobile
    } else if (width > 1024) {
      fontSize = fontSize * 1.1; // Slightly larger on desktop
    }

    return Text(
      data,
      style: effectiveStyle.copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
