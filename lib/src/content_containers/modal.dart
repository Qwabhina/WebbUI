import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUIModalType {
  custom, // User-defined size via constraints
  mini, // Small fixed size (e.g., 300x200)
  small, // Moderate fixed size (e.g., 400x300)
  medium, // Standard fixed size (e.g., 500x400)
  large, // Larger fixed size (e.g., 600x500)
  fixed, // Fixed to content size with max limits
  scrollable, // Content scrolls within a max height
  fullscreen, // Full screen, adaptive to device
}

class WebbUIModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final WebbUIModalType type;
  final BoxConstraints? customConstraints; // For custom type

  const WebbUIModal({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.type = WebbUIModalType.medium,
    this.customConstraints,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    WebbUIModalType type = WebbUIModalType.medium,
    BoxConstraints? customConstraints,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => WebbUIModal(
        title: title,
        actions: actions,
        type: type,
        customConstraints: customConstraints,
        child: child,
      ),
    );
  }

  BoxConstraints _getConstraints(BuildContext context) {
    // final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double maxWidth =
        MediaQuery.of(context).size.width * (isMobile ? 0.9 : 0.7);
    final double maxHeight =
        MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.8);

    switch (type) {
      case WebbUIModalType.custom:
        return customConstraints ??
            const BoxConstraints(maxWidth: 500, maxHeight: 600);
      case WebbUIModalType.mini:
        return const BoxConstraints(
            minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200);
      case WebbUIModalType.small:
        return const BoxConstraints(
            minWidth: 400, maxWidth: 400, minHeight: 300, maxHeight: 300);
      case WebbUIModalType.medium:
        return const BoxConstraints(
            minWidth: 500, maxWidth: 500, minHeight: 400, maxHeight: 400);
      case WebbUIModalType.large:
        return const BoxConstraints(
            minWidth: 600, maxWidth: 600, minHeight: 500, maxHeight: 500);
      case WebbUIModalType.fixed:
        return BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 300,
          minHeight: 200,
        );
      case WebbUIModalType.scrollable:
        return BoxConstraints(
          maxWidth: maxWidth,
          maxHeight:
              maxHeight * 0.7, // Scrollable area within 70% of screen height
        );
      case WebbUIModalType.fullscreen:
        return BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Dialog(
      insetPadding: isMobile || type == WebbUIModalType.fullscreen
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: _getConstraints(context),
        child: Container(
          decoration: BoxDecoration(
            color: webbTheme.colorPalette.neutralLight,
            borderRadius: type == WebbUIModalType.fullscreen
                ? null
                : BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Padding(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                  child:
                      Text(title!, style: webbTheme.typography.headlineMedium),
                ),
              Expanded(
                child: type == WebbUIModalType.scrollable
                    ? SingleChildScrollView(
                        padding:
                            EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                        child: child,
                      )
                    : Padding(
                        padding:
                            EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                        child: child,
                      ),
              ),
              if (actions != null)
                Padding(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
