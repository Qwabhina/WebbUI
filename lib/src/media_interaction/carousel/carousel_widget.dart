import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'carousel_definitions.dart';
import 'carousel_indicators.dart';
import 'carousel_item.dart';

/// A highly customizable, responsive, and accessible carousel component.
class WebbUICarousel extends StatefulWidget {
  final List<Widget> items;
  final List<String>? captions;
  final List<CaptionConfig>? captionConfigs;
  final ValueChanged<int>? onItemTap;
  final double? height;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool infiniteScroll;
  final bool pauseOnInteraction;
  final Curve transitionCurve;
  final Duration transitionDuration;
  final bool showControls;
  final WebbUICarouselIndicatorStyle indicatorStyle;
  final WebbUICarouselIndicatorPosition indicatorPosition;

  const WebbUICarousel({
    super.key,
    required this.items,
    this.captions,
    this.captionConfigs,
    this.onItemTap,
    this.height,
    this.autoPlay = true,
    this.autoPlayInterval = const Duration(seconds: 4),
    this.infiniteScroll = true,
    this.pauseOnInteraction = true,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration = const Duration(milliseconds: 500),
    this.showControls = true,
    this.indicatorStyle = WebbUICarouselIndicatorStyle.dots,
    this.indicatorPosition = WebbUICarouselIndicatorPosition.bottom,
  })  : assert(items.length > 0, 'Carousel must have at least one item.'),
        assert(captions == null || captions.length == items.length,
            'Captions length must match items length'),
        assert(captionConfigs == null || captionConfigs.length == items.length,
            'CaptionConfigs length must match items length');

  @override
  State<WebbUICarousel> createState() => _WebbUICarouselState();
}

class _WebbUICarouselState extends State<WebbUICarousel> {
  late PageController _pageController;
  late int _currentPage;
  Timer? _timer;
  bool _isInteracting = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.infiniteScroll ? widget.items.length * 100 : 0;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: MediaQuery.of(context).size.width < 600 ? 0.85 : 0.7,
    );
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    if (widget.items.length <= 1) return;
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!_isInteracting && !_isHovered && _pageController.hasClients) {
        _nextPage();
      }
    });
  }

  void _handleInteractionStart() {
    if (widget.pauseOnInteraction) {
      setState(() => _isInteracting = true);
      _timer?.cancel();
    }
  }

  void _handleInteractionEnd() {
    if (widget.pauseOnInteraction) {
      setState(() => _isInteracting = false);
      _startAutoPlay();
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: widget.transitionDuration,
      curve: widget.transitionCurve,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: widget.transitionDuration,
      curve: widget.transitionCurve,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onIndicatorTapped(int index) {
    if (!_pageController.hasClients) return;
    final int targetPage =
        (_currentPage - (_currentPage % widget.items.length)) + index;
    _pageController.animateToPage(
      targetPage,
      duration: widget.transitionDuration,
      curve: widget.transitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double carouselHeight = widget.height ??
        (isMobile ? MediaQuery.of(context).size.height * 0.35 : 400);

    final int realIndex = _currentPage % widget.items.length;

    return SizedBox(
      height: carouselHeight,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.pauseOnInteraction) {
            setState(() => _isHovered = true);
            _timer?.cancel();
          }
        },
        onExit: (_) {
          if (widget.pauseOnInteraction) {
            setState(() => _isHovered = false);
            _startAutoPlay();
          }
        },
        child: GestureDetector(
          onTapDown: (_) => _handleInteractionStart(),
          onTapUp: (_) => _handleInteractionEnd(),
          onHorizontalDragStart: (_) => _handleInteractionStart(),
          onHorizontalDragEnd: (_) => _handleInteractionEnd(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.infiniteScroll ? null : widget.items.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final int itemIndex = index % widget.items.length;
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double value = 1.0;
                      if (_pageController.position.haveDimensions) {
                        value = (_pageController.page ?? 0) - index;
                        value = (1 - (value.abs() * 0.2)).clamp(0.8, 1.0);
                      }
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: CarouselItem(
                      onTap: widget.onItemTap != null
                          ? () => widget.onItemTap!(itemIndex)
                          : null,
                      caption: widget.captions?[itemIndex],
                      captionConfig: widget.captionConfigs?[itemIndex] ??
                          const CaptionConfig(),
                      isMobile: isMobile,
                      child: widget.items[itemIndex],
                    ),
                  );
                },
              ),
              if (widget.items.length > 1) ...[
                _buildIndicators(webbTheme, realIndex),
                if (widget.showControls) ..._buildControls(webbTheme),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators(BuildContext context, int realIndex) {
    final Alignment alignment =
        widget.indicatorPosition == WebbUICarouselIndicatorPosition.top
            ? Alignment.topCenter
            : Alignment.bottomCenter;
    final double padding = context.spacingGrid.spacing(2);

    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: WebbUICarouselIndicators(
            itemCount: widget.items.length,
            currentIndex: realIndex,
            style: widget.indicatorStyle,
            onIndicatorTap: _onIndicatorTapped,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildControls(BuildContext context) {
    return [
      Positioned(
        left: 10.0,
        child: _ControlButton(
          icon: Icons.chevron_left,
          onPressed: _previousPage,
          context: context,
        ),
      ),
      Positioned(
        right: 10.0,
        child: _ControlButton(
          icon: Icons.chevron_right,
          onPressed: _nextPage,
          context: context,
        ),
      ),
    ];
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final BuildContext context;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    final webbTheme = context;
    return IconButton(
      style: IconButton.styleFrom(
        backgroundColor: webbTheme.colorPalette.neutralLight.withOpacity(0.6),
        shape: const CircleBorder(),
        padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
      ),
      icon: Icon(icon,
          color: webbTheme.colorPalette.primary,
          size: webbTheme.iconTheme.largeSize),
      onPressed: onPressed,
      tooltip: icon == Icons.chevron_left ? 'Previous' : 'Next',
    );
  }
}
