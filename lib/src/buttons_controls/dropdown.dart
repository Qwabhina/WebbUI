import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIDropdown<T> extends StatelessWidget {
  final T? value;
  final ValueChanged<T?>? onChanged;
  final List<DropdownMenuItem<T>> items;
  final String? hint;
  final String? label;
  final bool disabled;
  final String? errorText;

  const WebbUIDropdown({
    super.key,
    this.value,
    this.onChanged,
    required this.items,
    this.hint,
    this.label,
    this.disabled = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: webbTheme.typography.bodyMedium.copyWith(
              color: webbTheme.colorPalette.neutralDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
        ],
        DropdownButtonFormField<T>(
          value: value,
          onChanged: disabled ? null : onChanged,
          items: items,
          hint: hint != null
              ? Text(
                  hint!,
                  style: webbTheme.typography.bodyMedium.copyWith(
                    color: webbTheme.colorPalette.neutralDark
                        .withOpacity(disabled ? 0.3 : 0.6),
                  ),
                )
              : null,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? webbTheme.colorPalette.error
                    : webbTheme.colorPalette.neutralDark.withOpacity(0.3),
              ),
            ),
            enabled: !disabled,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null
                    ? webbTheme.colorPalette.error
                    : webbTheme.interactionStates.focusedBorder,
                width: 2,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(2),
              vertical: webbTheme.spacingGrid.spacing(1.5),
            ),
            errorText: errorText,
            filled: disabled,
            fillColor: disabled
                ? webbTheme.interactionStates.disabledColor.withOpacity(0.1)
                : null,
          ),
          style: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.neutralDark
                .withOpacity(disabled ? 0.5 : 1.0),
          ),
          icon: Icon(
            Icons.arrow_drop_down,
            color: webbTheme.colorPalette.neutralDark
                .withOpacity(disabled ? 0.5 : 1.0),
          ),
          dropdownColor: webbTheme.colorPalette.surface,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
