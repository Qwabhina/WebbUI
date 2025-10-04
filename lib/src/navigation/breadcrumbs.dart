import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIBreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const WebbUIBreadcrumbItem({required this.label, this.onTap});
}

class WebbUIBreadcrumbs extends StatelessWidget {
  final List<WebbUIBreadcrumbItem> items;

  const WebbUIBreadcrumbs({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Row(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        return Row(
          children: [
            GestureDetector(
              onTap: item.onTap,
              child: Text(
                item.label,
                style: webbTheme.typography.bodyMedium.copyWith(
                  color: item.onTap != null
                      ? webbTheme.colorPalette.primary
                      : webbTheme.colorPalette.neutralDark,
                ),
              ),
            ),
            if (index < items.length - 1)
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: webbTheme.spacingGrid.spacing(1)),
                child: Text('/', style: webbTheme.typography.bodyMedium),
              ),
          ],
        );
      }).toList(),
    );
  }
}
