import 'package:flutter/material.dart';

/// Defines the data type and behavior of a column in the WebbUITable.
enum WebbUIColumnType {
  text,
  number,
  boolean,
  selection,
  date,
  time,
  dateTime,
  currency,
  percentage,
}

// --- Function Typedefs for Custom Renderers ---

/// A builder for a custom widget to display in a cell.
/// `data` is the value for the specific cell.
/// `row` is the entire row object, providing context.
typedef WebbUICellRenderer<T> = Widget Function(
    BuildContext context, dynamic data, WebbUIRow<T> row);

/// A builder for a custom widget to display in a column header.
typedef WebbUITitleRenderer<T> = Widget Function(
    BuildContext context, WebbUIColumn<T> column);

/// A builder for a custom widget to use when a cell is in edit mode.
typedef WebbUIEditCellRenderer<T> = Widget Function(
    BuildContext context,
    dynamic initialValue,
    Function(dynamic newValue) onValueChanged,
    WebbUIRow<T> row);

/// Defines the properties and behavior of a single column in the WebbUITable.
class WebbUIColumn<T> {
  /// A unique identifier for the column.
  final String id;

  /// The text displayed in the column header.
  final String title;

  /// The data type of the column, which determines the default editor.
  final WebbUIColumnType columnType;

  /// A flex factor that determines the relative width of the column.
  final int widthFlex;

  /// How the content within the cells of this column should be aligned.
  final Alignment alignment;

  /// Whether the data in this column can be sorted.
  final bool isSortable;

  /// Whether the data in this column can be filtered.
  final bool isFilterable;

  /// A list of predefined options for `WebbUIColumnType.selection`.
  final List<String>? selectionOptions;

  /// A custom widget builder for rendering the cells in this column.
  /// If null, a default Text widget will be used.
  final WebbUICellRenderer<T>? cellRenderer;

  /// A custom widget builder for rendering the header of this column.
  final WebbUITitleRenderer<T>? titleRenderer;

  /// A custom widget builder for rendering the editor when a cell is active.
  final WebbUIEditCellRenderer<T>? editCellRenderer;

  WebbUIColumn({
    required this.id,
    required this.title,
    this.columnType = WebbUIColumnType.text,
    this.widthFlex = 1,
    this.alignment = Alignment.centerLeft,
    this.isSortable = true,
    this.isFilterable = true,
    this.selectionOptions,
    this.cellRenderer,
    this.titleRenderer,
    this.editCellRenderer,
  });
}

/// Represents a single row of data in the WebbUITable.
class WebbUIRow<T> {
  /// A unique identifier for the row.
  final String id;

  /// The raw data object associated with this row.
  final T originalData;

  /// A map where the key is the `column.id` and the value is the cell data.
  final Map<String, dynamic> data;

  /// An optional color to apply to the entire row background.
  final Color? color;

  const WebbUIRow({
    required this.id,
    required this.originalData,
    required this.data,
    this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebbUIRow && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// A simple model to represent a cell being edited.
class EditingCell {
  final String rowId;
  final String columnId;

  const EditingCell({required this.rowId, required this.columnId});
}
