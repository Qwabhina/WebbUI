import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the size presets for the [WebbUIModal] component.
enum WebbUIModalType {
  custom, // User-defined size via constraints
  mini, // Small fixed size (e.g., 300x200)
  small, // Moderate fixed size (e.g., 400x300)
  medium, // Standard fixed size (e.g., 500x400)
  large, // Larger fixed size (e.g., 600x500)
  fixed, // Fixed to content size with max limits (responsive max)
  scrollable, // Content scrolls within a max height (responsive max)
  fullscreen, // Full screen, adaptive to device
}

/// A theme-compliant, customizable modal dialog component.
class WebbUIModal extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final WebbUIModalType type;
  final BoxConstraints? customConstraints; // For custom type
  final bool showCloseButton;
  final bool barrierDismissible;
  final Color? barrierColor;

  const WebbUIModal({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.type = WebbUIModalType.medium,
    this.customConstraints,
    this.showCloseButton = true,
    this.barrierDismissible = true,
    this.barrierColor,
  });

  /// The standard way to display the modal dialog.
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
    WebbUIModalType type = WebbUIModalType.medium,
    BoxConstraints? customConstraints,
    bool showCloseButton = true,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black54,
      builder: (context) => WebbUIModal(
        title: title,
        actions: actions,
        type: type,
        customConstraints: customConstraints,
        showCloseButton: showCloseButton,
        barrierDismissible: barrierDismissible,
        barrierColor: barrierColor,
        child: child,
      ),
    );
  }

  BoxConstraints _getConstraints(BuildContext context) {
    final bool isMobile =
        MediaQuery.of(context).size.width < WebbUIBreakpoints.mobile;
    final bool isTablet =
        MediaQuery.of(context).size.width < WebbUIBreakpoints.tablet;

    final double maxWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.95
        : isTablet
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.6;
    
    final double maxHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.95
        : MediaQuery.of(context).size.height * 0.85;

    switch (type) {
      case WebbUIModalType.custom:
        return customConstraints ??
            const BoxConstraints(maxWidth: 500, maxHeight: 600);
      case WebbUIModalType.mini:
        return const BoxConstraints(
            minWidth: 300, maxWidth: 300, minHeight: 200, maxHeight: 200);
      case WebbUIModalType.small:
        return const BoxConstraints(
            minWidth: 400, maxWidth: 400, minHeight: 300, maxHeight: 300);
      case WebbUIModalType.medium:
        return const BoxConstraints(
            minWidth: 500, maxWidth: 500, minHeight: 400, maxHeight: 400);
      case WebbUIModalType.large:
        return const BoxConstraints(
            minWidth: 600, maxWidth: 600, minHeight: 500, maxHeight: 500);
      case WebbUIModalType.fixed:
        return BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 300,
          minHeight: 200,
        );
      case WebbUIModalType.scrollable:
        return BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );
      case WebbUIModalType.fullscreen:
        return BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height,
        );
    }
  }

  Widget _buildContent(BuildContext webbTheme) {
    final EdgeInsets padding = EdgeInsets.all(webbTheme.spacingGrid.spacing(2));

    if (type == WebbUIModalType.scrollable) {
      return SingleChildScrollView(
        padding: padding,
        child: child,
      );
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile =
        MediaQuery.of(context).size.width < WebbUIBreakpoints.mobile;

    // Fixed-size modals (mini, small, medium, large) and scrollable/fullscreen
    // need the content area to expand to fill the defined BoxConstraints.
    final bool hasFixedDimensions = type.index >= WebbUIModalType.mini.index &&
        type.index <= WebbUIModalType.large.index;

    final bool shouldExpandContent = hasFixedDimensions ||
        type == WebbUIModalType.scrollable ||
        type == WebbUIModalType.fullscreen;

    return Dialog(
      // Ensure zero padding for mobile/fullscreen to truly fill the viewport
      insetPadding: isMobile || type == WebbUIModalType.fullscreen
          ? EdgeInsets.zero
          // Generous padding for desktop/tablet views
          : EdgeInsets.all(webbTheme.spacingGrid.spacing(3)),

      child: ConstrainedBox(
        constraints: _getConstraints(context),
        child: Container(
          // Apply background color, themed border radius, and elevation
          decoration: BoxDecoration(
            color: webbTheme.colorPalette.neutralLight,
            borderRadius: type == WebbUIModalType.fullscreen
                ? BorderRadius.zero
                : BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            boxShadow: webbTheme.elevation.getShadows(3),
          ),
          child: Column(
            mainAxisSize:
                shouldExpandContent ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || showCloseButton)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    webbTheme.spacingGrid.spacing(2),
                    webbTheme.spacingGrid.spacing(2),
                    webbTheme.spacingGrid.spacing(1),
                    webbTheme.spacingGrid.spacing(1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (title != null)
                        Flexible(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: webbTheme.spacingGrid.spacing(1),
                            ),
                            child: Text(
                              title!,
                              style:
                                  webbTheme.typography.headlineMedium.copyWith(
                                color: webbTheme.colorPalette.neutralDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      const Spacer(),
                      if (showCloseButton)
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: webbTheme.colorPalette.neutralDark
                                .withOpacity(0.7),
                            size: webbTheme.iconTheme.mediumSize,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          tooltip: 'Close',
                          constraints: BoxConstraints.tightFor(
                            width: webbTheme.accessibility.minTouchTargetSize,
                            height: webbTheme.accessibility.minTouchTargetSize,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                    ],
                  ),
                ),

              // Optional Divider beneath the title
              if (title != null)
                Divider(
                  height: 1,
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                ),

              // --- CONTENT SECTION ---
              // If the content should expand (fixed-size, scrollable, fullscreen types)
              if (shouldExpandContent)
                Expanded(
                  child: _buildContent(webbTheme),
                )
              // If the content should shrink-wrap (fixed type, custom with unbound height)
              else
                _buildContent(webbTheme),

              // --- ACTION SECTION ---
              if (actions != null && actions!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // Use a Row for actions, relying on parent constraints to manage overflow
                    children: actions!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
