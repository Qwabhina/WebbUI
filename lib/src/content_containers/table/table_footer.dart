import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/theme.dart';
import 'table_state_manager.dart';

/// Renders the table footer, responsible for pagination controls or a custom widget.
class WebbUITableFooter<T> extends StatelessWidget {
  /// Optional custom widget to display instead of default pagination.
  final Widget? customFooter;

  const WebbUITableFooter({super.key, this.customFooter});

  @override
  Widget build(BuildContext context) {
    // If a custom footer is provided, use it directly.
    if (customFooter != null) {
      return customFooter!;
    }

    // Watch the state manager to get pagination information
    final state = context.watch<TableStateManager<T>>();
    final webbTheme = context;

    // Only show default footer if paginated and there is more than one page
    if (!state.isPaginated || state.totalPages <= 1) {
      return const SizedBox.shrink();
    }

    final currentPage = state.currentPage;
    final totalPages = state.totalPages;
    final isFirstPage = currentPage == 0;
    final isLastPage = currentPage == totalPages - 1;

    return Container(
      padding: EdgeInsets.symmetric(vertical: webbTheme.spacingGrid.spacing(1)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Page Info
          Text(
            'Page ${currentPage + 1} of $totalPages',
            style: webbTheme.typography.bodyMedium,
          ),

          // Right side: Pagination Controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous Button
              IconButton(
                icon: Icon(Icons.arrow_back_ios,
                    size: webbTheme.iconTheme.smallSize),
                onPressed:
                    isFirstPage ? null : () => state.setPage(currentPage - 1),
                color: webbTheme.colorPalette.primary,
                disabledColor:
                    webbTheme.colorPalette.neutralDark.withOpacity(0.3),
              ),

              SizedBox(width: webbTheme.spacingGrid.spacing(1)),

              // Next Button
              IconButton(
                icon: Icon(Icons.arrow_forward_ios,
                    size: webbTheme.iconTheme.smallSize),
                onPressed:
                    isLastPage ? null : () => state.setPage(currentPage + 1),
                color: webbTheme.colorPalette.primary,
                disabledColor:
                    webbTheme.colorPalette.neutralDark.withOpacity(0.3),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
