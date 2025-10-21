import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'validation_states.dart';

/// A factory class that creates consistent InputDecoration for WebbUI text fields.
/// This encapsulates all theming logic and ensures visual consistency.
class WebbUIInputDecoration {
  /// Creates a standard InputDecoration for WebbUI text fields
  static InputDecoration create({
    required BuildContext context,
    String? label,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    WebbUIValidationState validationState = WebbUIValidationState.none,
    String? validationMessage,
    int maxLines = 1,
    int? maxLength,
    int? currentLength,
    bool isFocused = false,
    bool isDisabled = false,
  }) {
    final webbTheme = context;
    
    // Determine colors based on state
    final Color borderColor = _getBorderColor(
      context,
      validationState,
      isDisabled,
    );
    final Color labelColor = _getLabelColor(
      context,
      isFocused,
      isDisabled,
    );

    // Content padding based on single-line vs multi-line
    final verticalPadding =
        webbTheme.spacingGrid.spacing(maxLines > 1 ? 2 : 1.5);

    // Build counter widget if maxLength is provided
    Widget? counterWidget;
    if (maxLength != null) {
      counterWidget = _buildCounterWidget(context, currentLength, maxLength);
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

      // Borders
      border: _buildBorder(context, borderColor, 1),
      enabledBorder: _buildBorder(context, borderColor, 1),
      focusedBorder: _buildBorder(
        context,
        webbTheme.interactionStates.focusedBorder,
        2,
      ),
      disabledBorder: _buildBorder(
        context,
        webbTheme.interactionStates.disabledColor,
        1,
      ),
      errorBorder: _buildBorder(context, webbTheme.colorPalette.error, 1),
      focusedErrorBorder:
          _buildBorder(context, webbTheme.colorPalette.error, 2),

      // Fill color
      filled: isDisabled,
      fillColor: isDisabled
          ? webbTheme.colorPalette.neutralDark.withOpacity(0.05)
          : null,
    );
  }

  static Color _getBorderColor(
    BuildContext context,
    WebbUIValidationState validationState,
    bool isDisabled,
  ) {
    final webbTheme = context;
    
    if (isDisabled) {
      return webbTheme.interactionStates.disabledColor;
    }

    switch (validationState) {
      case WebbUIValidationState.success:
        return webbTheme.colorPalette.success;
      case WebbUIValidationState.error:
        return webbTheme.colorPalette.error;
      case WebbUIValidationState.warning:
        return webbTheme.colorPalette.warning;
      default:
        return webbTheme.colorPalette.neutralDark.withOpacity(0.3);
    }
  }

  static Color _getLabelColor(
    BuildContext context,
    bool isFocused,
    bool isDisabled,
  ) {
    final webbTheme = context;
    
    if (isDisabled) {
      return webbTheme.interactionStates.disabledColor;
    }
    if (isFocused) {
      return webbTheme.interactionStates.focusedBorder;
    }
    return webbTheme.colorPalette.neutralDark;
  }

  static OutlineInputBorder _buildBorder(
    BuildContext context,
    Color color,
    double width,
  ) {
    final webbTheme = context;
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
      borderSide: BorderSide(color: color, width: width),
      gapPadding: 0,
    );
  }

  static Widget _buildCounterWidget(
    BuildContext context,
    int? currentLength,
    int maxLength,
  ) {
    final webbTheme = context;
    final bool isOverLimit = currentLength != null && currentLength > maxLength;
    
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
