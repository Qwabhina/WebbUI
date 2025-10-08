import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A component that provides a placeholder (shimmering) visualization
/// for content that is currently loading.
class WebbUISkeleton extends StatefulWidget {
  /// The height of the placeholder area.
  final double height;

  /// The width of the placeholder area.
  final double width;

  /// Optional border radius. Defaults to 4.
  final BorderRadius? borderRadius;

  const WebbUISkeleton({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius,
  });

  @override
  State<WebbUISkeleton> createState() => _WebbUISkeletonState();
}

class _WebbUISkeletonState extends State<WebbUISkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation cycles every 1.5 seconds.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // Use semi-transparent dark colors for the shimmer effect based on the theme
    final baseColor = webbTheme.colorPalette.neutralDark.withOpacity(0.1);
    final highlightColor = webbTheme.colorPalette.neutralDark.withOpacity(0.05);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate the gradient position, moving from -1.0 (start) to 3.0 (end of two cycles)
        final double gradientPosition = _controller.value * 2 - 1;

        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4),
            // Apply the shimmering linear gradient
            gradient: LinearGradient(
              begin: Alignment(-gradientPosition, -1),
              end: Alignment(-gradientPosition + 2, 1),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              // Stops define where the colors sit in the gradient, creating the visible 'swipe'
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}
