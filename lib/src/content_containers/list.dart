import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'package:webb_ui/src/content_containers/card.dart'; 


/// A theme-compliant list container, typically used with [ListTile] or custom children.
///
/// It handles responsive vertical spacing and optional containment within a card.
class WebbUIList extends StatelessWidget {
  final List<Widget> items;
  
  /// If true, applies tighter vertical padding between items.
  final bool dense;
  
  /// If true, wraps the list in a [WebbUICard] for visual containment.
  final bool wrappedInCard;

  /// If true, displays a [Divider] between items.
  final bool showSeparator;

  const WebbUIList({
    super.key,
    required this.items,
    this.dense = false,
    this.wrappedInCard = false,
    this.showSeparator = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    
    // Determine vertical spacing based on dense state and mobile screen size
    final double verticalSpacing = webbTheme.spacingGrid.spacing(
      dense || !isMobile
          ? 1
          : 2, // 1x spacing for dense/desktop, 2x for standard/mobile
    );

    // List content, possibly wrapped in a card
    Widget listContent = ListView.builder(
      // These physics and shrinkWrap are crucial for embedding the list inside
      // other scrollable widgets (like SingleChildScrollView).
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final itemWidget = Padding(
          padding: EdgeInsets.symmetric(vertical: verticalSpacing),
          child: items[index],
        );

        if (showSeparator && index < items.length - 1) {
          // Add a Divider after every item except the last one
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              itemWidget,
              Divider(
                height: 1,
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                indent: webbTheme.spacingGrid.spacing(2),
                endIndent: webbTheme.spacingGrid.spacing(2),
              ),
            ],
          );
        }
        return itemWidget;
      },
    );

    // If wrappedInCard is true, apply the card wrapper
    if (wrappedInCard) {
      // WebbUICard already provides default padding, so we nest the list content directly.
      return WebbUICard(
        child: listContent,
      );
    }

    return listContent;
  }
}
