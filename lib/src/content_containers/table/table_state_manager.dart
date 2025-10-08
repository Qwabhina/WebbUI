import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'table_models.dart';

/// Manages all mutable state for the [WebbUITable], including data handling,
/// sorting, filtering, and user interaction states (selection, editing).
class TableStateManager<T> with ChangeNotifier {
  // --- Data and Loading State ---
  final List<WebbUIColumn<T>> _columns;
  List<WebbUIRow<T>> _originalRows; // The full, unfiltered, unsorted dataset
  bool _isLoading = false;
  bool _isInitialLoad = true;
  bool _isInfiniteScroll = false;

  // --- Displayed Data State (The result of sorting/filtering/pagination) ---
  List<WebbUIRow<T>> _displayedRows = [];

  // --- Sorting State ---
  String? sortColumnId;
  bool isAscending = true; // True for ascending, false for descending

  // --- Pagination State ---
  int _currentPage = 0;
  final int _itemsPerPage;
  final bool isPaginated;

  // --- Interaction State ---
  final Set<WebbUIRow<T>> _selectedRows = {};
  EditingCell? _editingCell;
  final bool _isRowSelectionEnabled;

  // --- Getters ---

  List<WebbUIColumn<T>> get columns => _columns;
  List<WebbUIRow<T>> get rows => _displayedRows;
  bool get isLoading => _isLoading;
  bool get isInitialLoad => _isInitialLoad;
  Set<WebbUIRow<T>> get selectedRows => _selectedRows;
  EditingCell? get editingCell => _editingCell;
  bool get isRowSelectionEnabled => _isRowSelectionEnabled;
  bool get isInfiniteScroll => _isInfiniteScroll;

  int get currentPage => _currentPage;
  int get itemsPerPage => _itemsPerPage;
  int get totalPages => (_originalRows.length / _itemsPerPage).ceil();

  TableStateManager({
    required List<WebbUIColumn<T>> columns,
    required List<WebbUIRow<T>> initialRows,
    int itemsPerPage = 10,
    bool isPaginated = false,
    bool isRowSelectionEnabled = false,
    bool isInfiniteScroll = false,
  })  : _columns = columns,
        _originalRows = initialRows,
        _itemsPerPage = itemsPerPage,
        isPaginated = isPaginated,
        _isRowSelectionEnabled = isRowSelectionEnabled,
        _isInfiniteScroll = isInfiniteScroll {
    // Initial data processing
    _processData();
    _isInitialLoad = false;
  }

  // --- Data Processing ---

  /// Applies sorting, filtering, and pagination to determine [_displayedRows].
  void _processData() {
    List<WebbUIRow<T>> filteredAndSorted = List.from(_originalRows);

    // 1. Filtering (Placeholder: Real filtering logic would go here)
    // For now, we use all rows.

    // 2. Sorting
    if (sortColumnId != null) {
      final sortColumn = _columns.firstWhere((col) => col.id == sortColumnId);
      if (sortColumn.isSortable) {
        filteredAndSorted.sort((a, b) {
          final aValue = a.data[sortColumnId];
          final bValue = b.data[sortColumnId];
          int comparison = 0;

          if (aValue is Comparable && bValue is Comparable) {
            comparison = aValue.compareTo(bValue);
          } else if (aValue != null && bValue == null) {
            comparison = 1;
          } else if (aValue == null && bValue != null) {
            comparison = -1;
          }

          return isAscending ? comparison : -comparison;
        });
      }
    }

    // 3. Pagination/Infinite Scroll
    if (isPaginated) {
      final startIndex = _currentPage * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      _displayedRows = filteredAndSorted.sublist(
        startIndex,
        endIndex.clamp(0, filteredAndSorted.length),
      );
    } else if (_isInfiniteScroll) {
      // In infinite scroll mode, _displayedRows is built up over time.
      // We would append new data, but for this client-side demo, we use the
      // full list as we don't have a server to call.
      _displayedRows = filteredAndSorted;
    } else {
      _displayedRows = filteredAndSorted;
    }

    notifyListeners();
  }

  // --- Sorting Methods ---

  /// Handles a column header click to toggle or change the sort direction/column.
  void setSortColumn(String columnId) {
    if (sortColumnId == columnId) {
      // Toggle direction if same column
      isAscending = !isAscending;
    } else {
      // Change column and set to ascending by default
      sortColumnId = columnId;
      isAscending = true;
    }
    _currentPage = 0; // Reset pagination on sort
    _processData();
  }

  // --- Pagination Methods ---

  /// Changes the current page index.
  void setPage(int newPage) {
    if (newPage >= 0 && newPage < totalPages) {
      _currentPage = newPage;
      _processData();
    }
  }

  // --- Interaction Methods (Selection/Editing) ---

  /// Toggles the selection state of a specific row.
  void toggleRowSelection(WebbUIRow<T> row) {
    if (!_isRowSelectionEnabled) return;

    if (_selectedRows.contains(row)) {
      _selectedRows.remove(row);
    } else {
      _selectedRows.add(row);
    }
    notifyListeners();
  }

  /// Sets the currently active cell for editing.
  void setEditingCell(String rowId, String columnId) {
    _editingCell = EditingCell(rowId: rowId, columnId: columnId);
    notifyListeners();
  }

  /// Clears the editing state.
  void clearEditingCell() {
    _editingCell = null;
    notifyListeners();
  }

  /// Updates the value of a specific cell and clears the editing state.
  void updateCellValue(String rowId, String columnId, dynamic newValue) {
    // Find the row to update in the original data source
    final row = _originalRows.firstWhere((r) => r.id == rowId);
    row.data[columnId] =
        newValue; // Note: This mutates the map inside the row object

    // Recalculate everything (sorting, filtering, etc.)
    _processData();
    clearEditingCell(); // Exit edit mode
  }

  // --- Async/Lazy Loading Methods ---

  /// Placeholder for loading more data in infinite scroll or lazy pagination.
  /// In a real application, this would involve an asynchronous API call.
  void loadMoreData() async {
    if (_isLoading || !_isInfiniteScroll) return;

    _isLoading = true;
    notifyListeners();

    // Simulating network delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Placeholder: In a real implementation, you would fetch the next batch
    // of data from the server and append it to _originalRows.

    // Example: If we were fetching a batch of 10 new rows:
    // final newRows = await _fetchNewData(page: _currentPage + 1);
    // _originalRows.addAll(newRows);

    _isLoading = false;
    _currentPage++; // Even in infinite scroll, tracking page helps
    _processData();
  }
}
