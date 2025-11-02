import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
    if (widget.focusNode == null) _focusNode.dispose();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  Widget? _buildSuffixIcon(BuildContext context) {
    if (widget.validationState == WebbUIValidationState.none) return null;

    final webbTheme = context;
    final Color iconColor =
        widget.validationState == WebbUIValidationState.success
        ? webbTheme.colorPalette.success
        : webbTheme.colorPalette.error;

    final IconData iconData =
        widget.validationState == WebbUIValidationState.success
            // ? Icons.check_circle
            ? FluentIcons.checkmark_circle_20_regular
            // : Icons.error;
            : FluentIcons.error_circle_20_regular;

    return Icon(
      iconData,
      color: iconColor,
      size: webbTheme.iconTheme.mediumSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    final suffixIcon = _buildSuffixIcon(context);

    final decoration = WebbUIInputDecoration.create(
      context: context,
      label: widget.label,
      hintText: widget.hintText,
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: suffixIcon,
      validationState: widget.validationState,
      validationMessage: widget.validationMessage,
      maxLines: widget.maxLines ?? 1,
      maxLength: widget.maxLength,
      currentLength: _controller.text.length,
      isFocused: _hasFocus,
      isDisabled: widget.disabled,
    );

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
      style: context.typography.bodyMedium.copyWith(
        color: widget.disabled
            ? context.interactionStates.disabledColor
            : context.colorPalette.neutralDark,
      ),
    );
  }
}
