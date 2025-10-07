import 'package:flutter/material.dart';
import 'package:webb_ui/src/feedback_status/feedback_status.dart';
import 'package:webb_ui/src/theme.dart';
import 'video_player_with_controls.dart'; // Internal video player widget

/// Defines the type of media to be displayed in the container.
enum MediaType { image, video }

/// A versatile, theme-aware container for displaying images and videos
/// with consistent styling and controls.
class WebbUIMediaContainer extends StatelessWidget {
  /// The URL of the image or video to display.
  final String mediaUrl;

  /// The type of media to render.
  final MediaType mediaType;

  /// The desired aspect ratio of the media container. Defaults to 16/9.
  final double aspectRatio;

  // --- Image-specific properties ---
  /// How the image should be inscribed into the container.
  final BoxFit fit;

  // --- Video-specific properties ---
  /// Whether the video should start playing as soon as it's ready.
  final bool autoPlay;

  /// Whether the video should start again from the beginning once it ends.
  final bool loop;

  /// Whether the video's audio should be muted by default.
  final bool mute;

  const WebbUIMediaContainer({
    super.key,
    required this.mediaUrl,
    required this.mediaType,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.cover,
    this.autoPlay = false,
    this.loop = false,
    this.mute = true, // Muted by default is a common practice for autoplay
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          boxShadow: webbTheme.elevation.getShadows(1),
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          child: _buildMediaContent(context),
        ),
      ),
    );
  }

  Widget _buildMediaContent(BuildContext context) {
    switch (mediaType) {
      case MediaType.image:
        return _buildImage(context);
      case MediaType.video:
        return VideoPlayerWithControls(
          key: ValueKey(
              mediaUrl), // Ensures controller re-initialization on URL change
          videoUrl: mediaUrl,
          autoPlay: autoPlay,
          loop: loop,
          mute: mute,
        );
    }
  }

  Widget _buildImage(BuildContext context) {
    final webbTheme = context;
    const spinner = WebbUISpinner();

    return Image.network(
      mediaUrl,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: spinner);
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.broken_image_outlined,
            color: webbTheme.colorPalette.error,
            size: webbTheme.iconTheme.largeSize,
          ),
        );
      },
    );
  }
}
