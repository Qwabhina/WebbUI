import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'package:webb_ui/src/feedback_status/loaders/spinner.dart';
import 'package:webb_ui/src/forms_inputs/text_input/text_input.dart';
import 'package:webb_ui/src/theme.dart';
import 'table_models.dart';
import 'table_state_manager.dart';

/// Renders the main data area of the table, including rows and cells.
/// It handles row selection, cell editing, and lazy loading.
class WebbUITableBody<T> extends StatefulWidget {
  const WebbUITableBody({super.key});

  @override
  State<WebbUITableBody<T>> createState() => _WebbUITableBodyState<T>();
}

class _WebbUITableBodyState<T> extends State<WebbUITableBody<T>> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Listener for infinite scrolling.
  void _onScroll() {
    final stateManager =
        Provider.of<TableStateManager<T>>(context, listen: false);
    if (stateManager.isInfiniteScroll &&
        !stateManager.isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      // Load more data when user is 200px from the bottom
      stateManager.loadMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<TableStateManager<T>>(context);
    final webbTheme = context;

    if (stateManager.isLoading && stateManager.isInitialLoad) {
      return const Center(child: WebbUISpinner());
    }

    if (stateManager.rows.isEmpty) {
      return const Center(child: Text("No data available."));
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: stateManager.rows.length + (stateManager.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Show a spinner at the end if loading more data
        if (index == stateManager.rows.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: WebbUISpinner()),
          );
        }

        final row = stateManager.rows[index];
        final isSelected = stateManager.selectedRows.contains(row);

        return Material(
          color: isSelected
              ? webbTheme.interactionStates.pressedOverlay
              : row.color ?? Colors.transparent,
          child: InkWell(
            onTap: () => stateManager.toggleRowSelection(row),
            hoverColor: webbTheme.interactionStates.hoverOverlay,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox for row selection
                  if (stateManager.isRowSelectionEnabled)
                    SizedBox(
                      width: 60,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (isSelected) =>
                            stateManager.toggleRowSelection(row),
                      ),
                    ),
                  // Render all cells for the row
                  ...stateManager.columns.map((col) {
                    final cellData = row.data[col.id];
                    return _TableCellWidget(
                      key: ValueKey('${row.id}-${col.id}'),
                      row: row,
                      column: col,
                      data: cellData,
                    );
                  }),
                  // }).toList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A widget that renders a single cell and handles editing.
class _TableCellWidget<T> extends StatelessWidget {
  final WebbUIRow<T> row;
  final WebbUIColumn<T> column;
  final dynamic data;

  const _TableCellWidget({
    super.key,
    required this.row,
    required this.column,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<TableStateManager<T>>(context);
    final isEditing = stateManager.editingCell?.rowId == row.id &&
        stateManager.editingCell?.columnId == column.id;

    // Use the custom renderer if provided, otherwise use the editor or default text
    Widget content;
    if (isEditing) {
      content = _buildCellEditor(context, data);
    } else {
      if (column.cellRenderer != null) {
        content = column.cellRenderer!(context, data, row);
      } else {
        content = Text(data?.toString() ?? '', overflow: TextOverflow.ellipsis);
      }
    }

    return Expanded(
      flex: column.widthFlex,
      child: GestureDetector(
        onTap: () => stateManager.setEditingCell(row.id, column.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          alignment: column.alignment,
          child: content,
        ),
      ),
    );
  }

  /// Builds the appropriate editor based on the column type.
  Widget _buildCellEditor(BuildContext context, dynamic currentValue) {
    switch (column.columnType) {
      case WebbUIColumnType.text:
        return WebbUITextField(
          controller: TextEditingController(text: currentValue.toString()),
          onChanged: (newValue) {
            // In a real app, you'd likely want a "save" button
            // or update the stateManager on lost focus.
          },
        );
      case WebbUIColumnType.number:
      case WebbUIColumnType.currency:
      case WebbUIColumnType.percentage:
        return WebbUITextField(
          controller: TextEditingController(text: currentValue.toString()),
          keyboardType: TextInputType.number,
        );
      case WebbUIColumnType.boolean:
        return WebbUICheckbox(
          value: currentValue as bool? ?? false,
          onChanged: (newValue) {},
        );
      case WebbUIColumnType.selection:
        return WebbUIDropdown<dynamic>(
          value: currentValue,
          items: column.selectionOptions
                  ?.map((opt) => DropdownMenuItem(value: opt, child: Text(opt)))
                  .toList() ??
              [],
          onChanged: (newValue) {},
        );
      case WebbUIColumnType.date:
        // Simplified; a real implementation would show a picker.
        return Text(currentValue?.toString() ?? "Select Date");
      default:
        return Text(currentValue?.toString() ?? '');
    }
  }
}
