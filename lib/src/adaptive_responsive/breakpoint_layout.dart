import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIBreakpointLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget? tabletLayout;
  final Widget desktopLayout;
  final double mobileBreakpoint;
  final double tabletBreakpoint;

  const WebbUIBreakpointLayout({
    super.key,
    required this.mobileLayout,
    this.tabletLayout,
    required this.desktopLayout,
    this.mobileBreakpoint = 600.0,
    this.tabletBreakpoint = 1024.0,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final webbTheme = context;

    if (width < mobileBreakpoint) {
      return Padding(
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
        child: mobileLayout,
      );
    } else if (width < tabletBreakpoint) {
      return Padding(
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
        child: tabletLayout ?? mobileLayout,
      );
    } else {
      return Padding(
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
        child: desktopLayout,
      );
    }
  }
}
