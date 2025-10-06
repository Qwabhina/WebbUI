import 'package:flutter/material.dart';
import 'chart_definitions.dart';

/// Renders the interactive legend for the chart.
class ChartLegend extends StatelessWidget {
  final List<ChartSeries> series;
  final Map<String, bool> visibility;
  final Function(String) onLegendTapped;

  const ChartLegend({
    super.key,
    required this.series,
    required this.visibility,
    required this.onLegendTapped,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0, right: 16.0),
      child: Wrap(
        spacing: 16.0,
        runSpacing: 8.0,
        alignment: WrapAlignment.center,
        children: series.map((s) {
          final bool isVisible = visibility[s.name] ?? true;
          return GestureDetector(
            onTap: () => onLegendTapped(s.name),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: isVisible
                      ? s.color
                      : colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(width: 6),
                Text(
                  s.name,
                  style: TextStyle(
                    color: isVisible
                        ? colorScheme.onSurface
                        : colorScheme.onSurface.withOpacity(0.5),
                    decoration: isVisible
                        ? TextDecoration.none
                        : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
