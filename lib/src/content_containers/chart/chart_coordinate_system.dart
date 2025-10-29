import 'package:flutter/material.dart';
import 'chart_definitions.dart';
// import 'dart:collection';

/// Handles coordinate system transformations between data space and pixel space.
/// This is the core of the chart's rendering system, now with support for category axes,
/// optimized nearest point search, and reverse transformations.
class ChartCoordinateSystem {
  final ChartBounds bounds;
  final Size size;
  final double scale;
  final Offset panOffset;
  final double leftPadding;
  final double rightPadding;
  final double topPadding;
  final double bottomPadding;
  final AxisType xAxisType;

  const ChartCoordinateSystem({
    required this.bounds,
    required this.size,
    this.scale = 1.0,
    this.panOffset = Offset.zero,
    required this.leftPadding,
    required this.rightPadding,
    required this.topPadding,
    required this.bottomPadding,
    this.xAxisType = AxisType.numeric, // Default to numeric
  });

  /// Converts a data x-value to pixel x-coordinate.
  /// Handles numeric, dateTime, and category types.
  double getPixelX(dynamic x) {
    double xVal;
    if (xAxisType == AxisType.category) {
      // For categories, map string to index position
      final categories = bounds.categories ?? [];
      final index = categories.indexOf(x.toString());
      if (index == -1) return leftPadding; // Fallback if not found
      xVal = index.toDouble();
    } else {
      xVal = x is DateTime
          ? x.millisecondsSinceEpoch.toDouble()
          : (x as num).toDouble();
    }

    final double range = bounds.xRange / scale;
    if (range == 0) return leftPadding;

    final double viewMinX = bounds.minX -
        (panOffset.dx / (size.width - leftPadding - rightPadding)) * range;

    return leftPadding +
        ((xVal - viewMinX) / range) * (size.width - leftPadding - rightPadding);
  }

  /// Converts a data y-value to pixel y-coordinate.
  /// Now properly handles negative values by allowing minY < 0.
  double getPixelY(double y) {
    final double range = bounds.yRange / scale;
    if (range == 0) return size.height - bottomPadding;

    final double viewMinY = bounds.minY +
        (panOffset.dy / (size.height - topPadding - bottomPadding)) * range;

    return (size.height - bottomPadding) -
        ((y - viewMinY) / range) * (size.height - topPadding - bottomPadding);
  }

  /// Converts a pixel x-coordinate back to data x-value (reverse transformation).
  /// Useful for advanced interactions like custom tooltips or selections.
  dynamic getDataX(double pixelX) {
    final double normalizedX =
        (pixelX - leftPadding) / (size.width - leftPadding - rightPadding);
    final double range = bounds.xRange / scale;
    final double viewMinX = bounds.minX -
        (panOffset.dx / (size.width - leftPadding - rightPadding)) * range;
    final double xVal = viewMinX + normalizedX * range;

    if (xAxisType == AxisType.dateTime) {
      return DateTime.fromMillisecondsSinceEpoch(xVal.toInt());
    } else if (xAxisType == AxisType.category) {
      final categories = bounds.categories ?? [];
      final index = xVal.round();
      return index >= 0 && index < categories.length ? categories[index] : null;
    } else {
      return xVal;
    }
  }

  /// Converts a pixel y-coordinate back to data y-value.
  double getDataY(double pixelY) {
    final double normalizedY =
        1 - (pixelY - topPadding) / (size.height - topPadding - bottomPadding);
    final double range = bounds.yRange / scale;
    final double viewMinY = bounds.minY +
        (panOffset.dy / (size.height - topPadding - bottomPadding)) * range;
    return viewMinY + normalizedY * range;
  }

  /// Gets the chart area size (excluding padding).
  Size get chartAreaSize => Size(
        size.width - leftPadding - rightPadding,
        size.height - topPadding - bottomPadding,
      );

  /// Checks if a point is within the chart area.
  bool isPointInChartArea(Offset point) {
    return point.dx >= leftPadding &&
        point.dx <= size.width - rightPadding &&
        point.dy >= topPadding &&
        point.dy <= size.height - bottomPadding;
  }

  /// Finds the nearest data point to a pixel position.
  /// Optimized: Assumes data is sorted by x; uses binary search for efficiency on large datasets.
  ({ChartData? point, ChartSeries? series, double distance}) findNearestPoint(
    Offset pixelPosition,
    List<ChartSeries> series,
  ) {
    ChartData? nearestPoint;
    ChartSeries? nearestSeries;
    double minDistance = double.infinity;

    for (final s in series.where((s) => s.visible)) {
      if (s.data.isEmpty) continue;

      // Assume data sorted by x; find approximate index via binary search
      final int approxIndex = _binarySearch(s.data, getDataX(pixelPosition.dx));
      final int start = (approxIndex - 5).clamp(0, s.data.length - 1);
      final int end = (approxIndex + 5).clamp(0, s.data.length - 1);

      for (int i = start; i <= end; i++) {
        final p = s.data[i];
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

  /// Helper for binary search on sorted data points by x-value.
  int _binarySearch(List<ChartData> data, dynamic targetX) {
    int low = 0;
    int high = data.length - 1;
    double targetVal = targetX is DateTime
        ? targetX.millisecondsSinceEpoch.toDouble()
        : (targetX as num).toDouble();

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      double midVal = data[mid].x is DateTime
          ? (data[mid].x as DateTime).millisecondsSinceEpoch.toDouble()
          : (data[mid].x as num).toDouble();

      if (midVal < targetVal) {
        low = mid + 1;
      } else if (midVal > targetVal) {
        high = mid - 1;
      } else {
        return mid;
      }
    }
    return low;
  }
}
