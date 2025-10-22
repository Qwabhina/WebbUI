import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';

/// Paints the chart grid and axes with proper theming
class ChartGridPainter {
  final ChartConfig config;
  final BuildContext webbTheme;

  const ChartGridPainter({
    required this.config,
    required this.webbTheme,
  });

  /// Paints the complete grid system (grid lines and axes)
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

    // Vertical grid lines
    const int xGridCount = 5;
    for (int i = 0; i <= xGridCount; i++) {
      final double val =
          coordSystem.bounds.minX + coordSystem.bounds.xRange * i / xGridCount;
      final double x = coordSystem.getPixelX(val);

      canvas.drawLine(
        Offset(x, coordSystem.topPadding),
        Offset(x, size.height - coordSystem.bottomPadding),
        gridPaint,
      );
    }

    // Horizontal grid lines
    const int yGridCount = 5;
    for (int i = 0; i <= yGridCount; i++) {
      final double val =
          coordSystem.bounds.minY + coordSystem.bounds.yRange * i / yGridCount;
      final double y = coordSystem.getPixelY(val);

      canvas.drawLine(
        Offset(coordSystem.leftPadding, y),
        Offset(size.width - coordSystem.rightPadding, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size, ChartCoordinateSystem coordSystem) {
    final axisPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.4)
      ..strokeWidth = 1.5;

    // X-axis
    canvas.drawLine(
      Offset(coordSystem.leftPadding, size.height - coordSystem.bottomPadding),
      Offset(size.width - coordSystem.rightPadding,
          size.height - coordSystem.bottomPadding),
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

    // Y-axis labels
    const int yLabelCount = 5;
    for (int i = 0; i <= yLabelCount; i++) {
      final double val =
          coordSystem.bounds.minY + coordSystem.bounds.yRange * i / yLabelCount;
      final double y = coordSystem.getPixelY(val);

      final textPainter = TextPainter(
        text: TextSpan(
          text: val.toStringAsFixed(0),
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

    // X-axis labels
    const int xLabelCount = 5;
    for (int i = 0; i <= xLabelCount; i++) {
      final double val =
          coordSystem.bounds.minX + coordSystem.bounds.xRange * i / xLabelCount;
      final double x = coordSystem.getPixelX(val);

      String label;
      // In a real implementation, you'd use the actual xAxisType
      // For now, we'll format based on value
      if (val > 1000000000000) {
        // Likely a timestamp
        final date = DateTime.fromMillisecondsSinceEpoch(val.toInt());
        label = '${date.month}/${date.day}';
      } else {
        label = val.toStringAsFixed(1);
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
}
