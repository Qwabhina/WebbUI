import 'package:flutter/material.dart';
import 'chart_definitions.dart';

/// Handles coordinate system transformations between data space and pixel space
/// This is the core of the chart's rendering system
class ChartCoordinateSystem {
  final ChartBounds bounds;
  final Size size;
  final double scale;
  final Offset panOffset;
  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;

  const ChartCoordinateSystem({
    required this.bounds,
    required this.size,
    this.scale = 1.0,
    this.panOffset = Offset.zero,
    required this.leftPadding,
    required this.rightPadding,
    required this.topPadding,
    required this.bottomPadding,
  });

  /// Converts a data x-value to pixel x-coordinate
  double getPixelX(dynamic x) {
    final double xVal = x is DateTime
        ? x.millisecondsSinceEpoch.toDouble()
        : (x as num).toDouble();

    final double range = bounds.xRange / scale;
    if (range == 0) return leftPadding;

    final double viewMinX = bounds.minX -
        (panOffset.dx / (size.width - leftPadding - rightPadding)) * range;

    return leftPadding +
        ((xVal - viewMinX) / range) * (size.width - leftPadding - rightPadding);
  }

  /// Converts a data y-value to pixel y-coordinate
  double getPixelY(double y) {
    final double range = bounds.yRange / scale;
    if (range == 0) return size.height - bottomPadding;

    final double viewMinY = bounds.minY +
        (panOffset.dy / (size.height - topPadding - bottomPadding)) * range;

    return (size.height - bottomPadding) -
        ((y - viewMinY) / range) * (size.height - topPadding - bottomPadding);
  }

  /// Gets the chart area size (excluding padding)
  Size get chartAreaSize => Size(
        size.width - leftPadding - rightPadding,
        size.height - topPadding - bottomPadding,
      );

  /// Checks if a point is within the chart area
  bool isPointInChartArea(Offset point) {
    return point.dx >= leftPadding &&
        point.dx <= size.width - rightPadding &&
        point.dy >= topPadding &&
        point.dy <= size.height - bottomPadding;
  }

  /// Finds the nearest data point to a pixel position
  ({ChartData? point, ChartSeries? series, double distance}) findNearestPoint(
    Offset pixelPosition,
    List<ChartSeries> series,
  ) {
    ChartData? nearestPoint;
    ChartSeries? nearestSeries;
    double minDistance = double.infinity;

    for (final s in series.where((s) => s.visible)) {
      for (final p in s.data) {
        final px = getPixelX(p.x);
        final py = getPixelY(p.y);
        final distance = (Offset(px, py) - pixelPosition).distance;

        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = p;
          nearestSeries = s;
        }
      }
    }

    return (point: nearestPoint, series: nearestSeries, distance: minDistance);
  }
}
