import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'input_decoration.dart';
import 'validation_states.dart';

class WebbUITextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final bool disabled;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enableInteractiveSelection;
  final String? restorationId;
  final VoidCallback? onCancel; // Optional for base field
  final bool enableEscapeToCancel;

  const WebbUITextField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onEditingComplete,
    this.disabled = false,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enableInteractiveSelection = true,
    this.restorationId,
    this.onCancel,
    this.enableEscapeToCancel = false,
  });

  @override
  State<WebbUITextField> createState() => _WebbUITextFieldState();
}

class _WebbUITextFieldState extends State<WebbUITextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();

    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    // Only dispose if we created the focus node and controller
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  Widget? _buildSuffixIcon(BuildContext webbTheme) {
    if (widget.validationState == WebbUIValidationState.none) {
      return null;
    }

    final Color iconColor =
        widget.validationState == WebbUIValidationState.success
        ? webbTheme.colorPalette.success
        : webbTheme.colorPalette.error;

    final IconData iconData =
        widget.validationState == WebbUIValidationState.success
        ? Icons.check_circle
        : Icons.error;

    return Icon(
      iconData,
      color: iconColor,
      size: webbTheme.iconTheme.mediumSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final suffixIcon = _buildSuffixIcon(webbTheme);

    final decoration = WebbUIInputDecoration(
      webbTheme: webbTheme,
      label: widget.label,
      hintText: widget.hintText,
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: suffixIcon,
      validationState: widget.validationState,
      validationMessage: widget.validationMessage,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      currentLength: _controller.text.length,
      isFocused: _hasFocus,
      isDisabled: widget.disabled,
    ).getDecoration();

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
      enabled: !widget.disabled,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enableInteractiveSelection: widget.enableInteractiveSelection,
      restorationId: widget.restorationId,
      decoration: decoration,
      style: webbTheme.typography.bodyMedium.copyWith(
        color: widget.disabled
            ? webbTheme.interactionStates.disabledColor
            : webbTheme.colorPalette.neutralDark,
      ),
    );
  }
}
