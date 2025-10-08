import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the data structure for a single item in the breadcrumbs trail.
class WebbUIBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const WebbUIBreadcrumbItem({required this.label, this.onTap});
}

/// A custom-themed Breadcrumbs component for navigation history.
class WebbUIBreadcrumbs extends StatelessWidget {
  final List<WebbUIBreadcrumbItem> items;

  const WebbUIBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    
    return Row(
      // Ensure the row content does not overflow
      mainAxisSize: MainAxisSize.min, 
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;

        // Check if this is the last item in the list
        final isLastItem = index == items.length - 1;

        return Row(
          children: [
            // 1. The Breadcrumb Label (wrapped in GestureDetector if clickable)
            GestureDetector(
              // Only assign onTap if a callback is provided (i.e., not the last item)
              onTap: item.onTap, 
              child: Text(
                item.label,
                style: webbTheme.typography.bodyMedium.copyWith(
                  // Interactive items are primary color; non-interactive items are neutral/dark
                  color: item.onTap != null
                      ? webbTheme.colorPalette.primary
                      : webbTheme.colorPalette.neutralDark,
                  // Optionally slightly thicker for the current page
                  fontWeight: isLastItem ? FontWeight.bold : FontWeight.normal, 
                ),
              ),
            ),
            
            // 2. The Separator (only added if it's not the last item)
            if (!isLastItem)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: webbTheme.spacingGrid.spacing(1)),
                child: Text(
                  '/',
                  style: webbTheme.typography.bodyMedium.copyWith(
                    color: webbTheme.colorPalette.neutral,
                  ),
                ),
              ),
          ],
        );
      }).toList(),
    );
  }
}
