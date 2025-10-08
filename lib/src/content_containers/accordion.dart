import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'package:webb_ui/src/content_containers/card.dart';

/// A theme-compliant, expandable container component for hiding/showing content.
class WebbUIAccordion extends StatefulWidget {
  final String title;
  final Widget content;

  const WebbUIAccordion({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<WebbUIAccordion> createState() => _WebbUIAccordionState();
}

class _WebbUIAccordionState extends State<WebbUIAccordion> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    
    return WebbUICard(
      // AnimatedSize ensures a smooth, non-jerky height transition when the content changes size
      child: AnimatedSize(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section that acts as the toggle button
            ListTile(
              onTap: _toggleExpanded,

              // Title text styling uses a headline style for prominence
              title: Text(
                widget.title,
                style: webbTheme.typography.headlineMedium.copyWith(
                  color: webbTheme.colorPalette.neutralDark,
                ),
              ),

              // Trailing icon clearly indicates the current state
              trailing: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: webbTheme.colorPalette.neutralDark,
              ),

              // Use theme spacing for padding
              contentPadding: EdgeInsets.symmetric(
                horizontal: webbTheme.spacingGrid.spacing(2),
                vertical: webbTheme.spacingGrid.spacing(1),
              ),
            ),
            
            // Content section, built only when expanded
            if (_isExpanded)
              Padding(
                // Uses custom padding: full horizontal, no top (as it follows the list tile),
                // and full bottom spacing.
                padding: EdgeInsets.fromLTRB(
                  webbTheme.spacingGrid.spacing(2),
                  0,
                  webbTheme.spacingGrid.spacing(2),
                  webbTheme.spacingGrid.spacing(2),
                ),
                child: widget.content,
              ),
          ],
        ),
      ),
    );
  }
}
