import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';
import 'chart_coordinate_system.dart';
import 'chart_grid_painter.dart';
import 'chart_series_painter.dart';
import 'chart_tooltip_painter.dart';

/// Main chart painter that orchestrates all modular painters.
/// This follows the composite pattern, delegating to specialized painters.
/// Now with clipping for zoomed content and sorted series for optimization.
class WebbUIChartPainter extends CustomPainter {
  final List<ChartSeries> series;
  final ChartType chartType;
  final ChartConfig config;
  final Offset? tapPosition;
  final double scale;
  final Offset panOffset;
  final BuildContext webbTheme;
  final AxisType xAxisType; // Added

  // Modular painters
  late final ChartGridPainter _gridPainter;
  late final ChartTooltipPainter _tooltipPainter;

  // Cached values for performance
  late final ChartBounds _bounds;
  late final ChartCoordinateSystem _coordSystem;

  WebbUIChartPainter({
    required this.series,
    required this.chartType,
    required this.config,
    required this.tapPosition,
    required this.scale,
    required this.panOffset,
    required this.webbTheme,
    this.xAxisType = AxisType.numeric,
  }) {
    _gridPainter = ChartGridPainter(
      config: config,
      webbTheme: webbTheme,
      xAxisType: xAxisType,
    );
    _tooltipPainter = ChartTooltipPainter(webbTheme: webbTheme);
    
    // Pre-calculate expensive operations
    _bounds = ChartBounds.calculate(
      series: series,
      chartType: chartType,
      xAxisType: xAxisType,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Set up coordinate system with current size
    _coordSystem = ChartCoordinateSystem(
      bounds: _bounds,
      size: size,
      scale: scale,
      panOffset: panOffset,
      leftPadding: webbTheme.spacingGrid.spacing(4),
      rightPadding: webbTheme.spacingGrid.spacing(2),
      topPadding: webbTheme.spacingGrid.spacing(2),
      bottomPadding: webbTheme.spacingGrid.spacing(4),
      xAxisType: xAxisType,
    );

    final visibleSeries = series
        .where((s) => s.visible)
        .map((s) => s.sorted()) // Sort for optimization
        .toList();
    
    // Handle empty state
    if (visibleSeries.isEmpty || visibleSeries.every((s) => s.data.isEmpty)) {
      _drawEmptyState(canvas, size);
      return;
    }

    // Clip to prevent overflow from zoom/pan
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Handle pie/doughnut charts separately (they don't use grid/axes)
    if (chartType == ChartType.pie || chartType == ChartType.doughnut) {
      _drawPieOrDoughnutChart(canvas, visibleSeries);
    } else {
      // Draw grid and axes for cartesian charts
      _gridPainter.paint(canvas, size, _coordSystem);

      // Draw all visible series
      _drawSeries(canvas, visibleSeries);
    }

    // Draw tooltip if needed
    if (tapPosition != null) {
      _drawTooltip(canvas, size);
    }

    canvas.restore();
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

  void _drawSeries(Canvas canvas, List<ChartSeries> visibleSeries) {
    // For stacked, pass all series to painter for accumulation
    final painter = ChartSeriesPainterFactory.getPainter(chartType);
    painter.paint(
        canvas, _coordSystem, visibleSeries, config); // Changed to pass list
  }

  void _drawPieOrDoughnutChart(Canvas canvas, List<ChartSeries> visibleSeries) {
    // Pie charts use only the first visible series
    if (visibleSeries.isNotEmpty) {
      final painter = ChartSeriesPainterFactory.getPainter(chartType);
      painter.paint(
          canvas, _coordSystem, [visibleSeries.first], config); // Pass as list
    }
  }

  void _drawTooltip(Canvas canvas, Size size) {
    final nearest = _coordSystem.findNearestPoint(tapPosition!, series);

    if (nearest.point != null && nearest.distance < 30) {
      _tooltipPainter.paint(
        canvas,
        size,
        _coordSystem,
        tapPosition!,
        nearest.point,
        series, // Pass full series list
      );
    }
  }

  @override
  bool shouldRepaint(covariant WebbUIChartPainter oldDelegate) {
    return series != oldDelegate.series ||
        chartType != oldDelegate.chartType ||
        config != oldDelegate.config ||
        tapPosition != oldDelegate.tapPosition ||
        scale != oldDelegate.scale ||
        panOffset != oldDelegate.panOffset ||
        xAxisType != oldDelegate.xAxisType;
  }
}
