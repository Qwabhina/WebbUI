import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIDropdown<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final String? hint;
  final bool disabled;

  const WebbUIDropdown({
    super.key,
    this.value,
    this.onChanged,
    required this.items,
    this.hint,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: disabled ? null : onChanged,
      items: items,
      hint: hint != null
          ? Text(hint!,
              style: webbTheme.typography.bodyMedium.copyWith(
                  color: webbTheme.colorPalette.neutralDark
                      .withOpacity(disabled ? 0.3 : 0.6)))
          : null,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
              color: webbTheme.colorPalette.neutralDark
                  .withOpacity(disabled ? 0.3 : 0.6)),
        ),
        enabled: !disabled,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: webbTheme.interactionStates.focusedBorder),
        ),
        contentPadding: EdgeInsets.symmetric(
            horizontal: webbTheme.spacingGrid.spacing(2),
            vertical: webbTheme.spacingGrid.spacing(1)),
      ),
      style: webbTheme.typography.bodyMedium.copyWith(
          color: webbTheme.colorPalette.neutralDark
              .withOpacity(disabled ? 0.5 : 1.0)),
      icon: Icon(Icons.arrow_drop_down,
          color: webbTheme.colorPalette.neutralDark
              .withOpacity(disabled ? 0.5 : 1.0)),
      dropdownColor: webbTheme.colorPalette.neutralLight,
    );
  }
}
