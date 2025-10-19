import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';
import 'chart_legends.dart';
import 'chart_painter.dart';

class WebbUIChart extends StatefulWidget {
  final List<ChartSeries> series;
  final ChartType chartType;
  final AxisType? xAxisType;
  final AxisType? yAxisType;
  final bool showLegends;
  final ChartConfig config;
  final String? emptyStateText;

  const WebbUIChart({
    super.key,
    required this.series,
    this.chartType = ChartType.line,
    this.xAxisType,
    this.yAxisType,
    this.showLegends = true,
    this.config = const ChartConfig(),
    this.emptyStateText,
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
    _initializeVisibility();
  }

  @override
  void didUpdateWidget(covariant WebbUIChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Reset visibility if series data changes significantly
    if (widget.series.length != oldWidget.series.length ||
        widget.series
            .any((s) => !oldWidget.series.any((os) => os.name == s.name))) {
      _initializeVisibility();
    }

    // Reset zoom and pan when chart type changes
    if (widget.chartType != oldWidget.chartType) {
      _scale = 1.0;
      _panOffset = Offset.zero;
    }
  }

  void _initializeVisibility() {
    _seriesVisibility.clear();
    for (var s in widget.series) {
      _seriesVisibility[s.name] = s.visible;
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

  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _panOffset = Offset.zero;
      _tapPosition = null;
    });
  }

  bool get _hasData {
    return widget.series.isNotEmpty &&
        widget.series.any((s) => s.data.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final visibleSeries =
        widget.series.where((s) => _seriesVisibility[s.name] ?? true).toList();

    return Column(
      children: [
        // Legend at the top if configured
        if (widget.showLegends &&
            _hasData &&
            widget.config.legendPosition == LegendPosition.top)
          ChartLegend(
            series: widget.series,
            visibility: _seriesVisibility,
            onLegendTapped: _onLegendTapped,
            position: widget.config.legendPosition,
            alignment: widget.config.legendAlignment,
          ),

        // Chart controls
        if (widget.chartType != ChartType.pie &&
            widget.chartType != ChartType.doughnut)
          Padding(
            padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.zoom_out_map,
                      size: webbTheme.iconTheme.smallSize),
                  onPressed: _resetZoom,
                  tooltip: 'Reset zoom',
                ),
              ],
            ),
          ),

        // Chart area
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: webbTheme.colorPalette.background,
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            ),
            child: _hasData
                ? GestureDetector(
                    onTapDown: (details) => _handleTap(details.localPosition),
                    onScaleUpdate: _handleScaleUpdate,
                    onDoubleTap: _resetZoom,
                    child: CustomPaint(
                      painter: ChartPainter(
                        series: visibleSeries,
                        chartType: widget.chartType,
                        xAxisType: widget.xAxisType,
                        yAxisType: widget.yAxisType,
                        tapPosition: _tapPosition,
                        scale: _scale,
                        panOffset: _panOffset,
                        webbTheme: webbTheme,
                        config: widget.config,
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                      widget.emptyStateText ?? 'No chart data available',
                      style: webbTheme.typography.bodyMedium.copyWith(
                        color:
                            webbTheme.colorPalette.neutralDark.withOpacity(0.5),
                      ),
                    ),
                  ),
          ),
        ),

        // Legend at the bottom if configured
        if (widget.showLegends &&
            _hasData &&
            widget.config.legendPosition == LegendPosition.bottom)
          ChartLegend(
            series: widget.series,
            visibility: _seriesVisibility,
            onLegendTapped: _onLegendTapped,
            position: widget.config.legendPosition,
            alignment: widget.config.legendAlignment,
          ),
      ],
    );
  }
}
