import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIBreakpointLayout extends StatelessWidget {
  final WidgetBuilder mobileBuilder;
  final WidgetBuilder? tabletBuilder;
  final WidgetBuilder? desktopBuilder;
  final WidgetBuilder? largeDesktopBuilder;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? largeDesktopPadding;
  final bool applyAutoPadding;

  const WebbUIBreakpointLayout({
    super.key,
    required this.mobileBuilder,
    this.tabletBuilder,
    this.desktopBuilder,
    this.largeDesktopBuilder,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.largeDesktopPadding,
    this.applyAutoPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    EdgeInsets getDefaultPadding() {
      final double spacing = context.spacingGrid.spacing(2);
      return EdgeInsets.all(spacing);
    }

    Widget layout;
    EdgeInsets padding;

    if (WebbUIBreakpoints.isMobile(width)) {
      layout = mobileBuilder(context);
      padding = mobilePadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    } else if (WebbUIBreakpoints.isTablet(width)) {
      layout = (tabletBuilder ?? mobileBuilder)(context);
      padding = tabletPadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    } else if (WebbUIBreakpoints.isDesktop(width)) {
      layout = (desktopBuilder ?? tabletBuilder ?? mobileBuilder)(context);
      padding = desktopPadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    } else {
      layout = (largeDesktopBuilder ??
          desktopBuilder ??
          tabletBuilder ??
          mobileBuilder)(context);
      padding = largeDesktopPadding ??
          (applyAutoPadding ? getDefaultPadding() : EdgeInsets.zero);
    }

    return Padding(
      padding: padding,
      child: layout,
    );
  }
}
