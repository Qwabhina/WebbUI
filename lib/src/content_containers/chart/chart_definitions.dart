import 'package:flutter/material.dart';

// --- DATA MODELS ---

/// Represents a single data point in a series.
/// The `x` value can be of any type to support different axis types.
class ChartData {
  final dynamic x;
  final double y;

  ChartData(this.x, this.y);
}

/// Represents a series of data to be plotted on the chart.
class ChartSeries {
  final String name;
  final List<ChartData> data;
  final Color color;
  final ChartType chartType; // Can specify type per series for combo charts

  ChartSeries({
    required this.name,
    required this.data,
    required this.color,
    this.chartType = ChartType.line, // Default to line
  });
}

// --- ENUMS ---

/// Defines the types of charts that can be rendered.
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

/// Defines the types of axes for plotting data.
enum AxisType {
  numeric,
  category,
  dateTime,
}

enum LegendPosition { top, bottom, left, right }

enum LegendAlignment { start, center, end }

enum TooltipBehavior { followCursor, fixed }
