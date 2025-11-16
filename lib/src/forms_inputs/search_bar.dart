import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'text_input/input_decoration.dart';

/// A styled search bar component that optionally includes space for filter widgets.
class WebbUISearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final List<Widget>? filters;
  final String hintText;
  final bool autofocus;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  const WebbUISearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.filters,
    this.hintText = 'Search...',
    this.autofocus = false,
    this.enabled = true,
    this.padding,
  });

  @override
  State<WebbUISearchBar> createState() => _WebbUISearchBarState();
}

class _WebbUISearchBarState extends State<WebbUISearchBar> {
  late TextEditingController _internalController;
  late FocusNode _internalFocusNode;
  bool _showClearButton = false;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    
    _showClearButton = _internalController.text.isNotEmpty;
    
    _internalController.addListener(_onTextChange);
    _internalFocusNode.addListener(_onFocusChange);

    // Auto-focus if requested
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _internalFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _internalController.removeListener(_onTextChange);
    _internalFocusNode.removeListener(_onFocusChange);
    
    if (widget.controller == null) {
      _internalController.dispose();
    }
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChange() {
    final isNotEmpty = _internalController.text.isNotEmpty;
    if (_showClearButton != isNotEmpty) {
      setState(() {
        _showClearButton = isNotEmpty;
      });
    }

    widget.onChanged?.call(_internalController.text);
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _internalFocusNode.hasFocus;
    });
  }

  void _clearText() {
    _internalController.clear();
    widget.onChanged?.call('');
    // Keep focus after clearing
    _internalFocusNode.requestFocus();
  }

  Widget _buildSuffixIcon(BuildContext context) {
    if (!_showClearButton) return const SizedBox.shrink();

    final webbTheme = context;
    return IconButton(
      icon: Icon(
        // Icons.clear,
        FluentIcons.dismiss_20_regular,
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
        size: webbTheme.iconTheme.smallSize,
      ),
      onPressed: _clearText,
      splashRadius: webbTheme.iconTheme.smallSize / 2,
      tooltip: 'Clear search',
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final suffixIcon = _buildSuffixIcon(context);

    final decoration = WebbUIInputDecoration.create(
      context: context,
      hintText: widget.hintText,
      prefixIcon: Icon(
        // Icons.search,
        FluentIcons.search_20_regular,
        color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
        size: webbTheme.iconTheme.mediumSize,
      ),
      suffixIcon: suffixIcon,
      maxLines: 1,
      isFocused: _hasFocus,
      isDisabled: !widget.enabled,
    );

    return Semantics(
      textField: true,
      label: 'Search',
      hint: widget.hintText,
      value: _internalController.text,
      focused: _hasFocus,
      enabled: widget.enabled,
      child: Padding(
        padding: widget.padding ??
            EdgeInsets.symmetric(
              vertical: webbTheme.spacingGrid.spacing(1),
              horizontal: webbTheme.spacingGrid.spacing(2),
            ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _internalController,
                focusNode: _internalFocusNode,
                onChanged:
                    widget.onChanged, // Still call for immediate response
                onSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                enabled: widget.enabled,
                autofocus: widget.autofocus,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                decoration: decoration.copyWith(
                  // Override fill color for search-specific styling
                  filled: true,
                  fillColor: widget.enabled
                      ? webbTheme.colorPalette.neutralLight
                      : webbTheme.interactionStates.disabledColor
                          .withOpacity(0.1),
                ),
                style: webbTheme.typography.bodyMedium.copyWith(
                  color: widget.enabled
                      ? webbTheme.colorPalette.neutralDark
                      : webbTheme.interactionStates.disabledColor,
                ),
              ),
            ),

            // Filters section
            if (widget.filters != null && widget.filters!.isNotEmpty) ...[
              SizedBox(width: webbTheme.spacingGrid.spacing(1)),
              ...widget.filters!,
            ],
          ],
        ),
      ),
    );
  }
}
