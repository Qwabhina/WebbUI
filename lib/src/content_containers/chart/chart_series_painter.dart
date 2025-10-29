import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';

/// Base class for all series painters - uses strategy pattern for different chart types.
/// Now painters take list of series for stacked/grouped rendering.
abstract class ChartSeriesPainter {
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series, // Changed to list for multi-series handling
    ChartConfig config,
  );
}

/// Paints line charts with optional data points.
class LineSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series,
    ChartConfig config,
  ) {
    for (final s in series) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      final points = <Offset>[];

      // Create path and collect points
      for (int i = 0; i < s.data.length; i++) {
        final p = s.data[i];
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
        canvas.drawCircle(point, 3, Paint()..color = s.color);
      }
    }
  }
}

/// Paints area charts (line with filled area below).
class AreaSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series,
    ChartConfig config,
  ) {
    for (final s in series) {
      // First draw the line
      LineSeriesPainter().paint(canvas, coordSystem, [s], config);

      // Then fill the area, handling negatives
      final paint = Paint()..color = s.color.withOpacity(0.3);
      final path = Path();

      if (s.data.isNotEmpty) {
        final y0 = coordSystem.getPixelY(0); // Baseline at 0
        path.moveTo(
          coordSystem.getPixelX(s.data.first.x),
          y0,
        );

        for (final p in s.data) {
          path.lineTo(
            coordSystem.getPixelX(p.x),
            coordSystem.getPixelY(p.y),
          );
        }

        path.lineTo(
          coordSystem.getPixelX(s.data.last.x),
          y0,
        );
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }
}

/// Paints column/bar charts with grouping for multi-series.
/// Assumes all series have aligned x-values and similar lengths; otherwise, bars may misalign.
class ColumnSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series,
    ChartConfig config,
  ) {
    if (series.isEmpty) return;

    final numSeries = series.length;
    final groupWidth =
        coordSystem.chartAreaSize.width / series.first.data.length;
    final barWidth = groupWidth / (numSeries + 1); // Space between groups

    for (int i = 0; i < series.first.data.length; i++) {
      for (int j = 0; j < numSeries; j++) {
        final s = series[j];
        if (i >= s.data.length) continue;
        final p = s.data[i];
        final paint = Paint()..color = s.color;

        final groupX = coordSystem.getPixelX(p.x);
        final x = groupX - groupWidth / 2 + barWidth * (j + 0.5);
        final y = coordSystem.getPixelY(p.y);
        final yBase = coordSystem.getPixelY(
            p.y < 0 ? coordSystem.bounds.maxY : 0); // Handle negatives

        canvas.drawRect(
          Rect.fromLTRB(x - barWidth / 2, math.min(y, yBase), x + barWidth / 2,
              math.max(y, yBase)),
          paint,
        );
      }
    }
  }
}

/// Paints stacked column charts, supporting negatives.
/// Assumes all series have aligned x-values; otherwise, stacks may be incomplete.
class StackedColumnPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series,
    ChartConfig config,
  ) {
    if (series.isEmpty) return;

    final Map<dynamic, double> posStacks = {};
    final Map<dynamic, double> negStacks = {};

    for (final s in series) {
      for (final p in s.data) {
        final paint = Paint()..color = s.color;
        final x = coordSystem.getPixelX(p.x);
        final barWidth = coordSystem.chartAreaSize.width / (s.data.length * 2);

        double yStart;
        if (p.y >= 0) {
          yStart = posStacks[p.x] ?? 0;
          posStacks[p.x] = yStart + p.y;
        } else {
          yStart = negStacks[p.x] ?? 0;
          negStacks[p.x] = yStart + p.y;
        }

        final yTop = coordSystem.getPixelY(yStart + p.y);
        final yBottom = coordSystem.getPixelY(yStart);

        canvas.drawRect(
          Rect.fromLTRB(x - barWidth / 2, yTop, x + barWidth / 2, yBottom),
          paint,
        );
      }
    }
  }
}

/// Paints stacked area charts.
/// Fixed path reversal by collecting baseline points and traversing in reverse.
class StackedAreaPainter implements ChartSeriesPainter {
  @override
  void paint(
    Canvas canvas,
    ChartCoordinateSystem coordSystem,
    List<ChartSeries> series,
    ChartConfig config,
  ) {
    // Implementation similar to stacked column but with paths
    final Map<dynamic, double> stacks = {};

    for (final s in series.reversed) {
      // Draw from bottom to top
      final paint = Paint()..color = s.color.withOpacity(0.3);
      final linePaint = Paint()
        ..color = s.color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      final path = Path();
      final baselineOffsets = <Offset>[]; // Collect baselines for reversal

      if (s.data.isNotEmpty) {
        // Start at baseline (previous stack)
        final firstBaseline = Offset(
          coordSystem.getPixelX(s.data.first.x),
          coordSystem.getPixelY(stacks[s.data.first.x] ?? 0),
        );
        path.moveTo(firstBaseline.dx, firstBaseline.dy);
        baselineOffsets.add(firstBaseline);

        for (final p in s.data) {
          final stackY = stacks[p.x] ?? 0;
          final newY = stackY + p.y;
          stacks[p.x] = newY;
          path.lineTo(
            coordSystem.getPixelX(p.x),
            coordSystem.getPixelY(newY),
          );
          baselineOffsets.add(Offset(
            coordSystem.getPixelX(p.x),
            coordSystem.getPixelY(stackY),
          ));
        }

        // Close path by traversing baselines in reverse
        for (final offset in baselineOffsets.reversed) {
          path.lineTo(offset.dx, offset.dy);
        }
        path.close();

        canvas.drawPath(path, paint);
        canvas.drawPath(path, linePaint); // Optional line on top
      }
    }
  }
}

/// Paints pie/doughnut charts.
class PieSeriesPainter implements ChartSeriesPainter {
  @override
  void paint(Canvas canvas, ChartCoordinateSystem coordSystem,
      List<ChartSeries> series, ChartConfig config) {
    if (series.isEmpty) return;
    final s = series.first; // Merge if multi-series needed: fold all data
    final center =
        Offset(coordSystem.size.width / 2, coordSystem.size.height / 2);
    final radius =
        math.min(coordSystem.size.width, coordSystem.size.height) / 3;
    final total = s.data.fold<double>(0, (sum, p) => sum + p.y.abs());
    if (total == 0) return;

    double startAngle = -math.pi / 2;
    const labelStyle =
        TextStyle(color: Colors.black, fontSize: 12); // Use theme

    for (final p in s.data) {
      final sweepAngle = (p.y.abs() / total) * 2 * math.pi;
      final paint = Paint()
        ..color = _getSegmentColor(s.color, s.data.indexOf(p));

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          startAngle, sweepAngle, true, paint);

      // Add label at midpoint
      final midAngle = startAngle + sweepAngle / 2;
      final labelOffset = center +
          Offset(
              math.cos(midAngle) * radius / 2, math.sin(midAngle) * radius / 2);
      final textPainter = TextPainter(
          text: TextSpan(
              text: p.label ?? p.y.toStringAsFixed(0), style: labelStyle),
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas,
          labelOffset - Offset(textPainter.width / 2, textPainter.height / 2));

      startAngle += sweepAngle;
    }

    if (s.chartType == ChartType.doughnut) {
      canvas.drawCircle(center, radius * 0.5,
          Paint()..color = Colors.white); // Inner circle for doughnut
    }
  }

  Color _getSegmentColor(Color baseColor, int index) {
    final hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withLightness((hsl.lightness + (index * 0.15)).clamp(0.3, 0.9))
        .toColor();
  }
}

/// Factory to get the appropriate painter for each chart type.
/// Updated for stacked types.
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
      case ChartType.stackedArea:
        return StackedAreaPainter();
      case ChartType.stackedColumn:
      case ChartType.stackedBar:
        return StackedColumnPainter();
      case ChartType.pie:
      case ChartType.doughnut:
        return PieSeriesPainter();
    }
  }
}
