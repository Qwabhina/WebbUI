import 'package:flutter/material.dart';

// --- DATA MODELS ---

/// Represents a single data point in a series.
class ChartData {
  final dynamic x; // Can be num, DateTime, or String for category
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
/// Now includes sorting in constructor for optimized searches.
class ChartSeries {
  final String name;
  final List<ChartData> data;
  final Color color;
  final ChartType chartType;
  final bool visible; // Series-level visibility

  ChartSeries({
    required this.name,
    required this.data,
    required this.color,
    this.chartType = ChartType.line,
    this.visible = true,
  }) : assert(
            data.isEmpty ||
                data.every((p) => p.x.runtimeType == data.first.x.runtimeType),
            'All x values in a series must be of the same type.');

  /// Sorts data by x if not already sorted, for binary search optimization.
  ChartSeries sorted() {
    final sortedData = List<ChartData>.from(data)
      ..sort((a, b) {
        if (a.x is num && b.x is num) return (a.x as num).compareTo(b.x as num);
        if (a.x is DateTime && b.x is DateTime) {
          return (a.x as DateTime).compareTo(b.x as DateTime);
        }
        return 0; // Categories assumed pre-ordered
      });
    return copyWith(data: sortedData);
  }

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
  final int gridTickCount; // Added for configurable grid density

  const ChartConfig({
    this.showGrid = true,
    this.showAxes = true,
    this.showLabels = true,
    this.legendPosition = LegendPosition.bottom,
    this.legendAlignment = LegendAlignment.center,
    this.tooltipBehavior = TooltipBehavior.followCursor,
    this.animationDuration = const Duration(milliseconds: 300),
    this.gridTickCount = 5, // Default tick count
  });

  ChartConfig copyWith({
    bool? showGrid,
    bool? showAxes,
    bool? showLabels,
    LegendPosition? legendPosition,
    LegendAlignment? legendAlignment,
    TooltipBehavior? tooltipBehavior,
    Duration? animationDuration,
    int? gridTickCount,
  }) {
    return ChartConfig(
      showGrid: showGrid ?? this.showGrid,
      showAxes: showAxes ?? this.showAxes,
      showLabels: showLabels ?? this.showLabels,
      legendPosition: legendPosition ?? this.legendPosition,
      legendAlignment: legendAlignment ?? this.legendAlignment,
      tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
      animationDuration: animationDuration ?? this.animationDuration,
      gridTickCount: gridTickCount ?? this.gridTickCount,
    );
  }
}

// --- CHART BOUNDS CALCULATION ---

/// Calculates and stores the bounds (min/max values) for chart data.
/// Now supports category axes (x as strings mapped to indices) and negative y-values in stacked charts.
class ChartBounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final List<String>? categories; // For category axis

  const ChartBounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    this.categories,
  });

  /// Calculates bounds for a list of series, considering chart type and axis type.
  factory ChartBounds.calculate({
    required List<ChartSeries> series,
    required ChartType chartType,
    required AxisType xAxisType,
  }) {
    final visibleSeries = series.where((s) => s.visible);
    if (visibleSeries.isEmpty || visibleSeries.every((s) => s.data.isEmpty)) {
      return const ChartBounds(minX: 0, maxX: 1, minY: 0, maxY: 1);
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    Set<String> categorySet = {}; // For collecting unique categories

    final bool isStacked = chartType.toString().contains('stacked');
    final Map<dynamic, double> stackedPosTotals = {};
    final Map<dynamic, double> stackedNegTotals = {}; // For negative stacks

    for (final s in visibleSeries) {
      for (final p in s.data) {
        // Handle x based on type
        if (xAxisType == AxisType.category) {
          categorySet.add(p.x.toString());
        } else {
          final double currentX = p.x is DateTime
              ? (p.x as DateTime).millisecondsSinceEpoch.toDouble()
              : (p.x as num).toDouble();
          minX = minX < currentX ? minX : currentX;
          maxX = maxX > currentX ? maxX : currentX;
        }

        // Update y bounds based on chart type
        if (isStacked) {
          if (p.y >= 0) {
            stackedPosTotals[p.x] = (stackedPosTotals[p.x] ?? 0) + p.y;
          } else {
            stackedNegTotals[p.x] = (stackedNegTotals[p.x] ?? 0) + p.y;
          }
        } else {
          minY = minY < p.y ? minY : p.y;
          maxY = maxY > p.y ? maxY : p.y;
        }
      }
    }

    // Handle category x
    if (xAxisType == AxisType.category) {
      final List<String> categories = categorySet.toList();
      minX = 0;
      maxX = categories.length - 1.toDouble();
      return ChartBounds(
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        categories: categories,
      );
    }

    // Handle stacked chart bounds, supporting negatives
    if (isStacked) {
      if (stackedPosTotals.isNotEmpty) {
        maxY = stackedPosTotals.values.reduce((a, b) => a > b ? a : b);
      }
      if (stackedNegTotals.isNotEmpty) {
        minY = stackedNegTotals.values.reduce((a, b) => a < b ? a : b);
      }
      minY = minY < 0 ? minY : 0;
      maxY = maxY > 0 ? maxY : 0;
    }

    // Ensure valid ranges with padding
    if (minX == double.infinity) minX = 0;
    if (maxX == double.negativeInfinity) maxX = 1;
    if (minY == double.infinity) minY = 0;
    if (maxY == double.negativeInfinity) maxY = 1;

    final xRange = maxX - minX;
    final yRange = maxY - minY;

    return ChartBounds(
      minX: minX - xRange * 0.05,
      maxX: maxX + xRange * 0.05,
      minY: minY - yRange * 0.05, // Added padding for minY
      maxY: maxY + yRange * 0.1,
    );
  }

  double get xRange => maxX - minX;
  double get yRange => maxY - minY;
}
