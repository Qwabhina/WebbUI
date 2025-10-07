import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

enum WebbUICardType { standard, media, action, profile }

class WebbUICard extends StatelessWidget {
  final Widget child;
  final WebbUICardType type;
  final EdgeInsets? padding;
  final bool elevated;
  final String? title; // For profile/action cards
  final Widget? media; // For media cards
  final List<Widget>? actions; // For action cards
  final String? subtitle; // For profile cards
  final Widget? avatar; // For profile cards

  const WebbUICard({
    super.key,
    required this.child,
    this.type = WebbUICardType.standard,
    this.padding,
    this.elevated = true,
    this.title,
    this.media,
    this.actions,
    this.subtitle,
    this.avatar,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Base decoration for all cards
    final decoration = BoxDecoration(
      color: webbTheme.colorPalette.neutralLight,
      borderRadius: BorderRadius.circular(8),
      boxShadow: elevated ? webbTheme.elevation.getShadows(1) : null,
    );

    switch (type) {
      case WebbUICardType.standard:
        return Container(
          constraints: const BoxConstraints(
              maxWidth: double.infinity), // Prevents unbounded width
          decoration: decoration,
          child: Padding(
            padding:
                padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            child: child,
          ),
        );

      case WebbUICardType.media:
        return Container(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (media != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                  child: AspectRatio(
                    aspectRatio:
                        isMobile ? 16 / 9 : 4 / 3, // Responsive aspect ratio
                    child: media!,
                  ),
                ),
              Padding(
                padding:
                    padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                child: child,
              ),
            ],
          ),
        );

      case WebbUICardType.action:
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {}, // Override in parent for action
            child: Container(
              constraints: const BoxConstraints(maxWidth: double.infinity),
              decoration: decoration.copyWith(
                color:
                    webbTheme.interactionStates.hoverOverlay.withOpacity(0.1),
              ),
              child: Padding(
                padding:
                    padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(title!, style: webbTheme.typography.headlineMedium),
                    child,
                    if (actions != null)
                      Padding(
                        padding: EdgeInsets.only(
                            top: webbTheme.spacingGrid.spacing(2)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );

      case WebbUICardType.profile:
        return Container(
          constraints: const BoxConstraints(maxWidth: double.infinity),
          decoration: decoration,
          child: Padding(
            padding:
                padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (avatar != null)
                  Padding(
                    padding: EdgeInsets.only(
                        right: webbTheme.spacingGrid.spacing(2)),
                    child: avatar!,
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(title!,
                            style: webbTheme.typography.headlineMedium),
                      if (subtitle != null)
                        Text(subtitle!, style: webbTheme.typography.bodyMedium),
                      child,
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
    }
  }
}
