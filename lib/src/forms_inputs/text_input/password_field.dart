import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'input_decoration.dart';
import 'validation_states.dart';

class WebbUIPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final bool disabled;

  const WebbUIPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.disabled = false,
  });

  @override
  State<WebbUIPasswordField> createState() => _WebbUIPasswordFieldState();
}

class _WebbUIPasswordFieldState extends State<WebbUIPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    // 1. Define the custom suffix icon (visibility toggle)
    final Widget suffixIcon = IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        size: webbTheme.iconTheme.mediumSize,
      ),
      onPressed: widget.disabled
          ? null // Disable toggle if the field is disabled
          : () => setState(() => _obscureText = !_obscureText),
      color: webbTheme.colorPalette.neutralDark,
      splashRadius: webbTheme.iconTheme.mediumSize / 2,
    );

    // 2. Generate the theme-consistent decoration using the utility class's getDecoration() method.
    final InputDecoration decoration = WebbUIInputDecoration(
      webbTheme: webbTheme,
      label: widget.label,
      hintText: widget.hintText,
      validationState: widget.validationState,
      validationMessage: widget.validationMessage,
      suffixIcon: suffixIcon, // Inject the custom suffix icon here
      maxLines: 1, // Always 1 for password fields
    ).getDecoration();

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      enabled: !widget.disabled,
      keyboardType: TextInputType.visiblePassword,
      decoration: decoration,
      style: webbTheme.typography.bodyMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark),
    );
  }
}
