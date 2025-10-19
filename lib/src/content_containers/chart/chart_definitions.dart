import 'package:flutter/material.dart';

// --- DATA MODELS ---

/// Represents a single data point in a series.
class ChartData {
  final dynamic x;
  final double y;
  final String? label; // Optional label for tooltips

  ChartData(this.x, this.y, {this.label});
}

/// Represents a series of data to be plotted on the chart.
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

// class ChartConfig {
//   final bool showGrid;
//   final bool showAxes;
//   final bool showLabels;
//   final LegendPosition legendPosition;
//   final LegendAlignment legendAlignment;
//   final TooltipBehavior tooltipBehavior;
//   final Duration animationDuration;

//   const ChartConfig({
//     this.showGrid = true,
//     this.showAxes = true,
//     this.showLabels = true,
//     this.legendPosition = LegendPosition.bottom,
//     this.legendAlignment = LegendAlignment.center,
//     this.tooltipBehavior = TooltipBehavior.followCursor,
//     this.animationDuration = const Duration(milliseconds: 300),
//   });

//   ChartConfig copyWith({
//     bool? showGrid,
//     bool? showAxes,
//     bool? showLabels,
//     LegendPosition? legendPosition,
//     LegendAlignment? legendAlignment,
//     TooltipBehavior? tooltipBehavior,
//     Duration? animationDuration,
//   }) {
//     return ChartConfig(
//       showGrid: showGrid ?? this.showGrid,
//       showAxes: showAxes ?? this.showAxes,
//       showLabels: showLabels ?? this.showLabels,
//       legendPosition: legendPosition ?? this.legendPosition,
//       legendAlignment: legendAlignment ?? this.legendAlignment,
//       tooltipBehavior: tooltipBehavior ?? this.tooltipBehavior,
//       animationDuration: animationDuration ?? this.animationDuration,
//     );
//   }
// }
