import 'package:flutter/material.dart';
import 'foundations/foundations.dart';

/// Extension on BuildContext for easy access to WebbUI theme properties, with dynamic scaling.
extension WebbUITheme on BuildContext {
  WebbUIColorPalette get colorPalette =>
      Theme.of(this).extension<WebbUIColorPalette>() ??
      WebbUIColorPalette.defaultPalette;


  WebbUITypography get typographyBase =>
      Theme.of(this).extension<WebbUITypography>() ??
      WebbUITypography.defaultTypography;


  WebbUITypography get typography {
    return typographyBase.scaleWithContext(this);
  }


  WebbUISpacingGrid get spacingGrid =>
      Theme.of(this).extension<WebbUISpacingGrid>() ??
      WebbUISpacingGrid.defaultSpacingGrid;


  WebbUIIconTheme get iconTheme {
    final base = Theme.of(this).extension<WebbUIIconTheme>() ??
        WebbUIIconTheme.defaultIconTheme;
    return base.scaleWithContext(this); // Applies responsive scaling
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

/// Helper to create a light theme with WebbUI defaults.
ThemeData webbUILightTheme() {
  const baseTypography = WebbUITypography.defaultTypography;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WebbUIColorPalette.defaultPalette.primary,
    ),
    // Add this to integrate with Material widgets
    textTheme: TextTheme(
      displayLarge: baseTypography.displayLarge,
      displayMedium: baseTypography.displayMedium,
      headlineLarge: baseTypography.headlineLarge,
      headlineMedium: baseTypography.headlineMedium,
      bodyLarge: baseTypography.bodyLarge,
      bodyMedium: baseTypography.bodyMedium,
      labelLarge: baseTypography.labelLarge,
      labelMedium: baseTypography.labelMedium,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      WebbUIColorPalette.defaultPalette,
      WebbUITypography.defaultTypography,
      WebbUISpacingGrid.defaultSpacingGrid,
      WebbUIIconTheme.defaultIconTheme,
      WebbUIElevation.defaultElevation,
      WebbUIInteractionStates.defaultStates,
      WebbUIAccessibility.defaultAccessibility,
    ],
  );
}

/// Helper to create a dark theme with WebbUI dark variants.
ThemeData webbUIDarkTheme() {
  const baseTypography = WebbUITypography.defaultTypography;
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: WebbUIColorPalette.defaultPalette.primary,
    ),
    // Add this to integrate with Material widgets
    textTheme: TextTheme(
      displayLarge: baseTypography.displayLarge,
      displayMedium: baseTypography.displayMedium,
      headlineLarge: baseTypography.headlineLarge,
      headlineMedium: baseTypography.headlineMedium,
      bodyLarge: baseTypography.bodyLarge,
      bodyMedium: baseTypography.bodyMedium,
      labelLarge: baseTypography.labelLarge,
      labelMedium: baseTypography.labelMedium,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      WebbUIColorPalette.darkPalette,
      WebbUITypography
          .defaultTypography, // Same as light, scaling handles responsiveness
      WebbUISpacingGrid.defaultSpacingGrid,
      WebbUIIconTheme.defaultDarkIconTheme,
      WebbUIElevation
          .defaultElevation, // Shadows remain the same for simplicity
      WebbUIInteractionStates.defaultDarkStates,
      WebbUIAccessibility.defaultAccessibility,
    ],
  );
}
