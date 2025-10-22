import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'package:webb_ui/src/feedback_status/loaders/spinner.dart';
import 'package:webb_ui/src/forms_inputs/text_input/editable_textfield.dart';
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
class _TableCellWidget<T> extends StatefulWidget {
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
  State<_TableCellWidget<T>> createState() => __TableCellWidgetState<T>();
}

class __TableCellWidgetState<T> extends State<_TableCellWidget<T>> {
  @override
  Widget build(BuildContext context) {
    final stateManager = Provider.of<TableStateManager<T>>(context);
    final isEditing = stateManager.editingCell?.rowId == widget.row.id &&
        stateManager.editingCell?.columnId == widget.column.id;

    Widget content;
    
    if (isEditing) {
      content = _buildCellEditor(context);
    } else {
      if (widget.column.cellRenderer != null) {
        content = widget.column.cellRenderer!(context, widget.data, widget.row);
      } else {
        content = Text(
          _formatDisplayValue(widget.data, widget.column.columnType),
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      }
    }

    return Expanded(
      flex: widget.column.widthFlex,
      child: GestureDetector(
        onTap: () {
          if (!isEditing && _isEditableColumn(widget.column.columnType)) {
            stateManager.setEditingCell(widget.row.id, widget.column.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 12.0,
          ),
          alignment: widget.column.alignment,
          child: content,
        ),
      ),
    );
  }

  bool _isEditableColumn(WebbUIColumnType columnType) {
    return columnType !=
        WebbUIColumnType.boolean; // Boolean handled by checkbox directly
  }

  String _formatDisplayValue(dynamic data, WebbUIColumnType columnType) {
    if (data == null) return '';

    switch (columnType) {
      case WebbUIColumnType.currency:
        return '\$${data.toStringAsFixed(2)}';
      case WebbUIColumnType.percentage:
        return '${data.toStringAsFixed(1)}%';
      case WebbUIColumnType.number:
        return data.toString();
      case WebbUIColumnType.boolean:
        return data ? 'Yes' : 'No';
      default:
        return data.toString();
    }
  }

  Widget _buildCellEditor(BuildContext context) {
    if (widget.column.editCellRenderer != null) {
      return widget.column.editCellRenderer!(
        context,
        widget.data,
        widget.onEditComplete,
        widget.row,
      );
    }

    if (_isTextBasedColumn(widget.column.columnType)) {
      return _buildTextEditor(context);
    }

    if (widget.column.columnType == WebbUIColumnType.boolean) {
      return _buildBooleanEditor(context);
    }

    if (widget.column.columnType == WebbUIColumnType.selection) {
      return _buildSelectionEditor(context);
    }

    return _buildTextEditor(context); // Fallback
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

  Widget _buildTextEditor(BuildContext context) {
    return WebbUIEditableTextField(
      initialValue: widget.data?.toString() ?? '',
      onSave: widget.onEditComplete,
      onCancel: widget.onEditCancel,
      showActions: false,
      autoFocus: true,
      clearOnCancel: false,
    );
  }

  Widget _buildBooleanEditor(BuildContext context) {
    final currentValue = widget.data as bool? ?? false;

    return WebbUICheckbox(
      value: currentValue,
      onChanged: (value) {
        widget.onEditComplete(value);
        widget.onEditCancel(); // Auto-close after change
      },
    );
  }

  Widget _buildSelectionEditor(BuildContext context) {    
    return WebbUIDropdown<dynamic>(
      value: widget.data,
      items: widget.column.selectionOptions
              ?.map((opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt.toString()),
                  ))
              .toList() ??
          [],
      onChanged: (newValue) {
        widget.onEditComplete(newValue);
        widget.onEditCancel(); // Auto-close after selection
      },
    );
  }
}
