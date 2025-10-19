import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/theme.dart';
import 'table_body.dart';
import 'table_footer.dart';
import 'table_header.dart';
import 'table_models.dart';
import 'table_state_manager.dart';

/// The main, public-facing widget for the WebbUI data table.
/// It uses the Provider pattern to manage the table's state (sorting, pagination, etc.)
/// and composes the header, body, and footer components.
class WebbUITable<T> extends StatelessWidget {
  /// Defines the structure and behavior of each column.
  final List<WebbUIColumn<T>> columns;

  /// The initial dataset to be displayed.
  final List<WebbUIRow<T>> rows;

  /// Number of items to display per page if pagination is enabled.
  final int itemsPerPage;

  /// Whether client-side pagination should be enabled.
  final bool isPaginated;

  /// Whether the table should load new data automatically on scroll (infinite scroll).
  final bool isInfiniteScroll;

  /// Custom widget displayed above the table (e.g., title, global search).
  final Widget? header;

  /// Whether rows can be selected by the user.
  final bool isRowSelectionEnabled;

  /// Custom widget to display below the table body, replacing the default
  /// pagination controls if [isPaginated] is true.
  final Widget? customFooter;
  final double? maxHeight;

  const WebbUITable({
    super.key,
    required this.columns,
    required this.rows,
    this.itemsPerPage = 10,
    this.isPaginated = false,
    this.isInfiniteScroll = false,
    this.header,
    this.isRowSelectionEnabled = true,
    this.customFooter,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final screenHeight = MediaQuery.of(context).size.height;
    final effectiveMaxHeight = maxHeight ?? screenHeight * 0.6;

    // Use ChangeNotifierProvider to initialize and manage the table state.
    return ChangeNotifierProvider<TableStateManager<T>>(
      create: (context) => TableStateManager<T>(
        columns: columns,
        initialRows: rows,
        itemsPerPage: itemsPerPage,
        isPaginated: isPaginated,
        isRowSelectionEnabled: isRowSelectionEnabled,
        isInfiniteScroll: isInfiniteScroll,
      ),
      builder: (context, child) {
        // We use Builder to ensure we can access the TableStateManager via context.watch
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Custom Header (e.g., global filter, title) ---
            if (header != null)
              Padding(
                padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                child: header!,
              ),

            // --- Table Structure ---
            // Table container with proper constraints
            Container(
              constraints: BoxConstraints(
                maxHeight: effectiveMaxHeight,
                minHeight: 200, // Minimum height for empty states
              ),
              decoration: BoxDecoration(
                color: webbTheme.colorPalette.surface,
                borderRadius:
                    BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
                boxShadow: webbTheme.elevation.getShadows(1),
                border: Border.all(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Fixed header
                  WebbUITableHeader<T>(),

                  // Scrollable body
                  Expanded(
                    child: WebbUITableBody<T>(),
                  ),
                ],
              ),
            ),

            // Footer
            if (isPaginated || customFooter != null)
              Padding(
                padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                child: WebbUITableFooter<T>(
                  customFooter: customFooter,
                ),
              ),
          ],
        );
      },
    );
  }
}
