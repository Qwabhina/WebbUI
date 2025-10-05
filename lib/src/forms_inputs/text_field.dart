import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum WebbUIValidationState { none, success, error }

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
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    Color? borderColor;
    Color? iconColor;
    switch (validationState) {
      case WebbUIValidationState.success:
        borderColor = webbTheme.colorPalette.success;
        iconColor = webbTheme.colorPalette.success;
        break;
      case WebbUIValidationState.error:
        borderColor = webbTheme.colorPalette.error;
        iconColor = webbTheme.colorPalette.error;
        break;
      default:
        borderColor = webbTheme.colorPalette.neutralDark.withOpacity(0.3);
        iconColor = null;
    }

    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      enabled: !disabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: webbTheme.typography.labelLarge
            .copyWith(color: webbTheme.colorPalette.neutralDark),
        hintText: hintText,
        hintStyle: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),
        helperText: helperText,
        helperStyle: webbTheme.typography.labelMedium.copyWith(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.8)),
        errorText: validationState == WebbUIValidationState.error
            ? validationMessage
            : null,
        errorStyle: webbTheme.typography.labelMedium
            .copyWith(color: webbTheme.colorPalette.error),
        suffixIcon: validationState != WebbUIValidationState.none
            ? Icon(
                validationState == WebbUIValidationState.success
                    ? Icons.check_circle
                    : Icons.error,
                color: iconColor,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: webbTheme.interactionStates.focusedBorder, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: webbTheme.interactionStates.disabledColor),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: webbTheme.spacingGrid.spacing(2),
          vertical: webbTheme.spacingGrid.spacing(maxLines! > 1 ? 2 : 1),
        ),
      ),
      style: webbTheme.typography.bodyMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark),
    );
  }
}
