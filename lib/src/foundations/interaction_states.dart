import 'package:flutter/material.dart';

/// Defines interaction states for WebbUI components.
class WebbUIInteractionStates extends ThemeExtension<WebbUIInteractionStates> {
  final Color hoverOverlay;
  final Color pressedOverlay;
  final Color focusedBorder;
  final Color disabledColor;

  const WebbUIInteractionStates({
    required this.hoverOverlay,
    required this.pressedOverlay,
    required this.focusedBorder,
    required this.disabledColor,
  });

  /// Default light states.
  static const WebbUIInteractionStates defaultStates = WebbUIInteractionStates(
    hoverOverlay: Colors.black12, // Light overlay for hover
    pressedOverlay: Colors.black26, // Darker for pressed
    focusedBorder: Colors.blue, // Blue border for focus
    disabledColor: Colors.grey, // Grey for disabled
  );

  /// Default dark states, with white-based overlays for visibility.
  static const WebbUIInteractionStates defaultDarkStates =
      WebbUIInteractionStates(
    hoverOverlay: Colors.white12, // Light overlay for hover in dark
    pressedOverlay: Colors.white24, // Slightly stronger for pressed
    focusedBorder: Colors.blueAccent, // Brighter blue for focus
    disabledColor: Colors.black87, // Darker grey for disabled in dark
  );

  @override
  WebbUIInteractionStates copyWith({
    Color? hoverOverlay,
    Color? pressedOverlay,
    Color? focusedBorder,
    Color? disabledColor,
  }) {
    return WebbUIInteractionStates(
      hoverOverlay: hoverOverlay ?? this.hoverOverlay,
      pressedOverlay: pressedOverlay ?? this.pressedOverlay,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  WebbUIInteractionStates lerp(
      ThemeExtension<WebbUIInteractionStates>? other, double t) {
    if (other is! WebbUIInteractionStates) {
      return this;
    }
    return WebbUIInteractionStates(
      hoverOverlay: Color.lerp(hoverOverlay, other.hoverOverlay, t)!,
      pressedOverlay: Color.lerp(pressedOverlay, other.pressedOverlay, t)!,
      focusedBorder: Color.lerp(focusedBorder, other.focusedBorder, t)!,
      disabledColor: Color.lerp(disabledColor, other.disabledColor, t)!,
    );
  }
}
