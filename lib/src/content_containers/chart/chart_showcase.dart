import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'chart.dart';

/// An example screen that demonstrates how to use the WebbUIChart widget.
class ChartShowcaseScreen extends StatefulWidget {
  const ChartShowcaseScreen({super.key});

  @override
  State<ChartShowcaseScreen> createState() => _ChartShowcaseScreenState();
}

class _ChartShowcaseScreenState extends State<ChartShowcaseScreen> {
  late List<ChartSeries> _seriesData;
  ChartType _currentChartType = ChartType.line;
  bool _showLegends = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _seriesData = _generateSampleData();
    _startLiveData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Generates initial sample data for the chart.
  List<ChartSeries> _generateSampleData() {
    final random = Random();
    return [
      ChartSeries(
        name: 'Product A',
        color: Colors.cyan,
        chartType: _currentChartType,
        data: List.generate(
            8, (index) => ChartData(index + 1, random.nextDouble() * 100 + 50)),
      ),
      ChartSeries(
        name: 'Product B',
        color: Colors.amber,
        chartType: _currentChartType,
        data: List.generate(
            8, (index) => ChartData(index + 1, random.nextDouble() * 80 + 30)),
      ),
      if (_currentChartType.name.contains('stacked'))
        ChartSeries(
          name: 'Product C',
          color: Colors.pinkAccent,
          chartType: _currentChartType,
          data: List.generate(8,
              (index) => ChartData(index + 1, random.nextDouble() * 60 + 20)),
        ),
    ];
  }

  /// Simulates live data updates every 2 seconds.
  void _startLiveData() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final random = Random();
      setState(() {
        for (var series in _seriesData) {
          if (series.data.isNotEmpty) {
            final lastX = series.data.last.x;
            series.data.removeAt(0);
            series.data.add(ChartData(
                lastX + 1,
                random.nextDouble() * 100 +
                    (series.name == 'Product A' ? 50 : 30)));
          }
        }
      });
    });
  }

  /// Handles changing the chart type from the UI.
  void _onChartTypeChanged(ChartType? type) {
    if (type != null) {
      _timer?.cancel();
      setState(() {
        _currentChartType = type;
        _seriesData = _generateSampleData();
      });
      _startLiveData();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPieChart = _currentChartType == ChartType.pie ||
        _currentChartType == ChartType.doughnut;

    return Scaffold(
      appBar: AppBar(
        title: const Text('WebbUIChart Showcase'),
        elevation: 4,
        backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      ),
      body: Column(
        children: [
          // Chart Widget
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: WebbUIChart(
                series: _seriesData,
                chartType: _currentChartType,
                xAxisType: isPieChart ? null : AxisType.numeric,
                yAxisType: isPieChart ? null : AxisType.numeric,
                showLegends: _showLegends,
                // Unique key to force recreation when chart type changes
                key: ValueKey(_currentChartType),
              ),
            ),
          ),
          // Controls Section
          _buildControls(),
        ],
      ),
    );
  }

  /// Builds the control panel for changing chart settings.
  Widget _buildControls() {
    return Card(
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      margin: const EdgeInsets.all(8.0),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: [
            DropdownButton<ChartType>(
              value: _currentChartType,
              dropdownColor: Theme.of(context).colorScheme.surface,
              onChanged: _onChartTypeChanged,
              items: ChartType.values.map((ChartType type) {
                return DropdownMenuItem<ChartType>(
                  value: type,
                  child: Text(type.name),
                );
              }).toList(),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Show Legends'),
                Switch(
                  value: _showLegends,
                  onChanged: (value) {
                    setState(() {
                      _showLegends = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
