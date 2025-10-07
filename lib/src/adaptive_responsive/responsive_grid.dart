import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int? crossAxisCount;
  final double? childAspectRatio;
  final EdgeInsets? padding;

  const WebbUIResponsiveGrid({
    super.key,
    required this.children,
    this.crossAxisCount,
    this.childAspectRatio,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;
    final int effectiveCrossAxisCount = crossAxisCount ??
        (width > 1024
            ? 4
            : width > 600
                ? 2
                : 1); // Desktop: 4, Tablet: 2, Mobile: 1

    return Padding(
      padding: padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.count(
            crossAxisCount: effectiveCrossAxisCount,
            childAspectRatio: childAspectRatio ?? 1.0,
            mainAxisSpacing: webbTheme.spacingGrid.gutter,
            crossAxisSpacing: webbTheme.spacingGrid.gutter,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Parent handles scrolling
            children: children,
          );
        },
      ),
    );
  }
}
