import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'window_controls.dart';

/// Variants of the top navigation bar
enum WebbUITopNavBarVariant {
  primary, // Primary color background
  surface, // Surface color background
  transparent, // Transparent background
  elevated, // With shadow elevation
}

class WebbUITopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? badge;
  final bool showWindowControls;
  final WebbUITopNavBarVariant variant;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool centerTitle;
  final bool automaticallyImplyLeading;

  const WebbUITopNavBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.badge,
    this.showWindowControls = true,
    this.variant = WebbUITopNavBarVariant.primary,
    this.elevation = 0.0,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  Color _getBackgroundColor(BuildContext webbTheme) {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case WebbUITopNavBarVariant.primary:
        return webbTheme.colorPalette.primary;
      case WebbUITopNavBarVariant.surface:
        return webbTheme.colorPalette.surface;
      case WebbUITopNavBarVariant.transparent:
        return Colors.transparent;
      case WebbUITopNavBarVariant.elevated:
        return webbTheme.colorPalette.surface;
    }
  }

  Color _getForegroundColor(BuildContext webbTheme) {
    if (foregroundColor != null) return foregroundColor!;

    switch (variant) {
      case WebbUITopNavBarVariant.primary:
        return webbTheme.colorPalette.onPrimary;
      case WebbUITopNavBarVariant.surface:
      case WebbUITopNavBarVariant.elevated:
        return webbTheme.colorPalette.neutralDark;
      case WebbUITopNavBarVariant.transparent:
        return webbTheme.colorPalette.neutralDark;
    }
  }

  List<BoxShadow>? _getBoxShadow(BuildContext webbTheme) {
    if (variant == WebbUITopNavBarVariant.elevated) {
      return webbTheme.elevation.getShadows(2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bgColor = _getBackgroundColor(webbTheme);
    final fgColor = _getForegroundColor(webbTheme);
    final boxShadow = _getBoxShadow(webbTheme);

    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: boxShadow,
      ),
      child: Row(
        children: [
          // Leading widget (menu icon, back button, etc.)
          if (leading != null || automaticallyImplyLeading)
            _buildLeadingSection(webbTheme, fgColor),

          // Draggable title area (desktop) or centered title (mobile)
          Expanded(
            child: _buildTitleSection(webbTheme, fgColor),
          ),

          // Badge and actions section
          _buildTrailingSection(webbTheme, fgColor),
        ],
      ),
    );
  }

  Widget _buildLeadingSection(BuildContext webbTheme, Color fgColor) {
    final hasLeading = leading != null;
    final shouldImplyLeading = automaticallyImplyLeading && !hasLeading;

    if (!hasLeading && !shouldImplyLeading) {
      return const SizedBox();
    }

    return Padding(
      padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(1)),
      child: hasLeading
          ? leading!
          : IconButton(
              icon: Icon(Icons.arrow_back, color: fgColor),
              onPressed: () => Navigator.maybePop(webbTheme),
              tooltip: 'Back',
            ),
    );
  }

  Widget _buildTitleSection(BuildContext webbTheme, Color fgColor) {
    final titleWidget = Center(
      child: Text(
        title,
        style: webbTheme.typography.headlineMedium.copyWith(
          color: fgColor,
          fontWeight: FontWeight.w600,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );

    // Only make draggable on desktop with window controls
    if (WebbUIWindowControls.isDesktopPlatform && showWindowControls) {
      return MoveWindow(
        child: centerTitle
            ? titleWidget
            : Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: webbTheme.spacingGrid.spacing(2)),
                  child: titleWidget,
                ),
              ),
      );
    }

    return centerTitle
        ? titleWidget
        : Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: webbTheme.spacingGrid.spacing(2)),
              child: titleWidget,
            ),
          );
  }

  Widget _buildTrailingSection(BuildContext webbTheme, Color fgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Badge
        if (badge != null)
          Padding(
            padding: EdgeInsets.only(right: webbTheme.spacingGrid.spacing(1)),
            child: badge!,
          ),

        // Actions
        if (actions != null) ...actions!,

        // Window controls (desktop only)
        if (showWindowControls && WebbUIWindowControls.isDesktopPlatform)
          Padding(
            padding: EdgeInsets.only(
              left: webbTheme.spacingGrid.spacing(1),
              right: webbTheme.spacingGrid.spacing(0.5),
            ),
            child: WebbUIWindowControls(
              buttonColor: fgColor,
              hoverColor: fgColor.withOpacity(0.1),
            ),
          ),
      ],
    );
  }
}
