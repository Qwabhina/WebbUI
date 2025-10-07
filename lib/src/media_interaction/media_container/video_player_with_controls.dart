import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webb_ui/src/theme.dart';

/// An internal stateful widget that manages video playback and UI controls.
class VideoPlayerWithControls extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool loop;
  final bool mute;

  const VideoPlayerWithControls({
    super.key,
    required this.videoUrl,
    required this.autoPlay,
    required this.loop,
    required this.mute,
  });

  @override
  State<VideoPlayerWithControls> createState() =>
      VideoPlayerWithControlsState();
}

class VideoPlayerWithControlsState extends State<VideoPlayerWithControls> {
  late VideoPlayerController _controller;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized.
        setState(() {});
        _controller.setLooping(widget.loop);
        if (widget.mute) {
          _controller.setVolume(0);
        }
        if (widget.autoPlay) {
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      if (_controller.value.volume == 0) {
        _controller.setVolume(1.0);
      } else {
        _controller.setVolume(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // final spinner = WebbUISpinner();
    final spinner = CircularProgressIndicator(
      color: webbTheme.colorPalette.primary,
    );

    if (!_controller.value.isInitialized) {
      return Center(child: spinner);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _showControls = true),
      onExit: (_) => setState(() => _showControls = false),
      child: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: _buildControlsOverlay(webbTheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay(BuildContext webbTheme) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top controls (e.g., title, can be added here)
          const SizedBox.shrink(),

          // Center play/pause button
          _buildCenterPlayPause(webbTheme),

          // Bottom controls (progress bar, mute)
          _buildBottomBar(webbTheme),
        ],
      ),
    );
  }

  Widget _buildCenterPlayPause(BuildContext webbTheme) {
    return IconButton(
      icon: Icon(
        _controller.value.isPlaying
            ? Icons.pause_circle_filled
            : Icons.play_circle_filled,
        color: webbTheme.colorPalette.neutralLight,
        size: webbTheme.iconTheme.largeSize * 1.5,
      ),
      onPressed: _togglePlayPause,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext webbTheme) {
    return Padding(
      padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _controller.value.volume == 0
                  ? Icons.volume_off
                  : Icons.volume_up,
              color: webbTheme.colorPalette.neutralLight,
              size: webbTheme.iconTheme.mediumSize,
            ),
            onPressed: _toggleMute,
          ),
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: EdgeInsets.symmetric(
                horizontal: webbTheme.spacingGrid.spacing(1),
              ),
              colors: VideoProgressColors(
                playedColor: webbTheme.colorPalette.primary,
                bufferedColor:
                    webbTheme.colorPalette.neutralLight.withOpacity(0.5),
                backgroundColor:
                    webbTheme.colorPalette.neutralDark.withOpacity(0.5),
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (context, VideoPlayerValue value, child) {
              return Text(
                '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                style: webbTheme.typography.labelMedium
                    .copyWith(color: webbTheme.colorPalette.neutralLight),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
