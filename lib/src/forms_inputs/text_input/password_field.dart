import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'input_decoration.dart';
import 'validation_states.dart';

class WebbUIPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? label;
  final String? hintText;
  final WebbUIValidationState validationState;
  final String? validationMessage;
  final bool disabled;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const WebbUIPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.label,
    this.hintText,
    this.validationState = WebbUIValidationState.none,
    this.validationMessage,
    this.disabled = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<WebbUIPasswordField> createState() => _WebbUIPasswordFieldState();
}

class _WebbUIPasswordFieldState extends State<WebbUIPasswordField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _obscureText = true;
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

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    // Visibility toggle icon
    final Widget suffixIcon = IconButton(
      icon: Icon(
        _obscureText ? Icons.visibility_off : Icons.visibility,
        size: webbTheme.iconTheme.mediumSize,
        color: widget.disabled
            ? webbTheme.interactionStates.disabledColor
            : webbTheme.colorPalette.neutralDark,
      ),
      onPressed: widget.disabled
          ? null
          : () => setState(() => _obscureText = !_obscureText),
      splashRadius: webbTheme.iconTheme.mediumSize / 2,
    );

    final decoration = WebbUIInputDecoration(
      webbTheme: webbTheme,
      label: widget.label,
      hintText: widget.hintText,
      suffixIcon: suffixIcon,
      validationState: widget.validationState,
      validationMessage: widget.validationMessage,
      maxLines: 1,
      isFocused: _hasFocus,
      isDisabled: widget.disabled,
    ).getDecoration();

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: _obscureText,
      enabled: !widget.disabled,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.visiblePassword,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.done,
      decoration: decoration,
      style: webbTheme.typography.bodyMedium.copyWith(
        color: widget.disabled
            ? webbTheme.interactionStates.disabledColor
            : webbTheme.colorPalette.neutralDark,
      ),
    );
  }
}
