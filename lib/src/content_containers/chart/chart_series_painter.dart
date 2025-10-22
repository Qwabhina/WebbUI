import 'dart:math';
import 'package:flutter/material.dart';
import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';

/// Base class for all series painters - uses strategy pattern for different chart types
abstract class ChartSeriesPainter {
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    ChartSeries series,
    ChartConfig config,
  );
}

/// Paints line charts with optional data points
class LineSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    ChartSeries series,
    ChartConfig config,
  ) {
    final paint = Paint()
      ..color = series.color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = <Offset>[];

    // Create path and collect points
    for (int i = 0; i < series.data.length; i++) {
      final p = series.data[i];
      final x = coordSystem.getPixelX(p.x);
      final y = coordSystem.getPixelY(p.y);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the line
    canvas.drawPath(path, paint);

    // Draw data points
    for (final point in points) {
      canvas.drawCircle(point, 3, Paint()..color = series.color);
    }
  }
}

/// Paints area charts (line with filled area below)
class AreaSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    ChartSeries series,
    ChartConfig config,
  ) {
    // First draw the line
    LineSeriesPainter().paint(canvas, coordSystem, series, config);

    // Then fill the area
    final paint = Paint()..color = series.color.withOpacity(0.3);
    final path = Path();

    if (series.data.isNotEmpty) {
      // Start at first point's x position at y=0
      path.moveTo(
        coordSystem.getPixelX(series.data.first.x),
        coordSystem.getPixelY(0),
      );

      // Draw line through all data points
      for (final p in series.data) {
        path.lineTo(
          coordSystem.getPixelX(p.x),
          coordSystem.getPixelY(p.y),
        );
      }

      // Close the path back to y=0 at the last point
      path.lineTo(
        coordSystem.getPixelX(series.data.last.x),
        coordSystem.getPixelY(0),
      );
      path.close();

      canvas.drawPath(path, paint);
    }
  }
}

/// Paints column/bar charts
class ColumnSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    ChartSeries series,
    ChartConfig config,
  ) {
    final paint = Paint()..color = series.color;
    final barWidth = coordSystem.chartAreaSize.width / (series.data.length * 2);

    for (final p in series.data) {
      final x = coordSystem.getPixelX(p.x);
      final y = coordSystem.getPixelY(p.y);
      final y0 = coordSystem.getPixelY(0);

      canvas.drawRect(
        Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, y0),
        paint,
      );
    }
  }
}

/// Paints pie/doughnut charts
class PieSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    ChartSeries series,
    ChartConfig config,
  ) {
    final center = Offset(
      coordSystem.size.width / 2,
      coordSystem.size.height / 2,
    );
    final radius = min(coordSystem.size.width, coordSystem.size.height) / 3;
    final total = series.data.fold<double>(0, (sum, p) => sum + p.y);

    if (total == 0) return;

    double startAngle = -pi / 2;

    for (final p in series.data) {
      final sweepAngle = (p.y / total) * 2 * pi;
      final paint = Paint()
        ..color = _getSegmentColor(series.color, series.data.indexOf(p));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Draw doughnut hole if needed
    if (series.chartType == ChartType.doughnut) {
      canvas.drawCircle(
        center,
        radius * 0.5,
        Paint()..color = Colors.white, // Should use theme background
      );
    }
  }

  Color _getSegmentColor(Color baseColor, int index) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withLightness((hsl.lightness + (index * 0.15)).clamp(0.3, 0.9))
        .toColor();
  }
}

/// Factory to get the appropriate painter for each chart type
class ChartSeriesPainterFactory {
  static ChartSeriesPainter getPainter(ChartType chartType) {
    switch (chartType) {
      case ChartType.line:
        return LineSeriesPainter();
      case ChartType.area:
        return AreaSeriesPainter();
      case ChartType.column:
      case ChartType.bar:
        return ColumnSeriesPainter();
      case ChartType.pie:
      case ChartType.doughnut:
        return PieSeriesPainter();
      case ChartType.stackedArea:
      case ChartType.stackedBar:
      case ChartType.stackedColumn:
        // For simplicity, returning basic painters - would need specialized ones
        return ColumnSeriesPainter();
    }
  }
}
