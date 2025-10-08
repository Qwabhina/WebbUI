import 'package:flutter/material.dart';
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

  const WebbUIModal({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.type = WebbUIModalType.medium,
    this.customConstraints,
    this.showCloseButton = true, // Default to true for user convenience
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
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true, // Default dialog behavior
      builder: (context) => WebbUIModal(
        title: title,
        actions: actions,
        type: type,
        customConstraints: customConstraints,
        showCloseButton: showCloseButton,
        child: child,
      ),
    );
  }

  /// Calculates the appropriate BoxConstraints based on the modal type and screen size.
  BoxConstraints _getConstraints(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Responsive max dimensions (used for fixed, scrollable, and fixed-size types)
    final double maxWidth =
        MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.7);
    final double maxHeight =
        MediaQuery.of(context).size.height * (isMobile ? 0.95 : 0.85);

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
        // Max limits for fixed-to-content, but allows content to define size
        return BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          minWidth: 300,
          minHeight: 200,
        );
      case WebbUIModalType.scrollable:
        // Constrains the height for the scrollable area
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

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

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
            boxShadow:
                webbTheme.elevation.getShadows(3), // High elevation for a modal
          ),

          child: Column(
            // Use MainAxisSize.max when content should expand; otherwise, shrink-wrap.
            mainAxisSize:
                shouldExpandContent ? MainAxisSize.max : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- HEADER/TITLE SECTION ---
              if (title != null || showCloseButton)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    webbTheme.spacingGrid.spacing(2), // Left
                    webbTheme.spacingGrid.spacing(2), // Top
                    webbTheme.spacingGrid
                        .spacing(1), // Right (less if close button is present)
                    webbTheme.spacingGrid.spacing(1), // Bottom
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title
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

                      const Spacer(), // Pushes the close button to the right

                      // Close Button
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
                          // Ensure the button meets minimum touch target size
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

  /// Helper to build the content widget with appropriate scrolling and padding.
  Widget _buildContent(BuildContext webbTheme) {
    // Determine the base padding for content area
    final EdgeInsets padding = EdgeInsets.all(webbTheme.spacingGrid.spacing(2));

    if (type == WebbUIModalType.scrollable) {
      // Content is scrollable
      return SingleChildScrollView(
        padding: padding,
        child: child,
      );
    }

    // For all other types, just wrap in padding
    return Padding(
      padding: padding,
      child: child,
    );
  }
}
