import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';

/// Handles tooltip and crosshair painting with proper positioning.
/// Improved with multi-series support at same x and customizable format.
class ChartTooltipPainter {
  final BuildContext webbTheme;

  const ChartTooltipPainter({required this.webbTheme});

  /// Paints crosshair lines and tooltip at the specified position.
  /// Now takes the full list of series for multi-series tooltips.
  void paint(
    Canvas canvas,
    Size size,
    ChartCoordinateSystem coordSystem,
    Offset tapPosition,
    ChartData? nearestPoint,
    List<ChartSeries> allSeries, // Changed to take full series list
  ) {
    if (nearestPoint == null) return;

    final pointX = coordSystem.getPixelX(nearestPoint.x);
    final pointY = coordSystem.getPixelY(nearestPoint.y);

    _drawCrosshair(canvas, size, coordSystem, pointX, pointY);
    _drawTooltip(
        canvas, size, pointX, pointY, nearestPoint, allSeries, coordSystem);
  }

  void _drawCrosshair(
    Canvas canvas,
    Size size,
    ChartCoordinateSystem coordSystem,
    double pointX,
    double pointY,
  ) {
    final crosshairPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Vertical line
    canvas.drawLine(
      Offset(pointX, coordSystem.topPadding),
      Offset(pointX, size.height - coordSystem.bottomPadding),
      crosshairPaint,
    );

    // Horizontal line
    canvas.drawLine(
      Offset(coordSystem.leftPadding, pointY),
      Offset(size.width - coordSystem.rightPadding, pointY),
      crosshairPaint,
    );
  }

  void _drawTooltip(
    Canvas canvas,
    Size size,
    double pointX,
    double pointY,
    ChartData point,
    List<ChartSeries> allSeries, // Use full list for multi-series
    ChartCoordinateSystem coordSystem,
  ) {
    // Find all points at same x for multi-series tooltip
    final allPoints = <String>[];
    for (final s in allSeries.where((s) => s.visible)) {
      final matching = s.data.firstWhere(
        (p) => p.x == point.x,
        orElse: () => const ChartData(null, 0), // Fallback if no match
      );
      if (matching.x != null) {
        allPoints.add('${s.name}: ${matching.y.toStringAsFixed(2)}');
      }
    }

    final tooltipText = "X: ${point.x}\n${allPoints.join('\n')}";

    final textSpan = TextSpan(
      text: tooltipText,
      style: webbTheme.typography.labelMedium.copyWith(
        color: webbTheme.colorPalette.onSurface,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final rectWidth = textPainter.width + 16;
    final rectHeight = textPainter.height + 8;
    double rectX = pointX + 15;
    double rectY = pointY - rectHeight / 2;

    // Adjust position to stay within bounds
    if (rectX + rectWidth > size.width) {
      rectX = pointX - rectWidth - 15;
    }
    if (rectY < 0) rectY = 0;
    if (rectY + rectHeight > size.height) {
      rectY = size.height - rectHeight;
    }

    final tooltipRect = Rect.fromLTWH(rectX, rectY, rectWidth, rectHeight);

    // Draw tooltip background
    final backgroundPaint = Paint()
      ..color = webbTheme.colorPalette.surface.withOpacity(0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        tooltipRect,
        Radius.circular(webbTheme.spacingGrid.baseSpacing),
      ),
      backgroundPaint,
    );

    // Draw tooltip border
    final borderPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.2)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        tooltipRect,
        Radius.circular(webbTheme.spacingGrid.baseSpacing),
      ),
      borderPaint,
    );

    // Draw text
    textPainter.paint(canvas, tooltipRect.topLeft + const Offset(8, 4));
  }
}
