import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final WebbUIValidationState validationState;
  final String? validationMessage;

  const WebbUIPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
  });

  @override
  State<WebbUIPasswordField> createState() => _WebbUIPasswordFieldState();
}

class _WebbUIPasswordFieldState extends State<WebbUIPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    Color? borderColor;
    switch (widget.validationState) {
      case WebbUIValidationState.success:
        borderColor = webbTheme.colorPalette.success;
        break;
      case WebbUIValidationState.error:
        borderColor = webbTheme.colorPalette.error;
        break;
      default:
        borderColor = webbTheme.colorPalette.neutralDark.withOpacity(0.3);
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: _obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: webbTheme.typography.labelLarge
            .copyWith(color: webbTheme.colorPalette.neutralDark),
        hintText: widget.hintText,
        hintStyle: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),
        errorText: widget.validationState == WebbUIValidationState.error
            ? widget.validationMessage
            : null,
        errorStyle: webbTheme.typography.labelMedium
            .copyWith(color: webbTheme.colorPalette.error),
        suffixIcon: IconButton(
          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureText = !_obscureText),
          color: webbTheme.colorPalette.neutralDark,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: webbTheme.interactionStates.focusedBorder, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: webbTheme.spacingGrid.spacing(2),
            vertical: webbTheme.spacingGrid.spacing(1)),
      ),
      style: webbTheme.typography.bodyMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark),
    );
  }
}
