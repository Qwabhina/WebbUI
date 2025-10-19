import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';

class ChartLegend extends StatelessWidget {
  final List<ChartSeries> series;
  final Map<String, bool> visibility;
  final Function(String) onLegendTapped;
  final LegendPosition position;
  final LegendAlignment alignment;

  const ChartLegend({
    super.key,
    required this.series,
    required this.visibility,
    required this.onLegendTapped,
    this.position = LegendPosition.bottom,
    this.alignment = LegendAlignment.center,
  });

  MainAxisAlignment get mainAxisAlignment {
    switch (alignment) {
      case LegendAlignment.start:
        return MainAxisAlignment.start;
      case LegendAlignment.center:
        return MainAxisAlignment.center;
      case LegendAlignment.end:
        return MainAxisAlignment.end;
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    final visibleItems = series.where((s) => visibility[s.name] ?? true).length;
    if (visibleItems == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
      child: Wrap(
        spacing: webbTheme.spacingGrid.spacing(2),
        runSpacing: webbTheme.spacingGrid.spacing(1),
        alignment: WrapAlignment.center,
        children: series.map((seriesItem) {
          final bool isVisible = visibility[seriesItem.name] ?? true;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onLegendTapped(seriesItem.name),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
              child: Padding(
                padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(0.5)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: webbTheme.spacingGrid.spacing(1.5),
                      height: webbTheme.spacingGrid.spacing(1.5),
                      decoration: BoxDecoration(
                        color: isVisible
                            ? seriesItem.color
                            : webbTheme.colorPalette.neutralDark
                                .withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                            webbTheme.spacingGrid.baseSpacing / 2),
                      ),
                    ),
                    SizedBox(width: webbTheme.spacingGrid.spacing(1)),
                    Text(
                      seriesItem.name,
                      style: webbTheme.typography.labelMedium.copyWith(
                        color: isVisible 
                            ? webbTheme.colorPalette.neutralDark
                            : webbTheme.colorPalette.neutralDark
                                .withOpacity(0.5),
                        decoration: isVisible
                            ? TextDecoration.none
                            : TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
