import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUISearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final List<Widget>? filters;

  const WebbUISearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.filters,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: webbTheme.typography.bodyMedium.copyWith(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.6)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: webbTheme.colorPalette.neutralDark.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: webbTheme.interactionStates.focusedBorder),
              ),
              prefixIcon:
                  Icon(Icons.search, color: webbTheme.colorPalette.neutralDark),
            ),
          ),
        ),
        if (filters != null) ...filters!,
      ],
    );
  }
}
