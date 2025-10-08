import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIBreakpointLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget desktopLayout;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final bool applyAutoPadding; // Whether to apply responsive padding

  const WebbUIBreakpointLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    required this.desktopLayout,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.applyAutoPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final webbTheme = context;

    EdgeInsets getDefaultPadding() {
      final double spacing = webbTheme.spacingGrid.spacing(2);
      return EdgeInsets.all(spacing);
    }

    Widget layout;
    EdgeInsets padding;

    if (WebbUIBreakpoints.isMobile(width)) {
      layout = mobileLayout;
      padding = mobilePadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    } else if (WebbUIBreakpoints.isTablet(width)) {
      layout = tabletLayout ?? mobileLayout;
      padding = tabletPadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    } else {
      layout = desktopLayout;
      padding = desktopPadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    }

    return Padding(
      padding: padding,
      child: layout,
    );
  }
}
