import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'carousel_definitions.dart';

/// An internal widget that renders a single carousel item with its caption.
class CarouselItem extends StatelessWidget {
  final Widget child;
  final String? caption;
  final CaptionConfig captionConfig;
  final VoidCallback? onTap;
  final bool isMobile;

  const CarouselItem({
    super.key,
    required this.child,
    this.caption,
    required this.captionConfig,
    this.onTap,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.symmetric(horizontal: webbTheme.spacingGrid.spacing(1)),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The main content widget
              child,

              // Optional Caption Overlay
              if (caption != null && caption!.isNotEmpty)
                _buildCaption(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaption(BuildContext context) {
    final webbTheme = context;
    final config = captionConfig;

    return Positioned.fill(
      child: Align(
        alignment: config.alignment,
        child: Container(
          // Constrain the width to prevent overflow, especially on mobile.
          constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * (isMobile ? 0.7 : 0.5)),
          padding: config.padding ??
              EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
          margin: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
          decoration: BoxDecoration(
            color: config.backgroundColor?.withOpacity(config.opacity ?? 0.7) ??
                webbTheme.colorPalette.neutralDark.withOpacity(0.7),
            borderRadius:
                BorderRadius.circular(webbTheme.spacingGrid.baseSpacing / 2),
          ),
          child: Text(
            caption!,
            style: config.textStyle ??
                webbTheme.typography.bodyMedium.copyWith(color: Colors.white),
            textAlign: TextAlign.center,
            maxLines: isMobile ? 2 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
