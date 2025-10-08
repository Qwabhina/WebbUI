import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A theme-compliant list tile component, designed for use within [WebbUIList]
/// or as a standalone clickable item.
///
/// It applies themed typography, colors, icon sizes, and interaction states.
class WebbUIListTile extends StatelessWidget {
  /// A widget to display before the title. Typically an [Icon] or [CircleAvatar].
  final Widget? leading;

  /// The primary content of the list tile.
  final String title;

  /// Additional content displayed below the title.
  final String? subtitle;

  /// A widget to display after the title. Typically an [Icon] or [WebbUIButton].
  final Widget? trailing;

  /// Called when the user taps this list tile. If null, the tile is disabled.
  final VoidCallback? onTap;

  /// Whether this list tile is part of a dense list (tighter vertical spacing).
  final bool dense;

  const WebbUIListTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final isEnabled = onTap != null;

    // --- Themed Colors and Styles ---
    // Text colors adjust based on enabled/disabled state
    final Color titleColor = isEnabled
        ? webbTheme.colorPalette.neutralDark
        : webbTheme.interactionStates.disabledColor;
    final Color subtitleColor = isEnabled
        ? webbTheme.colorPalette.neutralDark.withOpacity(0.6)
        : webbTheme.interactionStates.disabledColor.withOpacity(0.7);
    final Color iconColor = isEnabled
        ? webbTheme.colorPalette.neutralDark.withOpacity(0.7)
        : webbTheme.interactionStates.disabledColor.withOpacity(0.5);

    return ListTile(
      onTap: onTap,
      dense: dense,

      // Apply interaction states from the theme
      hoverColor: webbTheme.interactionStates.hoverOverlay,
      splashColor: webbTheme.interactionStates.pressedOverlay,

      // Base style and padding
      tileColor: webbTheme.colorPalette.neutralLight,
      contentPadding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(2),
        vertical: webbTheme.spacingGrid.spacing(dense ? 0.5 : 1),
      ),

      // Leading: Merges theme icon size and calculated color
      leading: leading != null
          ? IconTheme.merge(
              data: IconThemeData(
                color: iconColor,
                size: webbTheme.iconTheme.mediumSize,
              ),
              child: leading!,
            )
          : null,

      // Title: Applies theme typography and color
      title: Text(
        title,
        style: webbTheme.typography.bodyLarge.copyWith(color: titleColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      // Subtitle: Applies theme typography and color
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: webbTheme.typography.bodyMedium
                  .copyWith(color: subtitleColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,

      // Trailing: Merges theme icon size and calculated color
      trailing: trailing != null
          ? IconTheme.merge(
              data: IconThemeData(
                color: iconColor,
                size: webbTheme.iconTheme.mediumSize,
              ),
              child: trailing!,
            )
          : null,
    );
  }
}
