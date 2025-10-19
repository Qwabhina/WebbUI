import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'package:webb_ui/src/feedback_status/loaders/spinner.dart';
import 'package:webb_ui/src/forms_inputs/text_input/editable_text_field.dart';
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

  void _onScroll() {
    final stateManager =
        Provider.of<TableStateManager<T>>(context, listen: false);
    if (stateManager.isInfiniteScroll &&
        !stateManager.isLoading &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
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
      return Center(
        child: Padding(
          padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(4)),
          child: Text(
            "No data available",
            style: webbTheme.typography.bodyMedium.copyWith(
              color: webbTheme.colorPalette.neutralDark.withOpacity(0.5),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: stateManager.rows.length + (stateManager.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == stateManager.rows.length) {
          return Padding(
            padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            child: const Center(child: WebbUISpinner()),
          );
        }

        final row = stateManager.rows[index];
        final isSelected = stateManager.selectedRows.contains(row);

        return Material(
          color: isSelected
              ? webbTheme.colorPalette.primary.withOpacity(0.1)
              : row.color ?? Colors.transparent,
          child: InkWell(
            onTap: () => stateManager.toggleRowSelection(row),
            hoverColor: webbTheme.interactionStates.hoverOverlay,
            splashColor: webbTheme.interactionStates.pressedOverlay,
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
                      child: Padding(
                        padding:
                            EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
                        child: WebbUICheckbox(
                          value: isSelected,
                          onChanged: (value) =>
                              stateManager.toggleRowSelection(row),
                        ),
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
                      onEditComplete: (newValue) {
                        stateManager.updateCellValue(row.id, col.id, newValue);
                      },
                      onEditCancel: () {
                        stateManager.clearEditingCell();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TableCellWidget<T> extends StatelessWidget {
  final WebbUIRow<T> row;
  final WebbUIColumn<T> column;
  final dynamic data;
  final Function(dynamic) onEditComplete;
  final VoidCallback onEditCancel;

  const _TableCellWidget({
    super.key,
    required this.row,
    required this.column,
    required this.data,
    required this.onEditComplete,
    required this.onEditCancel,
  });

  @override
  Widget build(BuildContext context) {
    final stateManager =
        Provider.of<TableStateManager<T>>(context, listen: false);
    final isEditing = stateManager.editingCell?.rowId == row.id &&
        stateManager.editingCell?.columnId == column.id;

    Widget content;
    
    if (isEditing) {
      // Use WebbUIEditableTextField for editing mode
      content = _buildCellEditor(context);
    } else {
      // Use custom renderer or default text for display mode
      if (column.cellRenderer != null) {
        content = column.cellRenderer!(context, data, row);
      } else {
        content = Text(
          data?.toString() ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      }
    }

    return Expanded(
      flex: column.widthFlex,
      child: GestureDetector(
        onTap: () {
          if (!isEditing && column.columnType != WebbUIColumnType.boolean) {
            stateManager.setEditingCell(row.id, column.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          alignment: column.alignment,
          child: content,
        ),
      ),
    );
  }

  Widget _buildCellEditor(BuildContext context) {
    // Use custom editor if provided
    if (column.editCellRenderer != null) {
      return column.editCellRenderer!(
        context,
        data,
        onEditComplete,
        row,
      );
    }

    // Use WebbUIEditableTextField for text-based columns
    if (_isTextBasedColumn(column.columnType)) {
      return WebbUIEditableTextField(
        initialValue: data?.toString() ?? '',
        onSave: onEditComplete,
        onCancel: onEditCancel,
        showActions:
            false, // Hide buttons for table cells - use keyboard shortcuts
        autoFocus: true,
        clearOnCancel: false, // Restore original value on cancel
      );
    }

    // Special handling for boolean columns
    if (column.columnType == WebbUIColumnType.boolean) {
      return _buildBooleanEditor(context);
    }

    // Special handling for selection columns
    if (column.columnType == WebbUIColumnType.selection) {
      return _buildSelectionEditor(context);
    }

    // Fallback to basic text field
    return WebbUIEditableTextField(
      initialValue: data?.toString() ?? '',
      onSave: onEditComplete,
      onCancel: onEditCancel,
      showActions: false,
      autoFocus: true,
    );
  }

  bool _isTextBasedColumn(WebbUIColumnType columnType) {
    return [
      WebbUIColumnType.text,
      WebbUIColumnType.number,
      WebbUIColumnType.currency,
      WebbUIColumnType.percentage,
      WebbUIColumnType.date,
      WebbUIColumnType.time,
      WebbUIColumnType.dateTime,
    ].contains(columnType);
  }

  Widget _buildBooleanEditor(BuildContext context) {
    final webbTheme = context;
    final currentValue = data as bool? ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        WebbUICheckbox(
          value: currentValue,
          onChanged: (value) => onEditComplete(value),
        ),
        SizedBox(width: webbTheme.spacingGrid.spacing(1)),
        // Optional: Add quick save/cancel for boolean fields
        WebbUIButton(
          label: 'Save',
          onPressed: () => onEditComplete(currentValue),
          variant: WebbUIButtonVariant.primary,
        ),
        SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),
        WebbUIButton(
          label: 'Cancel',
          onPressed: onEditCancel,
          variant: WebbUIButtonVariant.tertiary,
        ),
      ],
    );
  }

  Widget _buildSelectionEditor(BuildContext context) {
    return WebbUIDropdown<dynamic>(
      value: data,
      items: column.selectionOptions
              ?.map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt.toString()),
                  ))
              .toList() ??
          [],
      onChanged: (newValue) {
        onEditComplete(newValue);
        onEditCancel(); // Auto-close after selection
      },
    );
  }
}
