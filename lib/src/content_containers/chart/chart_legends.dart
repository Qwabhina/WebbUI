import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'chart_definitions.dart';

/// Interactive legend component for toggling series visibility
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

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    // Count visible items to handle empty state
    final visibleItems = series.where((s) => visibility[s.name] ?? true).length;
    if (visibleItems == 0) {
      return Padding(
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
        child: Text(
          'All series hidden - tap to show',
          style: webbTheme.typography.labelSmall.copyWith(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.5),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
      child: Wrap(
        spacing: webbTheme.spacingGrid.spacing(2),
        runSpacing: webbTheme.spacingGrid.spacing(1),
        alignment: WrapAlignment.center,
        children: series.map((seriesItem) {
          final bool isVisible = visibility[seriesItem.name] ?? true;

          return Tooltip(
            message: '${isVisible ? 'Hide' : 'Show'} ${seriesItem.name}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onLegendTapped(seriesItem.name),
                borderRadius: BorderRadius.circular(
                  webbTheme.spacingGrid.baseSpacing,
                ),
                child: Padding(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(0.5)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Color indicator
                      Container(
                        width: webbTheme.spacingGrid.spacing(1.5),
                        height: webbTheme.spacingGrid.spacing(1.5),
                        decoration: BoxDecoration(
                          color: isVisible
                              ? seriesItem.color
                              : webbTheme.colorPalette.neutralDark
                                  .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                            webbTheme.spacingGrid.baseSpacing / 2,
                          ),
                        ),
                      ),
                      SizedBox(width: webbTheme.spacingGrid.spacing(1)),
                      // Series name
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
            ),
          );
        }).toList(),
      ),
    );
  }
}
