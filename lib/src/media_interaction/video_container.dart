import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIVideoContainer extends StatefulWidget {
  final String videoUrl;
  final double? aspectRatio;
  final bool autoPlay;

  const WebbUIVideoContainer({
    super.key,
    required this.videoUrl,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
  });

  @override
  State<WebbUIVideoContainer> createState() => _WebbUIVideoContainerState();
}

class _WebbUIVideoContainerState extends State<WebbUIVideoContainer> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        if (widget.autoPlay) _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final double containerWidth = isMobile ? width : width * 0.8;

    return AspectRatio(
      aspectRatio: widget.aspectRatio!,
      child: Container(
        width: containerWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: webbTheme.elevation.getShadows(1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: _controller.value.isInitialized
              ? VideoPlayer(_controller)
              : const Center(child: WebbUISpinner()),
        ),
      ),
    );
  }
}
