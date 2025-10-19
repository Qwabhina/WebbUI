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
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    // Dispose all text controllers
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
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

  TextEditingController _getTextController(String key, String initialValue) {
    if (!_textControllers.containsKey(key)) {
      _textControllers[key] = TextEditingController(text: initialValue);
    }
    return _textControllers[key]!;
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
                      getTextController: (initialValue) => _getTextController(
                          '${row.id}-${col.id}', initialValue),
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

/// A widget that renders a single cell and handles editing.
class _TableCellWidget<T> extends StatefulWidget {
  final WebbUIRow<T> row;
  final WebbUIColumn<T> column;
  final dynamic data;
  final Function(dynamic) onEditComplete;
  final TextEditingController Function(String) getTextController;

  const _TableCellWidget({
    super.key,
    required this.row,
    required this.column,
    required this.data,
    required this.onEditComplete,
    required this.getTextController,
  });

  @override
  State<_TableCellWidget<T>> createState() => _TableCellWidgetState<T>();
}

class _TableCellWidgetState<T> extends State<_TableCellWidget<T>> {
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = false;
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
    });
  }

  void _saveEditing(dynamic newValue) {
    setState(() {
      _isEditing = false;
    });
    widget.onEditComplete(newValue);
  }

  void _cancelEditing() {
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final stateManager =
        Provider.of<TableStateManager<T>>(context, listen: false);
    final isEditing = stateManager.editingCell?.rowId == widget.row.id &&
        stateManager.editingCell?.columnId == widget.column.id;

    if (!_isEditing && isEditing) {
      _startEditing();
    }

    Widget content;
    if (_isEditing) {
      content = _buildCellEditor(context, widget.data);
    } else {
      if (widget.column.cellRenderer != null) {
        content = widget.column.cellRenderer!(context, widget.data, widget.row);
      } else {
        content = Text(
          widget.data?.toString() ?? '',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        );
      }
    }

    return Expanded(
      flex: widget.column.widthFlex,
      child: GestureDetector(
        onTap: () =>
            stateManager.setEditingCell(widget.row.id, widget.column.id),
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

  /// Builds the appropriate editor based on the column type.
  Widget _buildCellEditor(BuildContext context, dynamic currentValue) {
    final webbTheme = context;

    // Use custom editor if provided
    if (widget.column.editCellRenderer != null) {
      return widget.column.editCellRenderer!(
        context,
        currentValue,
        _saveEditing,
        widget.row,
      );
    }

    // Default editors based on column type
    switch (widget.column.columnType) {
      case WebbUIColumnType.text:
        final controller =
            widget.getTextController(currentValue?.toString() ?? '');
        return WebbUITextField(
          controller: controller,
          onSubmitted: (value) => _saveEditing(value),
          onCancel: _cancelEditing,
        );

      case WebbUIColumnType.number:
      case WebbUIColumnType.currency:
      case WebbUIColumnType.percentage:
        final controller =
            widget.getTextController(currentValue?.toString() ?? '');
        return WebbUITextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onSubmitted: (value) {
            final numValue = num.tryParse(value) ?? 0;
            _saveEditing(numValue);
          },
          onCancel: _cancelEditing,
        );

      case WebbUIColumnType.boolean:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            WebbUICheckbox(
              value: currentValue as bool? ?? false,
              onChanged: (value) => _saveEditing(value),
            ),
            SizedBox(width: webbTheme.spacingGrid.spacing(1)),
            WebbUIButton(
              label: 'Save',
              onPressed: () => _saveEditing(currentValue),
              variant: WebbUIButtonVariant.primary,
            ),
            SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),
            WebbUIButton(
              label: 'Cancel',
              onPressed: _cancelEditing,
              variant: WebbUIButtonVariant.tertiary,
            ),
          ],
        );

      case WebbUIColumnType.selection:
        return WebbUIDropdown<dynamic>(
          value: currentValue,
          items: widget.column.selectionOptions
                  ?.map((opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(opt.toString()),
                      ))
                  .toList() ??
              [],
          onChanged: (newValue) => _saveEditing(newValue),
        );

      case WebbUIColumnType.date:
      case WebbUIColumnType.time:
      case WebbUIColumnType.dateTime:
        // Simplified date editor
        final controller =
            widget.getTextController(currentValue?.toString() ?? '');
        return WebbUITextField(
          controller: controller,
          onSubmitted: (value) => _saveEditing(value),
          onCancel: _cancelEditing,
        );

      default:
        final controller =
            widget.getTextController(currentValue?.toString() ?? '');
        return WebbUITextField(
          controller: controller,
          onSubmitted: (value) => _saveEditing(value),
          onCancel: _cancelEditing,
        );
    }
  }
}
