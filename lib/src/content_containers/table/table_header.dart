import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/theme.dart';
import 'table_state_manager.dart';

/// Renders the fixed table header row with column titles, sorting icons,
/// and responsive width handling.
class WebbUITableHeader<T> extends StatelessWidget {
  const WebbUITableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TableStateManager<T>>();
    final webbTheme = context;
    final typography = webbTheme.typography.labelLarge.copyWith(
      fontWeight: FontWeight.w600,
      color: webbTheme.colorPalette.neutralDark,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: webbTheme.spacingGrid.spacing(1.5),
      ),
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.03),
        border: Border(
          bottom: BorderSide(
            color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        children: state.columns.map((column) {
          final isSorting = state.sortColumnId == column.id;
          final isAscending = state.isAscending;

          Widget columnTitle = Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: column.isSortable
                  ? () => state.setSortColumn(column.id)
                  : null,
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
              child: Container(
                padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Column Title
                    if (column.titleRenderer != null)
                      column.titleRenderer!(context, column)
                    else
                      Text(
                        column.title,
                        style: typography,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Sort Icon
                    if (column.isSortable) ...[
                      SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),
                      Icon(
                        isSorting
                            ? (isAscending
                                ? Icons.arrow_upward
                                : Icons.arrow_downward)
                            : Icons.unfold_more,
                        size: webbTheme.iconTheme.smallSize,
                        color: isSorting
                            ? webbTheme.colorPalette.primary
                            : webbTheme.colorPalette.neutralDark
                                .withOpacity(0.4),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );

          return Expanded(
            flex: column.widthFlex,
            child: Align(
              alignment: column.alignment,
              child: columnTitle,
            ),
          );
        }).toList(),
      ),
    );
  }
}
