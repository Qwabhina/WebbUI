import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIImageContainer extends StatelessWidget {
  final String imageUrl;
  final double? aspectRatio;
  final BoxFit fit;

  const WebbUIImageContainer({
    super.key,
    required this.imageUrl,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final double containerWidth =
        isMobile ? width : width * 0.8; // Responsive width

    return AspectRatio(
      aspectRatio: aspectRatio!,
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: webbTheme.elevation.getShadows(1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: WebbUISpinner());
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(Icons.error, color: webbTheme.colorPalette.error),
              );
            },
          ),
        ),
      ),
    );
  }
}
