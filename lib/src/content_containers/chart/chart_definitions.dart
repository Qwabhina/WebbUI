import 'package:flutter/material.dart';

// --- DATA MODELS ---

/// Represents a single data point in a series.
class ChartData {
  final dynamic x;
  final double y;
  final String? label; // Optional label for tooltips

  const ChartData(this.x, this.y, {this.label});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartData &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

/// Represents a series of data to be plotted on the chart.
class ChartSeries {
  final String name;
  final List<ChartData> data;
  final Color color;
  final ChartType chartType;
  final bool visible; // Series-level visibility

  const ChartSeries({
    required this.name,
    required this.data,
    required this.color,
    this.chartType = ChartType.line,
    this.visible = true,
  });

  ChartSeries copyWith({
    String? name,
    List<ChartData>? data,
    Color? color,
    ChartType? chartType,
    bool? visible,
  }) {
    return ChartSeries(
      name: name ?? this.name,
      data: data ?? this.data,
      color: color ?? this.color,
      chartType: chartType ?? this.chartType,
      visible: visible ?? this.visible,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartSeries &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          color == other.color &&
          chartType == other.chartType &&
          visible == other.visible;

  @override
  int get hashCode =>
      name.hashCode ^ color.hashCode ^ chartType.hashCode ^ visible.hashCode;
}

// --- ENUMS ---

enum ChartType {
  line,
  column,
  bar,
  area,
  stackedArea,
  stackedBar,
  stackedColumn,
  pie,
  doughnut
}

enum AxisType {
  numeric,
  category,
  dateTime
}

enum LegendPosition { top, bottom, left, right }

enum LegendAlignment { start, center, end }

enum TooltipBehavior { followCursor, fixed }

// --- CHART CONFIGURATION ---
class ChartConfig {
  final bool showGrid;
  final bool showAxes;
  final bool showLabels;
  final LegendPosition legendPosition;
  final LegendAlignment legendAlignment;
  final TooltipBehavior tooltipBehavior;
  final Duration animationDuration;

  const ChartConfig({
    this.showGrid = true,
    this.showAxes = true,
    this.showLabels = true,
    this.legendPosition = LegendPosition.bottom,
    this.legendAlignment = LegendAlignment.center,
    this.tooltipBehavior = TooltipBehavior.followCursor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  ChartConfig copyWith({
    bool? showGrid,
    bool? showAxes,
    bool? showLabels,
    LegendPosition? legendPosition,
    LegendAlignment? legendAlignment,
    TooltipBehavior? tooltipBehavior,
    Duration? animationDuration,
  }) {
    return ChartConfig(
      showGrid: showGrid ?? this.showGrid,
      showAxes: showAxes ?? this.showAxes,
      showLabels: showLabels ?? this.showLabels,
      legendPosition: legendPosition ?? this.legendPosition,
      legendAlignment: legendAlignment ?? this.legendAlignment,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }
}

// --- CHART BOUNDS CALCULATION ---

/// Calculates and stores the bounds (min/max values) for chart data
class ChartBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  const ChartBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  /// Calculates bounds for a list of series, considering chart type
  factory ChartBounds.calculate({
    required List<ChartSeries> series,
    required ChartType chartType,
  }) {
    final visibleSeries = series.where((s) => s.visible);
    if (visibleSeries.isEmpty || visibleSeries.every((s) => s.data.isEmpty)) {
      return const ChartBounds(minX: 0, maxX: 1, minY: 0, maxY: 1);
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    final bool isStacked = chartType.toString().contains('stacked');
    final Map<dynamic, double> stackedTotals = {};

    for (final s in visibleSeries) {
      for (final p in s.data) {
        // Convert x value to numeric representation
        final double currentX = p.x is DateTime
            ? (p.x as DateTime).millisecondsSinceEpoch.toDouble()
            : (p.x as num).toDouble();

        // Update x bounds
        minX = minX < currentX ? minX : currentX;
        maxX = maxX > currentX ? maxX : currentX;

        // Update y bounds based on chart type
        if (isStacked) {
          stackedTotals[p.x] = (stackedTotals[p.x] ?? 0) + p.y;
        } else {
          minY = minY < p.y ? minY : p.y;
          maxY = maxY > p.y ? maxY : p.y;
        }
      }
    }

    // Handle stacked chart bounds
    if (isStacked && stackedTotals.isNotEmpty) {
      minY = 0; // Stacked charts typically start at 0
      maxY = stackedTotals.values.reduce((a, b) => a > b ? a : b);
    }

    // Ensure valid ranges with padding
    if (minX == double.infinity) minX = 0;
    if (maxX == double.negativeInfinity) maxX = 1;
    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;

    // Add padding to bounds
    final xRange = maxX - minX;
    final yRange = maxY - minY;

    return ChartBounds(
      minX: minX - xRange * 0.05,
      maxX: maxX + xRange * 0.05,
      minY: minY,
      maxY: maxY + yRange * 0.1,
    );
  }

  double get xRange => maxX - minX;
  double get yRange => maxY - minY;
}
