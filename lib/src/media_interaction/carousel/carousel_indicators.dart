import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'carousel_definitions.dart';

/// Renders a row of customizable indicators for a carousel.
class WebbUICarouselIndicators extends StatelessWidget {
  final int itemCount;
  final int currentIndex;
  final WebbUICarouselIndicatorStyle style;
  final ValueChanged<int> onIndicatorTap;

  const WebbUICarouselIndicators({
    super.key,
    required this.itemCount,
    required this.currentIndex,
    required this.style,
    required this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double minTargetSize = webbTheme.accessibility.minTouchTargetSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final bool isActive = currentIndex == index;

        // Wrap the indicator in a GestureDetector and SizedBox for a larger, accessible touch area.
        return GestureDetector(
          onTap: () => onIndicatorTap(index),
          child: SizedBox(
            width: minTargetSize,
            height: minTargetSize,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: style == WebbUICarouselIndicatorStyle.dots
                    ? (isActive ? 10.0 : 8.0)
                    : (isActive ? 24.0 : 8.0),
                height: 8.0,
                decoration: BoxDecoration(
                  color: isActive
                      ? webbTheme.colorPalette.primary
                      : webbTheme.colorPalette.neutralDark.withOpacity(0.4),
                  borderRadius: style == WebbUICarouselIndicatorStyle.bars
                      ? BorderRadius.circular(4)
                      : null,
                  shape: style == WebbUICarouselIndicatorStyle.dots
                      ? BoxShape.circle
                      : BoxShape.rectangle,
                  boxShadow:
                      isActive ? webbTheme.elevation.getShadows(1) : null,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
