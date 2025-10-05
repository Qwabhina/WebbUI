import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum WebbUIStatusType { online, offline, pending, custom }

class WebbUIStatusIndicator extends StatelessWidget {
  final WebbUIStatusType type;
  final String? label;
  final Color? customColor;

  const WebbUIStatusIndicator({
    super.key,
    required this.type,
    this.label,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final Color color;
    switch (type) {
      case WebbUIStatusType.online:
        color = webbTheme.colorPalette.success;
        break;
      case WebbUIStatusType.offline:
        color = webbTheme.colorPalette.error;
        break;
      case WebbUIStatusType.pending:
        color = webbTheme.colorPalette.warning;
        break;
      case WebbUIStatusType.custom:
        color = customColor ?? webbTheme.colorPalette.neutralDark;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12.0,
          height: 12.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (label != null)
          Padding(
            padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
            child: Text(
              label!,
              style: webbTheme.typography.labelMedium
                  .copyWith(color: webbTheme.colorPalette.neutralDark),
            ),
          ),
      ],
    );
  }
}
