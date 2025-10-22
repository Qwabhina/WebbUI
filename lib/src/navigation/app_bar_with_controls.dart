import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'window_controls.dart';

/// A traditional AppBar that integrates window controls on desktop
class WebbUIAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final bool showWindowControls;

  const WebbUIAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = true,
    this.showWindowControls = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final isDesktop = WebbUIWindowControls.isDesktopPlatform;

    // Combine actions with window controls on desktop
    List<Widget>? combinedActions = actions ?? <Widget>[];
    if (isDesktop && showWindowControls) {
      combinedActions = [
        ...combinedActions,
        WebbUIWindowControls(
          buttonColor: foregroundColor ?? webbTheme.colorPalette.onSurface,
          hoverColor: (foregroundColor ?? webbTheme.colorPalette.onSurface)
              .withOpacity(0.1),
        ),
      ];
    }

    return AppBar(
      title: title != null ? Text(title!) : null,
      leading: leading,
      actions: combinedActions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? webbTheme.colorPalette.surface,
      foregroundColor: foregroundColor ?? webbTheme.colorPalette.neutralDark,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }
}
