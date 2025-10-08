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
    // Watch the state manager to get column definitions and current sort state
    final state = context.watch<TableStateManager<T>>();
    final webbTheme = context;
    final typography =
        webbTheme.typography.labelLarge.copyWith(fontWeight: FontWeight.bold);

    // Header container styling
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: webbTheme.spacingGrid.spacing(1),
      ),
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralDark
            .withOpacity(0.05), // Light background for header
        border: Border(
          bottom: BorderSide(
              color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
              width: 1.0),
        ),
      ),
      child: Row(
        children: state.columns.map((column) {
          final isSorting = state.sortColumnId == column.id;
          final isAscending = state.isAscending;

          // Wrap title in a widget that handles sorting click
          Widget columnTitle = GestureDetector(
            onTap:
                column.isSortable ? () => state.setSortColumn(column.id) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Column Title (using custom title renderer if provided)
                if (column.titleRenderer != null)
                  column.titleRenderer!(context, column)
                else
                  Text(column.title, style: typography),

                // 2. Sort Icon
                if (column.isSortable) ...[
                  SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),
                  Icon(
                    isSorting
                        ? (isAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)
                        : Icons.sort_by_alpha, // Default icon when not sorted
                    size: webbTheme.iconTheme.smallSize,
                    color: isSorting
                        ? webbTheme.colorPalette.primary
                        : webbTheme.colorPalette.neutralDark.withOpacity(0.5),
                  ),
                ],
              ],
            ),
          );

          // Final cell structure uses Expanded with flex factor
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
