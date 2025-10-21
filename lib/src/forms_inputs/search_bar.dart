import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A styled search bar component that optionally includes space for filter widgets.
/// It is now a StatefulWidget to manage the visibility of the clear button.
class WebbUISearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final List<Widget>? filters;

  const WebbUISearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.filters,
  });

  @override
  State<WebbUISearchBar> createState() => _WebbUISearchBarState();
}

class _WebbUISearchBarState extends State<WebbUISearchBar> {
  // Use a default controller if none is provided by the parent
  late TextEditingController _internalController;

  // This value determines if the clear icon should be visible
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Initialize controller: use widget.controller if provided, otherwise create a new one.
    _internalController = widget.controller ?? TextEditingController();

    // Set initial state for the clear button visibility
    _showClearButton = _internalController.text.isNotEmpty;

    // Add a listener to rebuild the widget when the text changes,
    // which controls the visibility of the clear button.
    _internalController.addListener(_onTextChange);
  }

  @override
  void dispose() {
    // Remove the listener to prevent memory leaks.
    _internalController.removeListener(_onTextChange);

    // Only dispose the controller if it was created internally
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _onTextChange() {
    // Check if the clear button visibility state needs updating
    final isNotEmpty = _internalController.text.isNotEmpty;
    if (_showClearButton != isNotEmpty) {
      setState(() {
        _showClearButton = isNotEmpty;
      });
    }

    // Also call the external onChanged callback if provided
    if (widget.onChanged != null) {
      widget.onChanged!(_internalController.text);
    }
  }

  void _clearText() {
    _internalController.clear();
    // Manually trigger the external onChanged with an empty string after clearing
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
    // _onTextChange will handle the setState, but calling it directly is redundant here.
    // The state will update automatically since clear() fires a change event.
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: webbTheme.spacingGrid.spacing(1),
        horizontal: webbTheme.spacingGrid.spacing(2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _internalController,
              // onChanged is handled internally in _onTextChange now
              onSubmitted: widget.onSubmitted,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: webbTheme.typography.bodyMedium.copyWith(
                    color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),

                // Styling for the default border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color:
                          webbTheme.colorPalette.neutralDark.withOpacity(0.3)),
                ),

                // Styling for the focused border
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: webbTheme.interactionStates.focusedBorder,
                      width: 2.0),
                ),

                // Styling for the prefix icon
                prefixIcon: Icon(
                  Icons.search,
                  color: webbTheme.colorPalette.neutralDark,
                  size: 20,
                ),

                // Now the suffixIcon (Clear button) is rendered conditionally and
                // managed internally because the widget is Stateful.
                suffixIcon: _showClearButton
                    ? IconButton(
                        icon: Icon(Icons.clear,
                            color: webbTheme.colorPalette.neutralDark),
                        onPressed: _clearText,
                      )
                    : null,

                // Ensure the background is light for visibility
                filled: true,
                fillColor: webbTheme.colorPalette.neutralLight,
              ),
            ),
          ),

          // Add spacing between the search bar and the filters, if present
          if (widget.filters != null && widget.filters!.isNotEmpty)
            SizedBox(width: webbTheme.spacingGrid.spacing(1)),

          // Spread the filters list if it is not null
          if (widget.filters != null && widget.filters!.isNotEmpty)
            ...widget.filters!,
        ],
      ),
    );
  }
}
