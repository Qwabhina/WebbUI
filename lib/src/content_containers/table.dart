import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUITable extends StatefulWidget {
  final Widget? header; // Custom header widget (e.g., title, filters)
  final List<String> headers;
  final List<List<Widget>> rows;
  final Widget? footer; // Custom footer widget (e.g., pagination, summary)
  final bool sortable;
  final List<bool>? sortDirections; // True for ascending, false for descending
  final void Function(int columnIndex, bool ascending)? onSort;
  final Map<String, double>? columnWidths; // Custom widths per header
  final Color? headerColor;
  final Color? rowColor;
  final MainAxisAlignment headerAlignment;
  final bool paginated;
  final int itemsPerPage;
  final ValueChanged<int>? onPageChanged;

  const WebbUITable({
    super.key,
    this.header,
    required this.headers,
    required this.rows,
    this.footer,
    this.sortable = false,
    this.sortDirections,
    this.onSort,
    this.columnWidths,
    this.headerColor,
    this.rowColor,
    this.headerAlignment = MainAxisAlignment.start,
    this.paginated = false,
    this.itemsPerPage = 10,
    this.onPageChanged,
  });

  @override
  State<WebbUITable> createState() => _WebbUITableState();
}

class _WebbUITableState extends State<WebbUITable> {
  int _currentPage = 0;

  void _handlePageChange(int delta) {
    setState(() {
      _currentPage += delta;
      if (widget.onPageChanged != null) widget.onPageChanged!(_currentPage);
    });
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final int totalPages = widget.paginated
        ? (widget.rows.length / widget.itemsPerPage).ceil()
        : 1;
    final int startIndex =
        widget.paginated ? _currentPage * widget.itemsPerPage : 0;
    final int endIndex = widget.paginated
        ? (_currentPage + 1) * widget.itemsPerPage
        : widget.rows.length;
    final List<List<Widget>> displayedRows = widget.rows.sublist(
      startIndex,
      endIndex > widget.rows.length ? widget.rows.length : endIndex,
    );

    if (isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null)
            Padding(
              padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
              child: widget.header!,
            ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(), // Delegate to parent
            itemCount: displayedRows.length,
            itemBuilder: (context, index) {
              return Theme(
                data: Theme.of(context).copyWith(
                  cardTheme: Theme.of(context).cardTheme.copyWith(
                        elevation: webbTheme.elevation.getShadows(1).isNotEmpty
                            ? 1
                            : 0,
                      ),
                ),
                child: ExpansionTile(
                  title: Text(
                    widget.headers[0], // First column as summary
                    style: webbTheme.typography.labelLarge,
                  ),
                  subtitle: Text(
                    displayedRows[index][0].toString(),
                    style: webbTheme.typography.bodyMedium,
                  ),
                  children: List.generate(widget.headers.length, (i) {
                    return ListTile(
                      title: Text(widget.headers[i],
                          style: webbTheme.typography.labelLarge),
                      subtitle: Text(displayedRows[index][i].toString(),
                          style: webbTheme.typography.bodyMedium),
                    );
                  }),
                ),
              );
            },
          ),
          if (widget.footer != null)
            Padding(
              padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
              child: widget.footer!,
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.header != null)
          Padding(
            padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            child: widget.header!,
          ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
              widget.headerColor ?? webbTheme.colorPalette.neutralLight,
            ),
            dataRowColor: WidgetStateProperty.all(
              widget.rowColor ?? Colors.white,
            ),
            headingTextStyle: webbTheme.typography.labelLarge.copyWith(
              color: webbTheme.colorPalette.neutralDark,
            ),
            dataTextStyle: webbTheme.typography.bodyMedium.copyWith(
              color: webbTheme.colorPalette.neutralDark,
            ),
            columns: widget.headers.asMap().entries.map((entry) {
              final int index = entry.key;
              final String header = entry.value;
              // final width = widget.columnWidths?[header] ?? 150.0; // Default width
              return DataColumn(
                label: Row(
                  mainAxisAlignment: widget.headerAlignment,
                  children: [
                    Text(header),
                    if (widget.sortable &&
                        widget.sortDirections != null &&
                        index < widget.sortDirections!.length)
                      Icon(
                        widget.sortDirections![index]
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
                onSort: widget.sortable
                    ? (columnIndex, ascending) =>
                        widget.onSort?.call(columnIndex, ascending)
                    : null,
              );
            }).toList(),
            columnSpacing: webbTheme.spacingGrid.gutter,
            rows: displayedRows
                .map((row) => DataRow(
                      cells: row.map((cell) => DataCell(cell)).toList(),
                    ))
                .toList(),
          ),
        ),
        if (widget.footer != null || (widget.paginated && totalPages > 1))
          Padding(
            padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            child: widget.footer ??
                (widget.paginated
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentPage > 0
                                ? () => _handlePageChange(-1)
                                : null,
                          ),
                          Text(
                            '${_currentPage + 1} of $totalPages',
                            style: webbTheme.typography.bodyMedium,
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentPage < totalPages - 1
                                ? () => _handlePageChange(1)
                                : null,
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
          ),
      ],
    );
  }
}
