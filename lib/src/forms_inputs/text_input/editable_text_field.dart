import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webb_ui/src/buttons_controls/button.dart';
import 'package:webb_ui/src/theme.dart';
import 'text_field.dart';
import 'validation_states.dart';

/// A specialized text field for inline editing scenarios with explicit
/// save and cancel actions.
///
/// This component is ideal for:
/// - Table cell editing
/// - Inline form editing
/// - Settings that require confirmation
/// - Any scenario where changes should be explicitly saved or canceled
/// rather than auto-saved.

class WebbUIEditableTextField extends StatefulWidget {
  final bool isLoading;
  final String initialValue;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;
  final String? label;
  final String? hintText;
  final bool autoFocus;
  final bool showActions;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final bool clearOnCancel;

  const WebbUIEditableTextField({
    super.key,
    required this.initialValue,
    required this.onSave,
    required this.onCancel,
    this.label,
    this.hintText,
    this.autoFocus = true,
    this.showActions = true,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.clearOnCancel = false,
    this.isLoading = false,
  });

  @override
  State<WebbUIEditableTextField> createState() =>
      _WebbUIEditableTextFieldState();
}

class _WebbUIEditableTextFieldState extends State<WebbUIEditableTextField> {
  late TextEditingController _controller;
  late String _originalValue;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _originalValue = widget.initialValue;
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(WebbUIEditableTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _controller.text = widget.initialValue;
      _originalValue = widget.initialValue;
      _hasChanges = false;
    }
  }

  void _handleTextChanged() {
    final newHasChanges = _controller.text != _originalValue;
    if (newHasChanges != _hasChanges) {
      setState(() {
        _hasChanges = newHasChanges;
      });
    }
  }

  void _handleSave() {
    if (_hasChanges) {
      // Add validation before saving
      if (widget.validationState == WebbUIValidationState.error) {
        // Don't save if there's a validation error
        return;
      }
      widget.onSave(_controller.text);
    } else {
      widget.onCancel();
    }
  }

  void _handleCancel() {
    if (_hasChanges) {
      if (widget.clearOnCancel) {
        _controller.clear();
      } else {
        _controller.text = _originalValue;
      }
    }
    widget.onCancel();
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isModifierPressed = HardwareKeyboard.instance.isControlPressed ||
          HardwareKeyboard.instance.isMetaPressed;

      if (event.logicalKey == LogicalKeyboardKey.escape) {
        _handleCancel();
      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
          isModifierPressed) {
        _handleSave();
      } else if (event.logicalKey == LogicalKeyboardKey.enter &&
          widget.showActions) {
        // Regular enter only saves if actions are visible (form-like behavior)
        _handleSave();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: _handleKeyPress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The text field
          WebbUITextField(
            controller: _controller,
            focusNode: FocusNode(), // Dedicated focus node for this field
            label: widget.label,
            hintText: widget.hintText,
            autofocus: widget.autoFocus,
            validationState: widget.validationState,
            validationMessage: widget.validationMessage,
            onSubmitted: (_) => _handleSave(),
            textInputAction: TextInputAction.done,
          ),

          // Action buttons (conditionally shown)
          if (widget.showActions) ...[
            SizedBox(height: webbTheme.spacingGrid.spacing(1)),
            _buildActionButtons(webbTheme),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext webbTheme) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Save button - only enabled when there are changes
          WebbUIButton(
            label: 'Save',
            onPressed: _hasChanges && !widget.isLoading ? _handleSave : null,
            isLoading: widget.isLoading,
            variant: WebbUIButtonVariant.primary,
          ),

          SizedBox(width: webbTheme.spacingGrid.spacing(1)),

          // Cancel button
          WebbUIButton(
            label: 'Cancel',
            onPressed: _handleCancel,
            variant: WebbUIButtonVariant.tertiary,
          ),

          // Optional: Change indicator
          if (_hasChanges) ...[
            SizedBox(width: webbTheme.spacingGrid.spacing(1)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: webbTheme.spacingGrid.spacing(1),
                vertical: webbTheme.spacingGrid.spacing(0.5),
              ),
              decoration: BoxDecoration(
                color: webbTheme.colorPalette.info.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
              ),
              child: Text(
                'Unsaved changes',
                style: webbTheme.typography.labelMedium.copyWith(
                  color: webbTheme.colorPalette.info,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
