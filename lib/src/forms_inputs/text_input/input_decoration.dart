import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'validation_states.dart';

/// A private utility class that encapsulates all the shared [InputDecoration]
/// logic and theming for WebbUI text input fields.
///
/// This ensures consistency across [WebbUITextField], [WebbUIPasswordField],
/// and any future input fields by acting as a single factory for [InputDecoration].
class WebbUIInputDecoration {
  // Changed from StatelessWidget to a regular class
  const WebbUIInputDecoration({
    required this.webbTheme,
    this.label,
    this.hintText,
    this.helperText,
    this.suffixIcon,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.maxLines = 1,
  });

  final BuildContext webbTheme;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? suffixIcon;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final int? maxLines;

  /// Returns a fully themed [InputDecoration] object.
  InputDecoration getDecoration() {
    // Changed from build(BuildContext context) to getDecoration()
    // 1. Determine border and icon color based on validation state
    Color borderColor;
    switch (validationState) {
      case WebbUIValidationState.success:
        borderColor = webbTheme.colorPalette.success;
        break;
      case WebbUIValidationState.error:
        borderColor = webbTheme.colorPalette.error;
        break;
      default:
        borderColor = webbTheme.colorPalette.neutralDark.withOpacity(0.3);
    }

    // 2. Determine content padding based on single-line vs multi-line
    // We use the stored webbTheme context to access theme properties.
    final verticalPadding =
        webbTheme.spacingGrid.spacing(maxLines! > 1 ? 2 : 1.5);

    // 3. Construct and return the standard InputDecoration
    return InputDecoration(
      // Labels and Text
      labelText: label,
      labelStyle: webbTheme.typography.labelLarge
          .copyWith(color: webbTheme.colorPalette.neutralDark),
      hintText: hintText,
      hintStyle: webbTheme.typography.bodyMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),

      // Helper text and Error text (themed)
      helperText: helperText,
      helperStyle: webbTheme.typography.labelMedium
          .copyWith(color: webbTheme.colorPalette.neutralDark.withOpacity(0.8)),
      errorText: validationState == WebbUIValidationState.error
          ? validationMessage
          : null,
      errorStyle: webbTheme.typography.labelMedium
          .copyWith(color: webbTheme.colorPalette.error),

      // Icons
      suffixIcon: suffixIcon,

      // Padding
      contentPadding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: verticalPadding,
      ),

      // Standard Border (The base border color changes based on validation state)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
            webbTheme.spacingGrid.baseSpacing), // Consistent radius
        borderSide: BorderSide(color: borderColor, width: 1),
      ),

      // Focused Border (Always uses the themed focused border color)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        borderSide: BorderSide(
            color: webbTheme.interactionStates.focusedBorder, width: 2),
      ),

      // Disabled Border (Always uses the themed disabled color)
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        borderSide: BorderSide(
            color: webbTheme.interactionStates.disabledColor, width: 1),
      ),

      // Error Border uses the standard border logic with error color
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        borderSide: BorderSide(color: webbTheme.colorPalette.error, width: 1),
      ),

      // Focused Error Border (Error border remains focused on error color)
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        borderSide: BorderSide(color: webbTheme.colorPalette.error, width: 2),
      ),
    );
  }
}
