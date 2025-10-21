import 'package:flutter/foundation.dart';
import 'table_models.dart';

/// Signature for async data loading callbacks
typedef DataLoader<T> = Future<List<WebbUIRow<T>>> Function(
    int page, int pageSize);

/// Manages all mutable state for the [WebbUITable], including data handling,
/// sorting, filtering, and user interaction states (selection, editing).
class TableStateManager<T> with ChangeNotifier {
  // --- Data and Loading State ---
  final List<WebbUIColumn<T>> _columns;
  List<WebbUIRow<T>> _originalRows;
  bool _isLoading = false;
  bool _isInitialLoad = true;
  final bool _isInfiniteScroll;
  final bool _isRowSelectionEnabled;
  final int _itemsPerPage;
  final DataLoader<T>? _dataLoader;

  // --- Displayed Data State (The result of sorting/filtering/pagination) ---
  List<WebbUIRow<T>> _displayedRows = [];

  // --- Sorting State ---
  String? sortColumnId;
  bool isAscending = true;

  // --- Pagination State ---
  int _currentPage = 0;
  final bool isPaginated;

  // --- Interaction State ---
  final Set<WebbUIRow<T>> _selectedRows = {};
  EditingCell? _editingCell;

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
  int get totalPages => _dataLoader != null
      ? -1 // Unknown total pages for async loading
      : (_originalRows.length / _itemsPerPage).ceil();

  TableStateManager({
    required List<WebbUIColumn<T>> columns,
    required List<WebbUIRow<T>> initialRows,
    int itemsPerPage = 10,
    this.isPaginated = false,
    bool isRowSelectionEnabled = false,
    bool isInfiniteScroll = false,
    DataLoader<T>? dataLoader, // Optional async data loader
  })  : _columns = columns,
        _originalRows = initialRows,
        _itemsPerPage = itemsPerPage,
        _isRowSelectionEnabled = isRowSelectionEnabled,
        _isInfiniteScroll = isInfiniteScroll,
        _dataLoader = dataLoader {
    _processData();
    _isInitialLoad = false;
  }

  void _processData() {
    List<WebbUIRow<T>> filteredAndSorted = List.from(_originalRows);

    // Sorting
    if (sortColumnId != null) {
      try {
        final sortColumn = _columns.firstWhere((col) => col.id == sortColumnId);
        if (sortColumn.isSortable) {
          filteredAndSorted.sort((a, b) {
            final aValue = a.data[sortColumnId];
            final bValue = b.data[sortColumnId];
            int comparison = 0;

            if (aValue == null && bValue == null) {
              comparison = 0;
            } else if (aValue == null) {
              comparison = -1;
            } else if (bValue == null) {
              comparison = 1;
            } else if (aValue is Comparable && bValue is Comparable) {
              comparison = aValue.compareTo(bValue);
            } else {
              comparison = aValue.toString().compareTo(bValue.toString());
            }

            return isAscending ? comparison : -comparison;
          });
        }
      } catch (e) {
        // Column not found, ignore sorting
        if (kDebugMode) {
          print('Sort column not found: $sortColumnId');
        }
      }
    }

    // Pagination/Infinite Scroll
    if (isPaginated) {
      final startIndex = _currentPage * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;
      if (startIndex < filteredAndSorted.length) {
        _displayedRows = filteredAndSorted.sublist(
          startIndex,
          endIndex.clamp(0, filteredAndSorted.length),
        );
      } else {
        _displayedRows = [];
      }
    } else if (_isInfiniteScroll) {
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
    _currentPage = 0;
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

  void updateCellValue(String rowId, String columnId, dynamic newValue) {
    try {
      final rowIndex = _originalRows.indexWhere((r) => r.id == rowId);
      if (rowIndex != -1) {
        _originalRows[rowIndex].data[columnId] = newValue;
        _processData();
        clearEditingCell();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating cell value: $e');
      }
    }
  }

  // --- Async/Lazy Loading Methods ---

  /// Loads more data for infinite scroll or pagination.
  /// Uses the provided data loader if available, otherwise falls back to mock data.
  Future<void> loadMoreData() async {
    if (_isLoading || !_isInfiniteScroll) return;

    _isLoading = true;
    notifyListeners();

    try {
      if (_dataLoader != null) {
        // Use the provided async data loader
        final newRows = await _dataLoader(_currentPage + 1, _itemsPerPage);

        if (newRows.isNotEmpty) {
          _originalRows.addAll(newRows);
          _currentPage++;
          _processData();
        }
        // If empty list returned, we've reached the end of data
      } else {
        // Fallback to mock data (original behavior)
        await Future.delayed(const Duration(milliseconds: 1000));
        
        // Generate mock data for demonstration
        final mockRows = _generateMockData(_currentPage + 1);
        _originalRows.addAll(mockRows);
        _currentPage++;
        _processData();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading more data: $e');
      }
      // You could add error state handling here
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generates mock data for demonstration purposes
  List<WebbUIRow<T>> _generateMockData(int page) {
    // This is a simple mock - in real usage, you'd remove this
    // and always use the dataLoader
    final startId = page * _itemsPerPage;
    return List.generate(_itemsPerPage, (index) {
      final id = startId + index;
      return WebbUIRow<T>(
        id: 'mock_$id',
        originalData: null as T, // Cast for demonstration
        data: {
          for (final column in _columns) column.id: 'Page $page, Item $index',
        },
      );
    });
  }

  /// Refreshes all data using the data loader (if available)
  Future<void> refreshData() async {
    if (_isLoading || _dataLoader == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newRows = await _dataLoader(0, _itemsPerPage);
      _originalRows = newRows;
      _currentPage = 0;
      _selectedRows.clear();
      _editingCell = null;
      _processData();
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // New method to update entire dataset
  void updateData(List<WebbUIRow<T>> newRows) {
    _originalRows = newRows;
    _currentPage = 0;
    _selectedRows.clear();
    _editingCell = null;
    _processData();
  }

  // New method to clear selection
  void clearSelection() {
    _selectedRows.clear();
    notifyListeners();
  }

  // New method to select all visible rows
  void selectAllVisible() {
    if (!_isRowSelectionEnabled) return;
    _selectedRows.addAll(_displayedRows);
    notifyListeners();
  }
}
