import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Defines the visual presentation type of the card.
enum WebbUICardType {
  standard, // Simple container for content
  media, // Contains a prominent image/media area
  action, // Clickable card, typically with title and actions
  profile // Focuses on user/entity avatar and metadata
}

/// A theme-compliant container for grouping related content and displaying hierarchy.
class WebbUICard extends StatelessWidget {
  /// The primary content area of the card.
  final Widget child;
  
  /// The specific visual layout of the card (standard, media, action, profile).
  final WebbUICardType type;
  
  /// Custom internal padding for the card's content.
  final EdgeInsets? padding;
  
  /// If true, applies a themed shadow (Elevation Level 1).
  final bool elevated;

  // Properties specific to card types:

  /// Primary title for the card (used in action/profile types).
  final String? title;

  /// Secondary text (used in profile cards).
  final String? subtitle;

  /// The widget displayed at the top of a media card (e.g., Image).
  final Widget? media;

  /// Buttons or interactions displayed in a row (used in action cards).
  final List<Widget>? actions;

  /// Avatar or icon for the profile card (used in profile cards).
  final Widget? avatar;

  /// The callback when the card is tapped (REQUIRED for WebbUICardType.action).
  final VoidCallback? onCardTap;

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
    this.onCardTap, // Required for action type
  });

  /// Builds the specific layout for non-action card types.
  Widget _buildContent(BuildContext webbTheme) {
    // final bool isMobile = MediaQuery.of(webbTheme).size.width < 600;
    
    // Default Padding based on theme spacing
    final defaultPadding =
        padding ?? EdgeInsets.all(webbTheme.spacingGrid.spacing(2));

    switch (type) {
      case WebbUICardType.standard:
        return Padding(
          padding: defaultPadding,
          child: child,
        );

      case WebbUICardType.media:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (media != null)
              ClipRRect(
                // Clips the media to the top rounded corners of the card
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                child: media!,
              ),
            Padding(
              padding: defaultPadding,
              child: child,
            ),
          ],
        );

      case WebbUICardType.profile:
        return Padding(
          padding: defaultPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (avatar != null)
                Padding(
                  padding:
                      EdgeInsets.only(right: webbTheme.spacingGrid.spacing(2)),
                  child: avatar!,
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: webbTheme.typography.headlineMedium.copyWith(
                          color: webbTheme.colorPalette.neutralDark,
                        ),
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: webbTheme.typography.bodyMedium.copyWith(
                          color: webbTheme.colorPalette.neutralDark
                              .withOpacity(0.7),
                        ),
                      ),
                    // Main content below metadata
                    Padding(
                      padding: EdgeInsets.only(
                        top: (title != null || subtitle != null)
                            ? webbTheme.spacingGrid.spacing(1)
                            : 0,
                      ),
                      child: child,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
        
      case WebbUICardType.action:
        // Action card content is handled by the InkWell wrapper below.
        return Padding(
          padding: defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(
                  title!,
                  style: webbTheme.typography.headlineMedium.copyWith(
                    color: webbTheme.colorPalette.neutralDark,
                  ),
                ),
              child,
              if (actions != null && actions!.isNotEmpty)
                Padding(
                  padding:
                      EdgeInsets.only(top: webbTheme.spacingGrid.spacing(2)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    // Base decoration for non-interactive cards
    final decoration = BoxDecoration(
      color: webbTheme.colorPalette.neutralLight,
      borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
      boxShadow: elevated ? webbTheme.elevation.getShadows(1) : null,
    );

    // Check if the card is an interactive action card
    final bool isActionCard = type == WebbUICardType.action;

    // Use Material/InkWell for interactive cards to get themed splash/hover effects
    if (isActionCard) {
      // Must ensure onCardTap is provided for an action card
      assert(onCardTap != null,
          'WebbUICardType.action requires an onCardTap callback.');

      // Use Material to handle elevation and InkWell for tap/hover
      return Material(
        color: webbTheme.colorPalette.neutralLight,
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
        // Use elevation logic for the Material widget
        elevation: elevated
            ? webbTheme.elevation.getShadows(1).first.blurRadius / 2
            : 0,
        shadowColor: elevated
            ? webbTheme.elevation.getShadows(1).first.color
            : Colors.transparent,

        child: InkWell(
          onTap: onCardTap,
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          hoverColor: webbTheme.interactionStates.hoverOverlay,
          splashColor: webbTheme.interactionStates.pressedOverlay,
          child: Container(
            constraints: const BoxConstraints(maxWidth: double.infinity),
            child: _buildContent(context),
          ),
        ),
      );
    }

    // Use a standard Container for non-interactive card types (standard, media, profile)
    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      decoration: decoration,
      child: _buildContent(context),
    );
  }
}
