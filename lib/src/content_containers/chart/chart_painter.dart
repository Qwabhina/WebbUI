import 'dart:math';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';

class ChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final ChartType chartType;
  final AxisType? xAxisType;
  final AxisType? yAxisType;
  final Offset? tapPosition;
  final double scale;
  final Offset panOffset;
  final BuildContext webbTheme;
  final ChartConfig config;

  late double _minX, _maxX, _minY, _maxY;
  late double _leftPadding, _rightPadding, _topPadding, _bottomPadding;

  // Cache for performance
  late List<ChartSeries> _cachedSeries;
  late ChartType _cachedChartType;
  late double _cachedScale;
  late Offset _cachedPanOffset;
  late Offset? _cachedTapPosition;

  ChartPainter({
    required this.series,
    required this.chartType,
    this.xAxisType,
    this.yAxisType,
    this.tapPosition,
    required this.scale,
    required this.panOffset,
    required this.webbTheme,
    required this.config,
  }) {
    _cachedSeries = List.from(series);
    _cachedChartType = chartType;
    _cachedScale = scale;
    _cachedPanOffset = panOffset;
    _cachedTapPosition = tapPosition;
    _calculatePadding();
    _calculateBounds();
  }

  void _calculatePadding() {
    _leftPadding = webbTheme.spacingGrid.spacing(4);
    _rightPadding = webbTheme.spacingGrid.spacing(2);
    _topPadding = webbTheme.spacingGrid.spacing(2);
    _bottomPadding = webbTheme.spacingGrid.spacing(4);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final visibleSeries = series.where((s) => s.visible).toList();
    
    if (visibleSeries.isEmpty || visibleSeries.every((s) => s.data.isEmpty)) {
      _drawEmptyState(canvas, size);
      return;
    }

    // Pie and Doughnut charts have separate logic
    if (chartType == ChartType.pie || chartType == ChartType.doughnut) {
      _drawPieOrDoughnutChart(canvas, size);
      return;
    }

    if (config.showGrid) {
      _drawGrid(canvas, size);
    }

    if (config.showAxes) {
      _drawAxes(canvas, size);
    }

    // Prepare data for stacked charts
    Map<dynamic, double> stackedValues = {};

    for (final s in visibleSeries) {
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
          _drawLine(canvas, size, s); // Fallback
          break;
      }
    }

    if (tapPosition != null) {
      _drawTooltipAndCrosshair(canvas, size);
    }
  }

  void _drawEmptyState(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'No data available',
        style: webbTheme.typography.bodyMedium.copyWith(
          color: webbTheme.colorPalette.neutralDark.withOpacity(0.5),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  void _calculateBounds() {
    final visibleSeries = series.where((s) => s.visible);
    if (visibleSeries.isEmpty) {
      _minX = 0;
      _maxX = 1;
      _minY = 0;
      _maxY = 1;
      return;
    }

    bool isStacked = chartType.toString().contains("stacked");

    // Initialize with first visible point
    final firstVisibleSeries = visibleSeries.firstWhere(
        (s) => s.data.isNotEmpty,
        orElse: () => visibleSeries.first);
    if (firstVisibleSeries.data.isEmpty) {
      _minX = 0;
      _maxX = 1;
      _minY = 0;
      _maxY = 1;
      return;
    }

    final firstData = firstVisibleSeries.data.first;
    _minX = _maxX = firstData.x is DateTime
        ? (firstData.x as DateTime).millisecondsSinceEpoch.toDouble()
        : (firstData.x as num).toDouble();
    _minY = 0;
    _maxY = firstData.y;

    Map<dynamic, double> stackedTotals = {};

    for (var s in visibleSeries) {
      for (var p in s.data) {
        double currentX = p.x is DateTime
            ? (p.x as DateTime).millisecondsSinceEpoch.toDouble()
            : (p.x as num).toDouble();
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
    if (_maxY > 0) {
      _maxY *= 1.1;
    } else {
      _maxY = 1.0;
    }
  }

  double _getPixelX(dynamic x, Size size) {
    double xVal = x is DateTime
        ? x.millisecondsSinceEpoch.toDouble()
        : (x as num).toDouble();
    double range = _maxX - _minX;
    if (range == 0) return _leftPadding;
    double scaledRange = range / scale;
    double viewMinX = _minX -
        (panOffset.dx / (size.width - _leftPadding - _rightPadding)) *
            scaledRange;
    return _leftPadding +
        ((xVal - viewMinX) / scaledRange) *
            (size.width - _leftPadding - _rightPadding);
  }

  double _getPixelY(double y, Size size) {
    double range = _maxY - _minY;
    if (range == 0) return size.height - _bottomPadding;
    double scaledRange = range / scale;
    double viewMinY = _minY +
        (panOffset.dy / (size.height - _topPadding - _bottomPadding)) *
            scaledRange;
    return (size.height - _bottomPadding) -
        ((y - viewMinY) / scaledRange) *
            (size.height - _topPadding - _bottomPadding);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Vertical grid lines
    int xGridCount = 5;
    for (int i = 0; i <= xGridCount; i++) {
      double val = _minX + (_maxX - _minX) * i / xGridCount;
      double x = _getPixelX(val, size);
      canvas.drawLine(
        Offset(x, _topPadding),
        Offset(x, size.height - _bottomPadding),
        gridPaint,
      );
    }

    // Horizontal grid lines
    int yGridCount = 5;
    for (int i = 0; i <= yGridCount; i++) {
      double val = _minY + (_maxY - _minY) * i / yGridCount;
      double y = _getPixelY(val, size);
      canvas.drawLine(
        Offset(_leftPadding, y),
        Offset(size.width - _rightPadding, y),
        gridPaint,
      );
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.4)
      ..strokeWidth = 1.5;

    final labelStyle = webbTheme.typography.labelMedium.copyWith(
      color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
    );

    // Draw X and Y axis lines
    canvas.drawLine(
      Offset(_leftPadding, size.height - _bottomPadding),
      Offset(size.width - _rightPadding, size.height - _bottomPadding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(_leftPadding, size.height - _bottomPadding),
      Offset(_leftPadding, _topPadding),
      axisPaint,
    );

    // Draw Y-axis labels
    int yLabelCount = 5;
    for (int i = 0; i <= yLabelCount; i++) {
      double val = _minY + (_maxY - _minY) * i / yLabelCount;
      double y = _getPixelY(val, size);

      final textPainter = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(0), style: labelStyle),
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
            _leftPadding - textPainter.width - 5, y - textPainter.height / 2),
      );
    }

    // Draw X-axis labels
    int xLabelCount = min(5, series.expand((s) => s.data).length);
    for (int i = 0; i <= xLabelCount; i++) {
      dynamic val = _minX + (_maxX - _minX) * i / xLabelCount;
      double x = _getPixelX(val, size);

      String label;
      if (xAxisType == AxisType.dateTime) {
        final date = DateTime.fromMillisecondsSinceEpoch(val.toInt());
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');
        label = '$month/$day';
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
        Offset(x - textPainter.width / 2, size.height - _bottomPadding + 5),
      );
    }
  }

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
      
      // Draw data points
      canvas.drawCircle(Offset(x, y), 3, Paint()..color = s.color);
    }
    canvas.drawPath(path, paint);
  }

  void _drawArea(Canvas canvas, Size size, ChartSeries s) {
    _drawLine(canvas, size, s);

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
    final barWidth =
        (size.width - _leftPadding - _rightPadding) / (s.data.length * 2);

    for (final p in s.data) {
      final x = _getPixelX(p.x, size);
      final y = _getPixelY(p.y, size);
      final y0 = _getPixelY(0, size);

      canvas.drawRect(
        Rect.fromLTRB(x - barWidth / 2, y, x + barWidth / 2, y0),
        paint,
      );
    }
  }

  void _drawBar(Canvas canvas, Size size, ChartSeries s) {
    final paint = Paint()..color = s.color;
    final barHeight =
        (size.height - _topPadding - _bottomPadding) / (s.data.length * 2);

    for (final p in s.data) {
      final x = _getPixelX(p.y, size);
      final y = _getPixelY(p.x, size);
      final x0 = _getPixelX(0, size);

      canvas.drawRect(
        Rect.fromLTRB(x0, y - barHeight / 2, x, y + barHeight / 2),
        paint,
      );
    }
  }

  void _drawStackedColumn(Canvas canvas, Size size, ChartSeries s,
      Map<dynamic, double> stackedValues) {
    final paint = Paint()..color = s.color;
    final barWidth =
        (size.width - _leftPadding - _rightPadding) / (s.data.length * 2);

    for (final p in s.data) {
      final lastY = stackedValues[p.x] ?? 0;
      final currentY = lastY + p.y;

      final x = _getPixelX(p.x, size);
      final y0 = _getPixelY(lastY, size);
      final y1 = _getPixelY(currentY, size);

      canvas.drawRect(
        Rect.fromLTRB(x - barWidth / 2, y1, x + barWidth / 2, y0),
        paint,
      );
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
    final paint = Paint()..color = s.color;
    final barHeight =
        (size.height - _topPadding - _bottomPadding) / (s.data.length * 2);

    for (final p in s.data) {
      final lastX = stackedValues[p.x] ?? 0;
      final currentX = lastX + p.y;

      final y = _getPixelY(p.x, size);
      final x0 = _getPixelX(lastX, size);
      final x1 = _getPixelX(currentX, size);

      canvas.drawRect(
        Rect.fromLTRB(x0, y - barHeight / 2, x1, y + barHeight / 2),
        paint,
      );
      stackedValues[p.x] = currentX;
    }
  }

  void _drawPieOrDoughnutChart(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 3;

    // Calculate total from visible series only
    final visibleSeries = series.where((s) => s.visible);
    final total = visibleSeries.fold<double>(
        0, (sum, s) => sum + s.data.fold(0, (s, p) => s + p.y));

    if (total == 0) return;

    double startAngle = -pi / 2;

    for (final s in visibleSeries) {
      for (final p in s.data) {
        final sweepAngle = (p.y / total) * 2 * pi;
        final paint = Paint()..color = s.color;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          true,
          paint,
        );
        startAngle += sweepAngle;
      }
    }

    if (chartType == ChartType.doughnut) {
      canvas.drawCircle(
        center,
        radius * 0.5,
        Paint()..color = webbTheme.colorPalette.background,
      );
    }
  }

  void _drawTooltipAndCrosshair(Canvas canvas, Size size) {
    if (tapPosition == null) return;

    ChartData? nearestPoint;
    ChartSeries? nearestSeries;
    double minDistance = double.infinity;

    for (final s in series.where((s) => s.visible)) {
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

      // Draw Crosshair
      final crosshairPaint = Paint()
        ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(px, _topPadding),
        Offset(px, size.height - _bottomPadding),
        crosshairPaint,
      );
      canvas.drawLine(
        Offset(_leftPadding, py),
        Offset(size.width - _rightPadding, py),
        crosshairPaint,
      );

      // Draw Tooltip
      final tooltipText = "${nearestSeries!.name}\n"
          "X: ${nearestPoint.x}\n"
          "Y: ${nearestPoint.y.toStringAsFixed(2)}";
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
      double rectX = px + 15;
      double rectY = py - rectHeight / 2;

      if (rectX + rectWidth > size.width) {
        rectX = px - rectWidth - 15;
      }
      if (rectY < 0) rectY = 0;
      if (rectY + rectHeight > size.height) rectY = size.height - rectHeight;

      final tooltipRect = Rect.fromLTWH(rectX, rectY, rectWidth, rectHeight);

      final tooltipPaint = Paint()
        ..color = webbTheme.colorPalette.surface.withOpacity(0.9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            tooltipRect, Radius.circular(webbTheme.spacingGrid.baseSpacing)),
        tooltipPaint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = webbTheme.colorPalette.neutralDark.withOpacity(0.2)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            tooltipRect, Radius.circular(webbTheme.spacingGrid.baseSpacing)),
        borderPaint,
      );

      textPainter.paint(canvas, tooltipRect.topLeft + const Offset(8, 4));
    }
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) {
    return _cachedSeries != series ||
        _cachedChartType != chartType ||
        _cachedScale != scale ||
        _cachedPanOffset != panOffset ||
        _cachedTapPosition != tapPosition;
  }
}
