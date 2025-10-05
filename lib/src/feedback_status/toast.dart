import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum WebbUIToastType { success, warning, error, info }

class WebbUIToast {
  static void show(
    BuildContext context, {
    required String message,
    WebbUIToastType type = WebbUIToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final webbTheme = context;
    final Color backgroundColor;
    final IconData icon;
    switch (type) {
      case WebbUIToastType.success:
        backgroundColor = webbTheme.colorPalette.success;
        icon = Icons.check_circle;
        break;
      case WebbUIToastType.warning:
        backgroundColor = webbTheme.colorPalette.warning;
        icon = Icons.warning;
        break;
      case WebbUIToastType.error:
        backgroundColor = webbTheme.colorPalette.error;
        icon = Icons.error;
        break;
      case WebbUIToastType.info:
        backgroundColor = webbTheme.colorPalette.info;
        icon = Icons.info;
        break;
    }

    final toast = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 50.0,
        left: 0.0,
        right: 0.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: webbTheme.spacingGrid.spacing(2)),
            padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: webbTheme.elevation.getShadows(2),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: Colors.white,
                    size: WebbUIIconTheme.getIconSize(context,
                        sizeType: 'medium')),
                SizedBox(width: webbTheme.spacingGrid.spacing(2)),
                Expanded(
                  child: Text(
                    message,
                    style: webbTheme.typography.bodyMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(toast);
    Future.delayed(duration, () => toast.remove());
  }
}
