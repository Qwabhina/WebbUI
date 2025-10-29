import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';
import 'chart_legends.dart';
import 'chart_painter.dart';

/// A comprehensive, interactive chart component supporting multiple chart types
/// and extensive customization through WebbUI's design system.
///
/// Features:
/// - Multiple chart types (line, bar, column, area, pie, doughnut, stacked variants)
/// - Interactive zoom, pan, and tooltips
/// - Legend toggling for series visibility
/// - Responsive design with proper theming
/// - Empty state handling
/// - Accessibility support
/// Now with category axis support and improved multi-series handling.
class WebbUIChart extends StatefulWidget {
  final List<ChartSeries> series;
  final ChartType chartType;
  final AxisType xAxisType;
  final AxisType yAxisType;
  final bool showLegends;
  final ChartConfig config;
  final String? emptyStateText;
  final double aspectRatio;
  final bool interactive;
  final ValueChanged<ChartData?>? onDataPointTapped;

  const WebbUIChart({
    super.key,
    required this.series,
    this.chartType = ChartType.line,
    this.xAxisType = AxisType.numeric,
    this.yAxisType = AxisType.numeric,
    this.showLegends = true,
    this.config = const ChartConfig(),
    this.emptyStateText,
    this.aspectRatio = 16 / 9,
    this.interactive = true,
    this.onDataPointTapped,
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

  /// Initializes series visibility based on the series' visible property.
  void _initializeVisibility() {
    _seriesVisibility.clear();
    for (var s in widget.series) {
      _seriesVisibility[s.name] = s.visible;
    }
  }

  /// Handles scale updates for zooming functionality.
  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (!widget.interactive) return;
    
    setState(() {
      if (details.scale != 1.0) {
        _scale = (_scale * details.scale).clamp(0.5, 5.0);
      }
      _panOffset += details.focalPointDelta;
      _tapPosition = null; // Clear tooltip on pan/zoom
    });
  }

  /// Handles tap events for tooltip display and data point selection.
  void _handleTap(Offset localPosition) {
    if (!widget.interactive) return;
    
    setState(() {
      _tapPosition = localPosition;
    });

    // Use coordSystem to find nearest, but since not painted yet, approximate
    final nearest = _approximateNearest(localPosition);
    widget.onDataPointTapped?.call(nearest);
  }

  /// Approximates nearest point without full painter (for tap callback).
  ChartData? _approximateNearest(Offset localPosition) {
    // Simplified; in practice, create temp coordSystem
    for (final s in widget.series) {
      if (s.data.isNotEmpty) return s.data.first;
    }
    return null;
  }

  /// Toggles series visibility when legend items are tapped.
  void _onLegendTapped(String seriesName) {
    setState(() {
      _seriesVisibility[seriesName] = !_seriesVisibility[seriesName]!;
    });
  }

  /// Resets zoom and pan to default values.
  void _resetZoom() {
    setState(() {
      _scale = 1.0;
      _panOffset = Offset.zero;
      _tapPosition = null;
    });
  }

  /// Returns true if there's any visible data to display.
  bool get _hasData {
    return widget.series.isNotEmpty &&
        widget.series.any(
            (s) => (_seriesVisibility[s.name] ?? true) && s.data.isNotEmpty);
  }

  /// Returns true for circular chart types (pie/doughnut).
  bool get _isCircularChart {
    return widget.chartType == ChartType.pie ||
        widget.chartType == ChartType.doughnut;
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    
    // Get only visible series for painting
    final visibleSeries =
        widget.series.where((s) => _seriesVisibility[s.name] ?? true).toList();

    return Semantics(
      label: 'Chart displaying ${widget.series.length} data series',
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- TOP LEGEND ---
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

            // --- CHART CONTROLS (only for non-circular, interactive charts) ---
            if (widget.interactive && !_isCircularChart && _hasData)
              _buildChartControls(webbTheme),

            // --- MAIN CHART AREA ---
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: webbTheme.colorPalette.background,
                  borderRadius: BorderRadius.circular(
                    webbTheme.spacingGrid.baseSpacing,
                  ),
                  border: Border.all(
                    color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: _hasData
                    ? _buildChartContent(webbTheme, visibleSeries)
                    : _buildEmptyState(webbTheme),
              ),
            ),

            // --- BOTTOM LEGEND ---
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
        ),
      ),
    );
  }

  /// Builds chart controls (zoom reset button).
  Widget _buildChartControls(BuildContext webbTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: webbTheme.spacingGrid.spacing(1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Zoom reset button
          if (_scale != 1.0 || _panOffset != Offset.zero)
            Tooltip(
              message: 'Reset zoom and pan',
              child: InkWell(
                onTap: _resetZoom,
                borderRadius: BorderRadius.circular(
                  webbTheme.spacingGrid.baseSpacing,
                ),
                child: Container(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
                  decoration: BoxDecoration(
                    color: webbTheme.colorPalette.surface,
                    borderRadius: BorderRadius.circular(
                      webbTheme.spacingGrid.baseSpacing,
                    ),
                    border: Border.all(
                      color:
                          webbTheme.colorPalette.neutralDark.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_out_map,
                        size: webbTheme.iconTheme.smallSize,
                        color: webbTheme.colorPalette.neutralDark,
                      ),
                      SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),
                      Text(
                        'Reset View',
                        style: webbTheme.typography.labelSmall.copyWith(
                          color: webbTheme.colorPalette.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the main chart content with gesture support.
  Widget _buildChartContent(
    BuildContext webbTheme,
    List<ChartSeries> visibleSeries,
  ) {
    return GestureDetector(
      onTapDown: (details) => _handleTap(details.localPosition),
      onScaleUpdate: widget.interactive ? _handleScaleUpdate : null,
      onDoubleTap: widget.interactive ? _resetZoom : null,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: WebbUIChartPainter(
          series: visibleSeries,
          chartType: widget.chartType,
          config: widget.config,
          tapPosition: _tapPosition,
          scale: _scale,
          panOffset: _panOffset,
          webbTheme: webbTheme,
          xAxisType: widget.xAxisType,
        ),
      ),
    );
  }

  /// Builds the empty state when no data is available.
  Widget _buildEmptyState(BuildContext webbTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: webbTheme.iconTheme.largeSize * 2,
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.3),
          ),
          SizedBox(height: webbTheme.spacingGrid.spacing(2)),
          Text(
            widget.emptyStateText ?? 'No chart data available',
            style: webbTheme.typography.bodyMedium.copyWith(
              color: webbTheme.colorPalette.neutralDark.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.series.isNotEmpty &&
              widget.series.every((s) => !(_seriesVisibility[s.name] ?? true)))
            Padding(
              padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(1)),
              child: Text(
                'All series are hidden. Use the legend to show data.',
                style: webbTheme.typography.labelSmall.copyWith(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
