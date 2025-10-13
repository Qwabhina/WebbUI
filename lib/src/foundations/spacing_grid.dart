import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

import 'breakpoints.dart';

/// Defines spacing and grid system for WebbUI, responsive to breakpoints.
class WebbUISpacingGrid extends ThemeExtension<WebbUISpacingGrid> {
  final double baseSpacing; // Base unit, e.g., 8.0
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double gutter;

  const WebbUISpacingGrid({
    required this.baseSpacing,
    required this.mobileColumns,
    required this.tabletColumns,
    required this.desktopColumns,
    required this.gutter,
  });

  /// Default values.
  static const WebbUISpacingGrid defaultSpacingGrid = WebbUISpacingGrid(
    baseSpacing: 8.0,
    mobileColumns: 4,
    tabletColumns: 8,
    desktopColumns: 12,
    gutter: 16.0,
  );

  /// Helper to get responsive columns based on context.
  static int getColumns(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final WebbUISpacingGrid grid =
        Theme.of(context).extension<WebbUISpacingGrid>() ?? defaultSpacingGrid;
  
    if (WebbUIBreakpoints.isMobile(width)) return grid.mobileColumns;
    if (WebbUIBreakpoints.isTablet(width)) return grid.tabletColumns;
    return grid.desktopColumns;
  }

  /// Helper for responsive spacing: multiples of baseSpacing.
  double spacing(num multiplier) => baseSpacing * multiplier;

  @override
  WebbUISpacingGrid copyWith({
    double? baseSpacing,
    int? mobileColumns,
    int? tabletColumns,
    int? desktopColumns,
    double? gutter,
  }) {
    return WebbUISpacingGrid(
      baseSpacing: baseSpacing ?? this.baseSpacing,
      mobileColumns: mobileColumns ?? this.mobileColumns,
      tabletColumns: tabletColumns ?? this.tabletColumns,
      desktopColumns: desktopColumns ?? this.desktopColumns,
      gutter: gutter ?? this.gutter,
    );
  }

  @override
  WebbUISpacingGrid lerp(ThemeExtension<WebbUISpacingGrid>? other, double t) {
    if (other is! WebbUISpacingGrid) {
      return this;
    }
    return WebbUISpacingGrid(
      baseSpacing: lerpDouble(baseSpacing, other.baseSpacing, t)!,
      mobileColumns:
          (mobileColumns + (other.mobileColumns - mobileColumns) * t).round(),
      tabletColumns:
          (tabletColumns + (other.tabletColumns - tabletColumns) * t).round(),
      desktopColumns:
          (desktopColumns + (other.desktopColumns - desktopColumns) * t)
              .round(),
      gutter: lerpDouble(gutter, other.gutter, t)!,
    );
  }
}
