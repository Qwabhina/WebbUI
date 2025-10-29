import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? mobileCrossAxisCount;
  final int? tabletCrossAxisCount;
  final int? desktopCrossAxisCount;
  final double? childAspectRatio;
  final EdgeInsets? padding;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  const WebbUIResponsiveGrid({
    super.key,
    required this.children,
    this.mobileCrossAxisCount,
    this.tabletCrossAxisCount,
    this.desktopCrossAxisCount,
    this.childAspectRatio,
    this.padding,
    this.mainAxisSpacing = 16.0,
    this.crossAxisSpacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    int getCrossAxisCount() {
      if (WebbUIBreakpoints.isMobile(width)) {
        return mobileCrossAxisCount ?? 1;
      } else if (WebbUIBreakpoints.isTablet(width)) {
        return tabletCrossAxisCount ?? 2;
      } else {
        return desktopCrossAxisCount ?? 4;
      }
    }

    return Padding(
      padding: padding ?? EdgeInsets.all(context.spacingGrid.spacing(1.5)),
      child: GridView.count(
        crossAxisCount: getCrossAxisCount(),
        childAspectRatio: childAspectRatio ?? 1.0,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: children,
      ),
    );
  }
}
