import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum WebbUIAlertType { success, warning, error, info }

class WebbUIAlert extends StatelessWidget {
  final String message;
  final WebbUIAlertType type;
  final VoidCallback? onDismiss;
  final bool dismissible;

  const WebbUIAlert({
    super.key,
    required this.message,
    this.type = WebbUIAlertType.info,
    this.onDismiss,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final Color backgroundColor;
    final IconData icon;
    switch (type) {
      case WebbUIAlertType.success:
        backgroundColor = webbTheme.colorPalette.success;
        icon = Icons.check_circle;
        break;
      case WebbUIAlertType.warning:
        backgroundColor = webbTheme.colorPalette.warning;
        icon = Icons.warning;
        break;
      case WebbUIAlertType.error:
        backgroundColor = webbTheme.colorPalette.error;
        icon = Icons.error;
        break;
      case WebbUIAlertType.info:
        backgroundColor = webbTheme.colorPalette.info;
        icon = Icons.info;
        break;
    }

    return Container(
      padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
      color: backgroundColor,
      child: Row(
        children: [
          Icon(icon,
              color: Colors.white,
              size: context.iconTheme.mediumSize),
          SizedBox(width: webbTheme.spacingGrid.spacing(2)),
          Expanded(
            child: Text(
              message,
              style:
                  webbTheme.typography.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
          if (dismissible)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismiss,
            ),
        ],
      ),
    );
  }
}
