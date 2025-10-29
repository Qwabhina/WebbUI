import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';
import 'dart:math' as math;

/// Paints the chart grid and axes with proper theming.
/// Now with dynamic tick intervals based on range for better adaptability.
class ChartGridPainter {
  final ChartConfig config;
  final BuildContext webbTheme;
  final AxisType xAxisType; // Added for type-specific labeling

  const ChartGridPainter({
    required this.config,
    required this.webbTheme,
    this.xAxisType = AxisType.numeric,
  });

  /// Paints the complete grid system (grid lines and axes).
  void paint(Canvas canvas, Size size, ChartCoordinateSystem coordSystem) {
    if (config.showGrid) {
      _drawGrid(canvas, size, coordSystem);
    }
    if (config.showAxes) {
      _drawAxes(canvas, size, coordSystem);
    }
    if (config.showLabels) {
      _drawLabels(canvas, size, coordSystem);
    }
  }

  void _drawGrid(Canvas canvas, Size size, ChartCoordinateSystem coordSystem) {
    final gridPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Dynamic vertical grid lines
    final xTicks = _calculateTicks(
      coordSystem.bounds.minX,
      coordSystem.bounds.maxX,
      config.gridTickCount,
    );
    for (final val in xTicks) {
      final double x = coordSystem.getPixelX(val);
      canvas.drawLine(
        Offset(x, coordSystem.topPadding),
        Offset(x, size.height - coordSystem.bottomPadding),
        gridPaint,
      );
    }

    // Dynamic horizontal grid lines
    final yTicks = _calculateTicks(
      coordSystem.bounds.minY,
      coordSystem.bounds.maxY,
      config.gridTickCount,
    );
    for (final val in yTicks) {
      final double y = coordSystem.getPixelY(val);
      canvas.drawLine(
        Offset(coordSystem.leftPadding, y),
        Offset(size.width - coordSystem.rightPadding, y),
        gridPaint,
      );
    }
  }

  /// Calculates nice tick values for a given range.
  List<double> _calculateTicks(double min, double max, int approxCount) {
    final range = max - min;
    if (range == 0) return [min];

    final double roughStep = range / (approxCount - 1);
    final double step = math.pow(10, math.log(roughStep).floor()).toDouble();
    final double first = (min / step).ceil() * step;
    final List<double> ticks = [];
    for (double val = first; val <= max; val += step) {
      ticks.add(val);
    }
    return ticks;
  }

  void _drawAxes(Canvas canvas, Size size, ChartCoordinateSystem coordSystem) {
    final axisPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.4)
      ..strokeWidth = 1.5;

    // X-axis at y=0 if minY < 0 < maxY, else at bottom
    double xAxisY = coordSystem.bounds.minY < 0 && coordSystem.bounds.maxY > 0
        ? coordSystem.getPixelY(0)
        : size.height - coordSystem.bottomPadding;

    canvas.drawLine(
      Offset(coordSystem.leftPadding, xAxisY),
      Offset(size.width - coordSystem.rightPadding, xAxisY),
      axisPaint,
    );

    // Y-axis
    canvas.drawLine(
      Offset(coordSystem.leftPadding, size.height - coordSystem.bottomPadding),
      Offset(coordSystem.leftPadding, coordSystem.topPadding),
      axisPaint,
    );
  }

  void _drawLabels(
      Canvas canvas, Size size, ChartCoordinateSystem coordSystem) {
    final labelStyle = webbTheme.typography.labelMedium.copyWith(
      color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
    );

    // Y-axis labels with dynamic ticks
    final yTicks = _calculateTicks(
      coordSystem.bounds.minY,
      coordSystem.bounds.maxY,
      config.gridTickCount,
    );
    for (final val in yTicks) {
      final double y = coordSystem.getPixelY(val);

      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatNumber(val),
          style: labelStyle,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          coordSystem.leftPadding - textPainter.width - 5,
          y - textPainter.height / 2,
        ),
      );
    }

    // X-axis labels with type-specific formatting
    final xTicks = _calculateTicks(
      coordSystem.bounds.minX,
      coordSystem.bounds.maxX,
      config.gridTickCount,
    );
    for (final val in xTicks) {
      final double x = coordSystem.getPixelX(val);

      String label;
      if (xAxisType == AxisType.category &&
          coordSystem.bounds.categories != null) {
        final index = val.round();
        label = coordSystem.bounds.categories![index];
      } else if (xAxisType == AxisType.dateTime) {
        final date = DateTime.fromMillisecondsSinceEpoch(val.toInt());
        label =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      } else {
        label = _formatNumber(val);
      }

      final textPainter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x - textPainter.width / 2,
          size.height - coordSystem.bottomPadding + 5,
        ),
      );
    }
  }

  /// Formats numbers nicely (e.g., with K/M for large values).
  String _formatNumber(double val) {
    if (val.abs() >= 1e6) return '${(val / 1e6).toStringAsFixed(1)}M';
    if (val.abs() >= 1e3) return '${(val / 1e3).toStringAsFixed(1)}K';
    return val.toStringAsFixed(val.abs() < 10 ? 1 : 0);
  }
}
