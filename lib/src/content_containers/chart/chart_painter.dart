import 'dart:math';
import 'package:flutter/material.dart';
import 'chart_definitions.dart';

/// Handles the actual drawing of the chart on the canvas.
class ChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final ChartType chartType;
  final AxisType? xAxisType;
  final AxisType? yAxisType;
  final Offset? tapPosition;
  final double scale;
  final Offset panOffset;
  final BuildContext context; // Use BuildContext to access WebbUITheme

  late double _minX, _maxX, _minY, _maxY;
  final _padding = 50.0;

  ChartPainter({
    required this.series,
    required this.chartType,
    this.xAxisType,
    this.yAxisType,
    this.tapPosition,
    required this.scale,
    required this.panOffset,
    required this.context, // Updated constructor
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty || series.every((s) => s.data.isEmpty)) return;

    // Pie and Doughnut charts have a separate drawing logic
    if (chartType == ChartType.pie || chartType == ChartType.doughnut) {
      _drawPieOrDoughnutChart(canvas, size);
      return;
    }

    _calculateBounds();
    _drawAxesAndGrid(canvas, size);

    // Prepare data for stacked charts
    Map<dynamic, double> stackedValues = {};

    for (final s in series) {
      final effectiveChartType = s.chartType;
      switch (effectiveChartType) {
        case ChartType.line:
          _drawLine(canvas, size, s);
          break;
        case ChartType.area:
          _drawArea(canvas, size, s);
          break;
        case ChartType.column:
          _drawColumn(canvas, size, s);
          break;
        case ChartType.bar:
          _drawBar(canvas, size, s);
          break;
        case ChartType.stackedColumn:
          _drawStackedColumn(canvas, size, s, stackedValues);
          break;
        case ChartType.stackedBar:
          _drawStackedBar(canvas, size, s, stackedValues);
          break;
        case ChartType.stackedArea:
          _drawStackedArea(canvas, size, s, stackedValues);
          break;
        default:
          break;
      }
    }

    _drawTooltipAndCrosshair(canvas, size);
  }

  // --- Bound Calculation ---
  void _calculateBounds() {
    if (series.isEmpty) return;

    bool isStacked = chartType.name.contains("stacked");

    // Initialize with first point
    _minX = _maxX = series.first.data.first.x is DateTime
        ? (series.first.data.first.x as DateTime)
            .millisecondsSinceEpoch
            .toDouble()
        : series.first.data.first.x.toDouble();
    _minY = 0; // Always start Y axis at 0 for clarity
    _maxY = series.first.data.first.y;

    Map<dynamic, double> stackedTotals = {};

    for (var s in series) {
      for (var p in s.data) {
        double currentX = p.x is DateTime
            ? (p.x as DateTime).millisecondsSinceEpoch.toDouble()
            : p.x.toDouble();
        if (currentX < _minX) _minX = currentX;
        if (currentX > _maxX) _maxX = currentX;

        if (isStacked) {
          stackedTotals[p.x] = (stackedTotals[p.x] ?? 0) + p.y;
        } else {
          if (p.y > _maxY) _maxY = p.y;
          if (p.y < _minY) _minY = p.y;
        }
      }
    }

    if (isStacked) {
      _maxY =
          stackedTotals.values.isEmpty ? 100 : stackedTotals.values.reduce(max);
    }

    // Add some padding to max values
    _maxY *= 1.1;
  }

  // --- Coordinate Transformation ---
  double _getPixelX(dynamic x, Size size) {
    double xVal =
        x is DateTime ? x.millisecondsSinceEpoch.toDouble() : x.toDouble();
    double range = _maxX - _minX;
    if (range == 0) return _padding;
    double scaledRange = range / scale;
    double viewMinX =
        _minX - (panOffset.dx / (size.width - 2 * _padding)) * scaledRange;
    return _padding +
        ((xVal - viewMinX) / scaledRange) * (size.width - 2 * _padding);
  }

  double _getPixelY(double y, Size size) {
    double range = _maxY - _minY;
    if (range == 0) return size.height - _padding;
    double scaledRange = range / scale;
    double viewMinY =
        _minY + (panOffset.dy / (size.height - 2 * _padding)) * scaledRange;
    return (size.height - _padding) -
        ((y - viewMinY) / scaledRange) * (size.height - 2 * _padding);
  }

  // --- Drawing Methods: Axes and Grid ---
  void _drawAxesAndGrid(Canvas canvas, Size size) {
    final colorScheme = Theme.of(context).colorScheme;

    final axisPaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.4)
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = colorScheme.onSurface.withOpacity(0.15)
      ..strokeWidth = 0.5;
    final labelStyle =
        TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 10);

    // Draw X and Y axis lines
    canvas.drawLine(Offset(_padding, size.height - _padding),
        Offset(size.width - _padding, size.height - _padding), axisPaint);
    canvas.drawLine(Offset(_padding, size.height - _padding),
        Offset(_padding, _padding), axisPaint);

    // Draw Y-axis labels and grid lines
    int yLabelCount = 5;
    for (int i = 0; i <= yLabelCount; i++) {
      double val = _minY + (_maxY - _minY) * i / yLabelCount;
      double y = _getPixelY(val, size);

      canvas.drawLine(
          Offset(_padding, y), Offset(size.width - _padding, y), gridPaint);

      final textSpan =
          TextSpan(text: val.toStringAsFixed(0), style: labelStyle);
      final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.right,
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(_padding - textPainter.width - 5, y - textPainter.height / 2));
    }

    // Draw X-axis labels and grid lines
    int xLabelCount = 5;
    for (int i = 0; i <= xLabelCount; i++) {
      dynamic val = _minX + (_maxX - _minX) * i / xLabelCount;
      double x = _getPixelX(val, size);

      canvas.drawLine(
          Offset(x, size.height - _padding), Offset(x, _padding), gridPaint);

      String label;
      if (xAxisType == AxisType.dateTime) {
        final date = DateTime.fromMillisecondsSinceEpoch(val.toInt());
        // Use built-in properties for formatting MM/dd, removing intl dependency
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');
        label = '$month/$day';
      } else {
        label = val.toStringAsFixed(1);
      }

      final textSpan = TextSpan(text: label, style: labelStyle);
      final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr);
      textPainter.layout();
      textPainter.paint(canvas,
          Offset(x - textPainter.width / 2, size.height - _padding + 5));
    }
  }

  // --- Drawing Methods: Chart Types ---
  void _drawLine(Canvas canvas, Size size, ChartSeries s) {
    final paint = Paint()
      ..color = s.color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path();

    for (int i = 0; i < s.data.length; i++) {
      final p = s.data[i];
      final x = _getPixelX(p.x, size);
      final y = _getPixelY(p.y, size);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = s.color);
    }
    canvas.drawPath(path, paint);
  }

  void _drawArea(Canvas canvas, Size size, ChartSeries s) {
    _drawLine(canvas, size, s); // Draw the top line first

    final paint = Paint()..color = s.color.withOpacity(0.3);
    final path = Path();

    path.moveTo(_getPixelX(s.data.first.x, size), _getPixelY(0, size));

    for (final p in s.data) {
      path.lineTo(_getPixelX(p.x, size), _getPixelY(p.y, size));
    }
    path.lineTo(_getPixelX(s.data.last.x, size), _getPixelY(0, size));
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawColumn(Canvas canvas, Size size, ChartSeries s) {
    final paint = Paint()..color = s.color;
    final barWidth = (size.width - 2 * _padding) / (s.data.length * 2);

    for (final p in s.data) {
      final x = _getPixelX(p.x, size);
      final y = _getPixelY(p.y, size);
      final y0 = _getPixelY(0, size);

      canvas.drawRect(
          Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, y0), paint);
    }
  }

  void _drawBar(Canvas canvas, Size size, ChartSeries s) {
    final paint = Paint()..color = s.color;
    final barHeight = (size.height - 2 * _padding) / (s.data.length * 2);

    for (final p in s.data) {
      final x = _getPixelX(p.y, size);
      final y = _getPixelY(
          p.x, size); // Y-axis is categorical, so pixel positions are different
      final x0 = _getPixelX(0, size);

      canvas.drawRect(
          Rect.fromLTRB(x0, y - barHeight / 2, x, y + barHeight / 2), paint);
    }
  }

  void _drawStackedColumn(Canvas canvas, Size size, ChartSeries s,
      Map<dynamic, double> stackedValues) {
    final paint = Paint()..color = s.color;
    final barWidth = (size.width - 2 * _padding) / (s.data.length * 2);

    for (final p in s.data) {
      final lastY = stackedValues[p.x] ?? 0;
      final currentY = lastY + p.y;

      final x = _getPixelX(p.x, size);
      final y0 = _getPixelY(lastY, size);
      final y1 = _getPixelY(currentY, size);

      canvas.drawRect(
          Rect.fromLTRB(x - barWidth / 2, y1, x + barWidth / 2, y0), paint);
      stackedValues[p.x] = currentY;
    }
  }

  void _drawStackedArea(Canvas canvas, Size size, ChartSeries s,
      Map<dynamic, double> stackedValues) {
    final paint = Paint()..color = s.color.withOpacity(0.7);
    final path = Path();

    final lastPoint = s.data.last;

    final lastY0 = stackedValues[lastPoint.x] ?? 0;
    path.moveTo(_getPixelX(lastPoint.x, size), _getPixelY(lastY0, size));

    for (int i = s.data.length - 1; i >= 0; i--) {
      final p = s.data[i];
      final lastY = stackedValues[p.x] ?? 0;
      path.lineTo(_getPixelX(p.x, size), _getPixelY(lastY, size));
    }

    for (final p in s.data) {
      final lastY = stackedValues[p.x] ?? 0;
      final currentY = lastY + p.y;
      path.lineTo(_getPixelX(p.x, size), _getPixelY(currentY, size));
      stackedValues[p.x] = currentY;
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawStackedBar(Canvas canvas, Size size, ChartSeries s,
      Map<dynamic, double> stackedValues) {
    // Similar logic to stacked column, but with axes flipped.
  }

  void _drawPieOrDoughnutChart(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2.5;
    final total = series.fold<double>(
        0, (sum, s) => sum + s.data.fold(0, (s, p) => s + p.y));

    double startAngle = -pi / 2;

    for (final s in series) {
      for (final p in s.data) {
        final sweepAngle = (p.y / total) * 2 * pi;
        final paint = Paint()..color = s.color;

        canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
            startAngle, sweepAngle, true, paint);
        startAngle += sweepAngle;
      }
    }

    if (chartType == ChartType.doughnut) {
      canvas.drawCircle(center, radius * 0.5,
          Paint()..color = Theme.of(context).scaffoldBackgroundColor);
    }
  }

  // --- Drawing Methods: User Interaction ---
  void _drawTooltipAndCrosshair(Canvas canvas, Size size) {
    if (tapPosition == null) return;

    // Find nearest point
    ChartData? nearestPoint;
    ChartSeries? nearestSeries;
    double minDistance = double.infinity;

    for (final s in series) {
      for (final p in s.data) {
        final px = _getPixelX(p.x, size);
        final py = _getPixelY(p.y, size);
        final distance = (Offset(px, py) - tapPosition!).distance;
        if (distance < minDistance) {
          minDistance = distance;
          nearestPoint = p;
          nearestSeries = s;
        }
      }
    }

    if (nearestPoint != null && minDistance < 30) {
      final px = _getPixelX(nearestPoint.x, size);
      final py = _getPixelY(nearestPoint.y, size);
      final colorScheme = Theme.of(context).colorScheme;

      // Draw Crosshair
      final crosshairPaint = Paint()
        ..color = colorScheme.onSurface.withOpacity(0.5)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(px, _padding), Offset(px, size.height - _padding),
          crosshairPaint);
      canvas.drawLine(Offset(_padding, py), Offset(size.width - _padding, py),
          crosshairPaint);

      // Draw Tooltip
      final tooltipText = "${nearestSeries!.name}\n"
          "X: ${nearestPoint.x}\n"
          "Y: ${nearestPoint.y.toStringAsFixed(2)}";
      final textSpan = TextSpan(
          text: tooltipText,
          style: TextStyle(color: colorScheme.onInverseSurface, fontSize: 12));
      final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr);
      textPainter.layout();

      final rectWidth = textPainter.width + 16;
      final rectHeight = textPainter.height + 8;
      double rectX = px + 15;
      double rectY = py - rectHeight / 2;

      if (rectX + rectWidth > size.width) {
        rectX = px - rectWidth - 15;
      }
      if (rectY < 0) rectY = 0;
      if (rectY + rectHeight > size.height) rectY = size.height - rectHeight;

      final tooltipRect = Rect.fromLTWH(rectX, rectY, rectWidth, rectHeight);

      final tooltipPaint = Paint()
        ..color = colorScheme.inverseSurface.withOpacity(0.8);
      canvas.drawRRect(
          RRect.fromRectAndRadius(tooltipRect, const Radius.circular(8)),
          tooltipPaint);
      textPainter.paint(canvas, tooltipRect.topLeft + const Offset(8, 4));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Repaint on any change for simplicity
  }
}
