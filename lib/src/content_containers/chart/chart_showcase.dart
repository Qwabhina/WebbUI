import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:webb_ui/webb_ui.dart'
    show
        AxisType,
        ChartConfig,
        ChartData,
        ChartSeries,
        ChartType,
        LegendPosition,
        WebbUIChart;

class ChartShowcase extends StatelessWidget {
  const ChartShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chart Module Showcase',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChartShowcaseScreen(),
    );
  }
}

class ChartShowcaseScreen extends StatelessWidget {
  const ChartShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chart Module Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('1. Line Chart (Numeric Axis)'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateNumericSeries(),
              chartType: ChartType.line,
              xAxisType: AxisType.numeric,
              interactive: true,
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('2. Area Chart (DateTime Axis)'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateDateTimeSeries(),
              chartType: ChartType.area,
              xAxisType: AxisType.dateTime,
              interactive: true,
              config: const ChartConfig(showGrid: false),
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('3. Column Chart (Category Axis, Multi-Series)'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateCategorySeries(),
              chartType: ChartType.column,
              xAxisType: AxisType.category,
              interactive: true,
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('4. Stacked Column Chart (With Negatives)'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateStackedSeriesWithNegatives(),
              chartType: ChartType.stackedColumn,
              xAxisType: AxisType.numeric,
              interactive: true,
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('5. Stacked Area Chart'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateStackedSeries(),
              chartType: ChartType.stackedArea,
              xAxisType: AxisType.numeric,
              interactive: true,
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('6. Pie Chart'),
          _buildChartContainer(
            WebbUIChart(
              series: _generatePieSeries(),
              chartType: ChartType.pie,
              interactive: false, // No zoom/pan for circular
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('7. Doughnut Chart'),
          _buildChartContainer(
            WebbUIChart(
              series: _generatePieSeries(),
              chartType: ChartType.doughnut,
              interactive: false,
              showLegends: true,
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('8. Bar Chart (Horizontal, Custom Config)'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateNumericSeries(),
              chartType: ChartType.bar,
              xAxisType: AxisType.numeric,
              interactive: true,
              config: const ChartConfig(
                legendPosition: LegendPosition.top,
                showLabels: false,
                gridTickCount: 10,
              ),
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('9. Empty State Handling'),
          _buildChartContainer(
            const WebbUIChart(
              series: [],
              chartType: ChartType.line,
              emptyStateText: 'Custom Empty Message',
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionTitle('10. Data Point Tap Callback'),
          _buildChartContainer(
            WebbUIChart(
              series: _generateNumericSeries(),
              chartType: ChartType.line,
              interactive: true,
              onDataPointTapped: (point) {
                if (point != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Tapped: X=${point.x}, Y=${point.y}')),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChartContainer(Widget chart) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: chart,
    );
  }

  // Sample Data Generators

  List<ChartSeries> _generateNumericSeries() {
    final random = math.Random();
    return [
      ChartSeries(
        name: 'Series 1',
        color: Colors.blue,
        data: List.generate(
            10, (i) => ChartData(i + 1, random.nextDouble() * 100)),
      ),
      ChartSeries(
        name: 'Series 2',
        color: Colors.green,
        data: List.generate(
            10, (i) => ChartData(i + 1, random.nextDouble() * 100)),
      ),
    ];
  }

  List<ChartSeries> _generateDateTimeSeries() {
    final now = DateTime.now();
    final random = math.Random();
    return [
      ChartSeries(
        name: 'Daily Data',
        color: Colors.red,
        data: List.generate(
            7,
            (i) => ChartData(
                now.subtract(Duration(days: 6 - i)), random.nextDouble() * 50)),
      ),
    ];
  }

  List<ChartSeries> _generateCategorySeries() {
    final categories = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    final random = math.Random();
    return [
      ChartSeries(
        name: 'Sales A',
        color: Colors.orange,
        data: categories
            .map((cat) => ChartData(cat, random.nextDouble() * 200))
            .toList(),
      ),
      ChartSeries(
        name: 'Sales B',
        color: Colors.purple,
        data: categories
            .map((cat) => ChartData(cat, random.nextDouble() * 200))
            .toList(),
      ),
    ];
  }

  List<ChartSeries> _generateStackedSeries() {
    final random = math.Random();
    return List.generate(
        3,
        (j) => ChartSeries(
              name: 'Stack $j',
              color: Colors.primaries[j * 3],
              data: List.generate(
                  5, (i) => ChartData(i + 1, random.nextDouble() * 50 + 10)),
            ));
  }

  List<ChartSeries> _generateStackedSeriesWithNegatives() {
    final random = math.Random();
    return List.generate(
        3,
        (j) => ChartSeries(
              name: 'Stack $j',
              color: Colors.primaries[j * 3],
              data: List.generate(5,
                  (i) => ChartData(i + 1, (random.nextDouble() - 0.5) * 100)),
            ));
  }

  List<ChartSeries> _generatePieSeries() {
    final random = math.Random();
    return [
      ChartSeries(
        name: 'Pie Data',
        color: Colors.blue,
        data: List.generate(
            5, (i) => ChartData('Slice $i', random.nextDouble() * 100 + 20)),
      ),
    ];
  }
}
