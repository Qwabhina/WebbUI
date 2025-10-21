import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'package:webb_ui/src/forms_inputs/text_input/text_input.dart';
import 'package:webb_ui/src/theme.dart';

/// A component for increasing or decreasing a number value within a defined range.
/// Supports direct text input, keyboard navigation, and custom step sizes.
class WebbUINumberStepper extends StatefulWidget {
  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;
  final bool enabled;
  final bool showInputField;
  final String? label;
  final String? hintText;

  const WebbUINumberStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.enabled = true,
    this.showInputField = false,
    this.label,
    this.hintText,
  });

  @override
  State<WebbUINumberStepper> createState() => _WebbUINumberStepperState();
}

class _WebbUINumberStepperState extends State<WebbUINumberStepper> {
  late int _value;
  bool _isEditing = false;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _value = widget.value.clamp(widget.min, widget.max);
    _textController.text = _value.toString();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant WebbUINumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Only update value if it changed externally and we're not currently editing
    if (!_isEditing &&
        (oldWidget.value != widget.value ||
            oldWidget.min != widget.min || 
            oldWidget.max != widget.max)) {
      _value = widget.value.clamp(widget.min, widget.max);
      _textController.text = _value.toString();
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _saveTextInput();
    }
  }

  void _increment() {
    if (!widget.enabled) return;

    final newValue = (_value + widget.step).clamp(widget.min, widget.max);
    if (newValue != _value) {
      _updateValue(newValue);
    }
  }

  void _decrement() {
    if (!widget.enabled) return;

    final newValue = (_value - widget.step).clamp(widget.min, widget.max);
    if (newValue != _value) {
      _updateValue(newValue);
    }
  }

  void _updateValue(int newValue) {
    setState(() {
      _value = newValue;
      _textController.text = newValue.toString();
    });
    widget.onChanged?.call(newValue);
  }

  void _startEditing() {
    if (!widget.enabled) return;

    setState(() {
      _isEditing = true;
    });
    // Select all text for easy replacement
    _textController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _textController.text.length,
    );
  }

  void _saveTextInput() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      // If empty, revert to current value
      _textController.text = _value.toString();
      setState(() => _isEditing = false);
      return;
    }

    final parsedValue = int.tryParse(text);
    if (parsedValue != null) {
      final clampedValue = parsedValue.clamp(widget.min, widget.max);
      _updateValue(clampedValue);
    } else {
      // Invalid input, revert to current value
      _textController.text = _value.toString();
    }

    setState(() => _isEditing = false);
  }

  void _handleKeyPress(KeyEvent event) {
    if (!widget.enabled) return;

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _increment();
          break;
        case LogicalKeyboardKey.arrowDown:
          _decrement();
          break;
        case LogicalKeyboardKey.enter:
          if (_isEditing) {
            _saveTextInput();
          }
          break;
        case LogicalKeyboardKey.escape:
          if (_isEditing) {
            _textController.text = _value.toString();
            setState(() => _isEditing = false);
          }
          break;
      }
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool canDecrement = widget.enabled && _value > widget.min;
    final bool canIncrement = widget.enabled && _value < widget.max;

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: _handleKeyPress,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: webbTheme.typography.labelLarge.copyWith(
                color: widget.enabled
                    ? webbTheme.colorPalette.neutralDark
                    : webbTheme.interactionStates.disabledColor,
              ),
            ),
            SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
          ],
          
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decrement Button
              _buildButton(
                webbTheme,
                icon: Icons.remove,
                onPressed: canDecrement ? _decrement : null,
                isEnabled: canDecrement,
              ),

              SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),

              // Value Display or Input Field
              _buildValueDisplay(webbTheme, canDecrement, canIncrement),

              SizedBox(width: webbTheme.spacingGrid.spacing(0.5)),

              // Increment Button
              _buildButton(
                webbTheme,
                icon: Icons.add,
                onPressed: canIncrement ? _increment : null,
                isEnabled: canIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    BuildContext webbTheme, {
    required IconData icon,
    required VoidCallback? onPressed,
    required bool isEnabled,
  }) {
    return WebbUIIconButton(
      icon: icon,
      onPressed: onPressed,
      disabled: !isEnabled,
      tooltip: icon == Icons.add ? 'Increment' : 'Decrement',
    );
  }

  Widget _buildValueDisplay(
    BuildContext webbTheme,
    bool canDecrement,
    bool canIncrement,
  ) {
    final double touchTarget = webbTheme.accessibility.minTouchTargetSize;

    if (widget.showInputField && _isEditing) {
      return SizedBox(
        width: touchTarget * 2.5,
        child: WebbUITextField(
          controller: _textController,
          focusNode: _focusNode,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _saveTextInput(),
          maxLines: 1,
        ),
      );
    }

    return GestureDetector(
      onTap: widget.showInputField ? _startEditing : null,
      child: Container(
        constraints: BoxConstraints(
          minWidth: touchTarget * (widget.showInputField ? 2.5 : 1.5),
          minHeight: touchTarget,
        ),
        padding: EdgeInsets.symmetric(
          horizontal:
              webbTheme.spacingGrid.spacing(widget.showInputField ? 1 : 1.5),
          vertical: webbTheme.spacingGrid.spacing(0.5),
        ),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: webbTheme.colorPalette.neutralLight.withOpacity(
            widget.enabled ? 0.9 : 0.5,
          ),
          border: Border.all(
            color: webbTheme.colorPalette.neutralDark.withOpacity(
              widget.enabled ? 0.3 : 0.1,
            ),
            width: 1,
          ),
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        ),
        child: Text(
          '$_value',
          style: webbTheme.typography.bodyLarge.copyWith(
            color: widget.enabled
                ? webbTheme.colorPalette.neutralDark
                : webbTheme.interactionStates.disabledColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
