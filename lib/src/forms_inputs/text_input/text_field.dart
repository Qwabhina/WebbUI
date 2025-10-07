import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'input_decoration.dart';
import 'validation_states.dart';

class WebbUITextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? helperText;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final int? maxLines;
  final ValueChanged<String>? onChanged;
  final bool disabled;
  final TextInputType keyboardType;
  final bool obscureText;

  const WebbUITextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.helperText,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.maxLines = 1,
    this.onChanged,
    this.disabled = false,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  /// Generates the appropriate validation icon widget.
  Widget? _buildSuffixIcon(BuildContext webbTheme) {
    if (validationState == WebbUIValidationState.none) {
      return null;
    }

    final Color iconColor = validationState == WebbUIValidationState.success
        ? webbTheme.colorPalette.success
        : webbTheme.colorPalette.error;

    final IconData iconData = validationState == WebbUIValidationState.success
        ? Icons.check_circle
        : Icons.error;

    return Icon(
      iconData,
      color: iconColor,
      size: webbTheme.iconTheme.mediumSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    // The suffix icon is now only the validation icon.
    final Widget? suffixIcon = _buildSuffixIcon(webbTheme);

    // Generate the theme-consistent decoration using the utility class's getDecoration() method.
    final InputDecoration decoration = WebbUIInputDecoration(
      webbTheme: webbTheme,
      label: label,
      hintText: hintText,
      helperText: helperText,
      suffixIcon: suffixIcon,
      validationState: validationState,
      validationMessage: validationMessage,
      maxLines: maxLines,
    ).getDecoration();

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: !disabled,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: decoration,
      style: webbTheme.typography.bodyMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark),
    );
  }
}
