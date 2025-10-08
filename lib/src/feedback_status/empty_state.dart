import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A component for displaying a centralized message, illustration, and optional action
/// when a list or section contains no data.
class WebbUIEmptyState extends StatelessWidget {
  /// The main message content (required).
  final String message; 
  
  /// An optional, bold title displayed above the message.
  final String? title;

  /// An optional illustration or icon to visually represent the empty state.
  final Widget? illustration;
  
  /// An optional action button (e.g., "Add First Item").
  final Widget? action;

  const WebbUIEmptyState({
    super.key,
    required this.message,
    this.title, // New optional title
    this.illustration,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // Set max width for the content to prevent overstretching on large screens
    const double maxWidth = 400.0; 

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.all(webbTheme.spacingGrid
            .spacing(2)), // General padding for containment
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize
              .min, // Ensures column only takes required vertical space
          children: [
            // 1. Illustration
            if (illustration != null) illustration!,

            // Spacing after illustration
            if (illustration != null)
              SizedBox(height: webbTheme.spacingGrid.spacing(4)),

            // 2. Title (Optional, large/bold)
            if (title != null)
              Padding(
                padding:
                    EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
                child: Text(
                  title!,
                  style: webbTheme.typography.headlineMedium
                      .copyWith(color: webbTheme.colorPalette.neutralDark),
                  textAlign: TextAlign.center,
                ),
              ),

            // 3. Message (Required, supporting text)
            Text(
              message,
              style: webbTheme.typography.bodyLarge.copyWith(
                  color: webbTheme.colorPalette.neutralDark.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            
            // 4. Action
            if (action != null)
              Padding(
                padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(3)),
                child: action!,
              ),
          ],
        ),
      ),
    );
  }
}
