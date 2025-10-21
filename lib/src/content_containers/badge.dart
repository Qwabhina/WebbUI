import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUIBadgeColorType {
  primary,
  error,
  success,
  warning,
  info,
  neutral
}

enum WebbUIBadgeSize {
  small,
  medium,
  large,
}

class WebbUIBadge extends StatelessWidget {
  final String content;
  final WebbUIBadgeColorType colorType;
  final WebbUIBadgeSize size;
  final Widget? child;
  final bool showDot;
  final String? semanticLabel;

  const WebbUIBadge({
    super.key,
    required this.content,
    this.colorType = WebbUIBadgeColorType.neutral,
    this.size = WebbUIBadgeSize.medium,
    this.child,
    this.showDot = false,
    this.semanticLabel,
  });

  Color _getBackgroundColor(BuildContext webbTheme) {
    switch (colorType) {
      case WebbUIBadgeColorType.primary:
        return webbTheme.colorPalette.primary;
      case WebbUIBadgeColorType.error:
        return webbTheme.colorPalette.error;
      case WebbUIBadgeColorType.success:
        return webbTheme.colorPalette.success;
      case WebbUIBadgeColorType.warning:
        return webbTheme.colorPalette.warning;
      case WebbUIBadgeColorType.info:
        return webbTheme.colorPalette.info;
      case WebbUIBadgeColorType.neutral:
        return webbTheme.colorPalette.neutralDark.withOpacity(0.8);
    }
  }

  Color _getForegroundColor(BuildContext webbTheme) {
    switch (colorType) {
      case WebbUIBadgeColorType.primary:
      case WebbUIBadgeColorType.error:
      case WebbUIBadgeColorType.success:
      case WebbUIBadgeColorType.warning:
      case WebbUIBadgeColorType.info:
        return webbTheme.colorPalette.onPrimary;
      case WebbUIBadgeColorType.neutral:
        return webbTheme.colorPalette.neutralLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final backgroundColor = _getBackgroundColor(webbTheme);
    final foregroundColor = _getForegroundColor(webbTheme);

    double getPadding() {
      switch (size) {
        case WebbUIBadgeSize.small:
          return webbTheme.spacingGrid.spacing(0.5);
        case WebbUIBadgeSize.medium:
          return webbTheme.spacingGrid.spacing(0.75);
        case WebbUIBadgeSize.large:
          return webbTheme.spacingGrid.spacing(1);
      }
    }

    double getMinSize() {
      switch (size) {
        case WebbUIBadgeSize.small:
          return webbTheme.spacingGrid.spacing(1.5);
        case WebbUIBadgeSize.medium:
          return webbTheme.spacingGrid.spacing(2);
        case WebbUIBadgeSize.large:
          return webbTheme.spacingGrid.spacing(2.5);
      }
    }

    TextStyle getTextStyle() {
      final baseStyle = webbTheme.typography.labelMedium;
      switch (size) {
        case WebbUIBadgeSize.small:
          return baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 12) * 0.8,
            height: 1.0,
            color: foregroundColor,
          );
        case WebbUIBadgeSize.medium:
          return baseStyle.copyWith(
            fontSize: (baseStyle.fontSize ?? 12) * 0.9,
            height: 1.0,
            color: foregroundColor,
          );
        case WebbUIBadgeSize.large:
          return baseStyle.copyWith(
            height: 1.0,
            color: foregroundColor,
          );
      }
    }

    final badgeContent = showDot
        ? Container(
            width: getMinSize() / 2,
            height: getMinSize() / 2,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
          )
        : Container(
            constraints: BoxConstraints(
              minWidth: getMinSize(),
              minHeight: getMinSize(),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: getPadding(),
              vertical: getPadding() / 2,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(getMinSize() * 2),
            ),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: getTextStyle(),
            ),
          );

    if (child == null) {
      return Semantics(
        label: semanticLabel ?? content,
        container: true,
        child: badgeContent,
      );
    }

    return Badge(
      label: badgeContent,
      backgroundColor: backgroundColor,
      textColor: foregroundColor,
      offset: Offset(
        webbTheme.spacingGrid.spacing(0.5),
        webbTheme.spacingGrid.spacing(-0.5),
      ),
      child: child!,
    );
  }
}
