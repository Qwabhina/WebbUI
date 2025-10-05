import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIEmptyState extends StatelessWidget {
  final String message;
  final Widget? illustration;
  final Widget? action;

  const WebbUIEmptyState({
    super.key,
    required this.message,
    this.illustration,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (illustration != null) illustration!,
          Text(
            message,
            style: webbTheme.typography.bodyLarge.copyWith(
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.7)),
            textAlign: TextAlign.center,
          ),
          if (action != null)
            Padding(
              padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(2)),
              child: action!,
            ),
        ],
      ),
    );
  }
}
