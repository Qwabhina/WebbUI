import 'package:flutter/material.dart';
import 'foundations/foundations.dart';

/// Extension on BuildContext for easy access to WebbUI theme properties
extension WebbUITheme on BuildContext {
  WebbUIColorPalette get colorPalette =>
      Theme.of(this).extension<WebbUIColorPalette>() ??
      WebbUIColorPalette.defaultPalette;

  WebbUITypography get typographyBase =>
      Theme.of(this).extension<WebbUITypography>() ??
      WebbUITypography.defaultTypography;

  WebbUITypography get typography => typographyBase.scaleWithContext(this);

  WebbUISpacingGrid get spacingGrid =>
      Theme.of(this).extension<WebbUISpacingGrid>() ??
      WebbUISpacingGrid.defaultSpacingGrid;

  WebbUIIconTheme get iconTheme {
    final base = Theme.of(this).extension<WebbUIIconTheme>() ??
        WebbUIIconTheme.defaultIconTheme;
    return base.scaleWithContext(this);
  }

  WebbUIElevation get elevation =>
      Theme.of(this).extension<WebbUIElevation>() ??
      WebbUIElevation.defaultElevation;

  WebbUIInteractionStates get interactionStates =>
      Theme.of(this).extension<WebbUIInteractionStates>() ??
      WebbUIInteractionStates.defaultStates;

  WebbUIAccessibility get accessibility =>
      Theme.of(this).extension<WebbUIAccessibility>() ??
      WebbUIAccessibility.defaultAccessibility;
}

/// Complete TextTheme integration for Material 3 compatibility
TextTheme _buildTextTheme(WebbUITypography typography) {
  return TextTheme(
    displayLarge: typography.displayLarge,
    displayMedium: typography.displayMedium,
    displaySmall: typography.headlineLarge, // Fallback
    headlineLarge: typography.headlineLarge,
    headlineMedium: typography.headlineMedium,
    headlineSmall: typography.bodyLarge, // Fallback
    titleLarge: typography.labelLarge,
    titleMedium: typography.labelMedium,
    titleSmall: typography.labelSmall,
    bodyLarge: typography.bodyLarge,
    bodyMedium: typography.bodyMedium,
    bodySmall: typography.labelMedium, // Fallback
    labelLarge: typography.labelLarge,
    labelMedium: typography.labelMedium,
    labelSmall: typography.labelSmall,
  );
}

/// Helper to create a light theme with WebbUI defaults
ThemeData webbUILightTheme({Color? seedColor}) {
  const baseTypography = WebbUITypography.defaultTypography;
  final palette = seedColor != null
      ? WebbUIColorPalette.defaultPalette.copyWith(primary: seedColor)
      : WebbUIColorPalette.defaultPalette;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.light,
    ),
    textTheme: _buildTextTheme(baseTypography),
    extensions: <ThemeExtension<dynamic>>[
      palette,
      WebbUITypography.defaultTypography,
      WebbUISpacingGrid.defaultSpacingGrid,
      WebbUIIconTheme.defaultIconTheme,
      WebbUIElevation.defaultElevation,
      WebbUIInteractionStates.defaultStates,
      WebbUIAccessibility.defaultAccessibility,
    ],
  );
}

/// Helper to create a dark theme with WebbUI dark variants
ThemeData webbUIDarkTheme({Color? seedColor}) {
  const baseTypography = WebbUITypography.defaultTypography;
  final palette = seedColor != null
      ? WebbUIColorPalette.darkPalette.copyWith(primary: seedColor)
      : WebbUIColorPalette.darkPalette;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: Brightness.dark,
    ),
    textTheme: _buildTextTheme(baseTypography),
    extensions: <ThemeExtension<dynamic>>[
      palette,
      WebbUITypography.defaultTypography,
      WebbUISpacingGrid.defaultSpacingGrid,
      WebbUIIconTheme.defaultDarkIconTheme,
      WebbUIElevation.defaultElevation,
      WebbUIInteractionStates.defaultDarkStates,
      WebbUIAccessibility.defaultAccessibility,
    ],
  );
}
