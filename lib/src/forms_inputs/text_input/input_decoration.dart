import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'validation_states.dart';

/// A private utility class that encapsulates all the shared [InputDecoration]
/// logic and theming for WebbUI text input fields.
///
/// This ensures consistency across [WebbUITextField], [WebbUIPasswordField],
/// and any future input fields by acting as a single factory for [InputDecoration].
class WebbUIInputDecoration {
  const WebbUIInputDecoration({
    required this.webbTheme,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.maxLines = 1,
    this.maxLength,
    this.currentLength,
    this.isFocused = false,
    this.isDisabled = false,
  });

  final BuildContext webbTheme;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final int? maxLines;
  final int? maxLength;
  final int? currentLength;
  final bool isFocused;
  final bool isDisabled;

  /// Returns a fully themed [InputDecoration] object.
  InputDecoration getDecoration() {
    // Changed from build(BuildContext context) to getDecoration()
    // 1. Determine border and icon color based on validation state
    // Determine colors based on state
    final Color borderColor = _getBorderColor();
    // final Color textColor = _getTextColor();
    final Color labelColor = _getLabelColor();

    // 2. Determine content padding based on single-line vs multi-line
    // We use the stored webbTheme context to access theme properties.
    // Content padding based on single-line vs multi-line
    final verticalPadding =
        webbTheme.spacingGrid.spacing(maxLines! > 1 ? 2 : 1.5);

    // 3. Construct and return the standard InputDecoration
    // Build counter widget if maxLength is provided
    Widget? counterWidget;
    if (maxLength != null) {
      counterWidget = _buildCounterWidget();
    }

    return InputDecoration(
      // Labels and Text
      labelText: label,
      labelStyle: webbTheme.typography.labelLarge.copyWith(color: labelColor),
      hintText: hintText,
      hintStyle: webbTheme.typography.bodyMedium.copyWith(
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
      ),

      // Icons
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,

      // Helper and error text
      helperText: helperText,
      helperStyle: webbTheme.typography.labelMedium.copyWith(
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.8),
      ),
      errorText: validationState == WebbUIValidationState.error
          ? validationMessage 
          : null,
      errorStyle: webbTheme.typography.labelMedium.copyWith(
        color: webbTheme.colorPalette.error,
      ),
      errorMaxLines: 2,

      // Counter
      counter: counterWidget,
      counterText: '', // Hide default counter

      // Padding
      contentPadding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: verticalPadding,
      ),

      // Standard Border (The base border color changes based on validation state)
      // Borders
      border: _buildBorder(borderColor, 1),
      enabledBorder: _buildBorder(borderColor, 1),
      focusedBorder: _buildBorder(
        webbTheme.interactionStates.focusedBorder,
        2,
      ),
      // Focused Border (Always uses the themed focused border color)
      disabledBorder: _buildBorder(
        webbTheme.interactionStates.disabledColor,
        1,
      ),
      errorBorder: _buildBorder(webbTheme.colorPalette.error, 1),
      focusedErrorBorder: _buildBorder(webbTheme.colorPalette.error, 2),

      // Disabled Border (Always uses the themed disabled color)
      // Fill color
      filled: isDisabled,
      fillColor: isDisabled
          ? webbTheme.colorPalette.neutralDark.withOpacity(0.05)
          : null,
    );
  }

      // Error Border uses the standard border logic with error color
  Color _getBorderColor() {
    if (isDisabled) {
      return webbTheme.interactionStates.disabledColor;
    }

    switch (validationState) {
      case WebbUIValidationState.success:
        return webbTheme.colorPalette.success;
      case WebbUIValidationState.error:
        return webbTheme.colorPalette.error;
      default:
        return webbTheme.colorPalette.neutralDark.withOpacity(0.3);
    }
  }

      // Focused Error Border (Error border remains focused on error color)
  // Color _getTextColor() {
  //   if (isDisabled) {
  //     return webbTheme.interactionStates.disabledColor;
  //   }
  //   return webbTheme.colorPalette.neutralDark;
  // }

  Color _getLabelColor() {
    if (isDisabled) {
      return webbTheme.interactionStates.disabledColor;
    }
    if (isFocused) {
      return webbTheme.interactionStates.focusedBorder;
    }
    return webbTheme.colorPalette.neutralDark;
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
      borderSide: BorderSide(color: color, width: width),
      gapPadding: 0,
    );
  }

  Widget _buildCounterWidget() {
    final bool isOverLimit = currentLength != null &&
        maxLength != null &&
        currentLength! > maxLength!;
    
    return Padding(
      padding: EdgeInsets.only(
        top: webbTheme.spacingGrid.spacing(0.5),
      ),
      child: Text(
        '${currentLength ?? 0}/$maxLength',
        style: webbTheme.typography.labelMedium.copyWith(
          color: isOverLimit
              ? webbTheme.colorPalette.error
              : webbTheme.colorPalette.neutralDark.withOpacity(0.6),
        ),
      ),
    );
  }
}
