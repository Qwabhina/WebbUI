import 'package:flutter/material.dart';
import 'chart_definitions.dart';
import 'chart_legends.dart';
import 'chart_painter.dart';

/// A highly customizable and interactive chart widget conforming to WebbUI theme.
class WebbUIChart extends StatefulWidget {
  final List<ChartSeries> series;
  final ChartType chartType;
  final AxisType? xAxisType;
  final AxisType? yAxisType;
  final bool showLegends;

  const WebbUIChart({
    super.key,
    required this.series,
    this.chartType = ChartType.line,
    this.xAxisType,
    this.yAxisType,
    this.showLegends = true,
  });

  @override
  State<WebbUIChart> createState() => _WebbUIChartState();
}

class _WebbUIChartState extends State<WebbUIChart> {
  Offset? _tapPosition;
  double _scale = 1.0;
  Offset _panOffset = Offset.zero;

  final Map<String, bool> _seriesVisibility = {};

  @override
  void initState() {
    super.initState();
    for (var s in widget.series) {
      _seriesVisibility[s.name] = true;
    }
  }

  @override
  void didUpdateWidget(covariant WebbUIChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset visibility if series data changes
    if (widget.series.length != oldWidget.series.length ||
        widget.series
            .any((s) => !oldWidget.series.any((os) => os.name == s.name))) {
      _seriesVisibility.clear();
      for (var s in widget.series) {
        _seriesVisibility[s.name] = true;
      }
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.5, 5.0);
      }
      _panOffset += details.focalPointDelta;
      _tapPosition = null; // Clear tooltip on pan/zoom
    });
  }

  void _handleTap(Offset localPosition) {
    setState(() {
      _tapPosition = localPosition;
    });
  }

  void _onLegendTapped(String seriesName) {
    setState(() {
      _seriesVisibility[seriesName] = !_seriesVisibility[seriesName]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final visibleSeries =
        widget.series.where((s) => _seriesVisibility[s.name] ?? true).toList();

    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            onTapDown: (details) => _handleTap(details.localPosition),
            onScaleUpdate: _handleScaleUpdate,
            onDoubleTap: () => setState(() {
              // Reset zoom and pan
              _scale = 1.0;
              _panOffset = Offset.zero;
            }),
            child: CustomPaint(
              size: Size.infinite,
              painter: ChartPainter(
                series: visibleSeries,
                chartType: widget.chartType,
                xAxisType: widget.xAxisType,
                yAxisType: widget.yAxisType,
                tapPosition: _tapPosition,
                scale: _scale,
                panOffset: _panOffset,
                context: context, // Pass the context for theme access
              ),
            ),
          ),
        ),
        if (widget.showLegends)
          ChartLegend(
            series: widget.series,
            visibility: _seriesVisibility,
            onLegendTapped: _onLegendTapped,
          ),
      ],
    );
  }
}
