import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum WebbUICarouselIndicatorStyle { dots, bars }

enum WebbUICarouselIndicatorPosition { bottom, top }

class CaptionConfig {
  final AlignmentGeometry alignment;
  final Color? backgroundColor;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final double? opacity;

  const CaptionConfig({
    this.alignment = Alignment.bottomCenter,
    this.backgroundColor,
    this.textStyle,
    this.padding,
    this.opacity,
  });
}

class WebbUICarousel extends StatefulWidget {
  final List<Widget> items;
  final List<String>? captions;
  final List<CaptionConfig>?
      captionConfigs; // Custom caption configurations per item
  final ValueChanged<int>? onItemTap; // Callback for item clicks
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
    this.autoPlayInterval = const Duration(seconds: 3),
    this.infiniteScroll = true,
    this.pauseOnInteraction = true,
    this.transitionCurve = Curves.easeInOut,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.showControls = true,
    this.indicatorStyle = WebbUICarouselIndicatorStyle.dots,
    this.indicatorPosition = WebbUICarouselIndicatorPosition.bottom,
  })  : assert(captions == null || captions.length == items.length,
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
    _currentPage = widget.infiniteScroll ? widget.items.length : 0;
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: MediaQuery.of(context).size.width < 600 ? 0.8 : 0.6,
    );
    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (!_isInteracting && !_isHovered) {
        _nextPage();
      }
    });
  }

  void _pauseAutoPlay() {
    _timer?.cancel();
  }

  void _resumeAutoPlay() {
    if (widget.autoPlay) {
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
    if (widget.infiniteScroll) {
      if (index == 0) {
        _pageController.jumpToPage(widget.items.length * 2);
      } else if (index == widget.items.length * 3 - 1) {
        _pageController.jumpToPage(widget.items.length);
      }
    }
  }

  int _getRealIndex() {
    return _currentPage % widget.items.length;
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double screenHeight = MediaQuery.of(context).size.height;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    final double carouselHeight =
        widget.height ?? (isMobile ? screenHeight * 0.3 : screenHeight * 0.5);

    final List<Widget> extendedItems = widget.infiniteScroll
        ? [...widget.items, ...widget.items, ...widget.items]
        : widget.items;
    final List<String>? extendedCaptions =
        widget.captions != null && widget.infiniteScroll
            ? [...widget.captions!, ...widget.captions!, ...widget.captions!]
            : widget.captions;
    final List<CaptionConfig>? extendedCaptionConfigs =
        widget.captionConfigs != null && widget.infiniteScroll
            ? [
                ...widget.captionConfigs!,
                ...widget.captionConfigs!,
                ...widget.captionConfigs!
              ]
            : widget.captionConfigs;

    return SizedBox(
      height: carouselHeight,
      child: MouseRegion(
        onEnter: (_) {
          if (widget.pauseOnInteraction) {
            setState(() => _isHovered = true);
            _pauseAutoPlay();
          }
        },
        onExit: (_) {
          if (widget.pauseOnInteraction) {
            setState(() => _isHovered = false);
            _resumeAutoPlay();
          }
        },
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.pauseOnInteraction) {
              setState(() => _isInteracting = true);
              _pauseAutoPlay();
            }
          },
          onTapUp: (_) {
            if (widget.pauseOnInteraction) {
              setState(() => _isInteracting = false);
              _resumeAutoPlay();
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: extendedItems.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final realIndex = index % widget.items.length;
                  final captionConfig = extendedCaptionConfigs != null
                      ? extendedCaptionConfigs[realIndex]
                      : const CaptionConfig();
                  return GestureDetector(
                    onTap: widget.onItemTap != null
                        ? () => widget.onItemTap!(realIndex)
                        : null,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: webbTheme.spacingGrid.spacing(1)),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          extendedItems[index],
                          if (extendedCaptions != null &&
                              extendedCaptions[realIndex].isNotEmpty)
                            Positioned(
                              left: captionConfig.padding?.left ?? 10.0,
                              right: captionConfig.padding?.right ?? 10.0,
                              top:
                                  captionConfig.alignment == Alignment.topCenter
                                      ? captionConfig.padding?.top ?? 10.0
                                      : null,
                              bottom: captionConfig.alignment ==
                                      Alignment.bottomCenter
                                  ? captionConfig.padding?.bottom ?? 10.0
                                  : null,
                              child: Align(
                                alignment: captionConfig.alignment,
                                child: Container(
                                  padding: captionConfig.padding ??
                                      EdgeInsets.all(
                                          webbTheme.spacingGrid.spacing(1)),
                                  decoration: BoxDecoration(
                                    color: captionConfig.backgroundColor
                                            ?.withOpacity(
                                                captionConfig.opacity ?? 0.7) ??
                                        webbTheme.colorPalette.neutralDark
                                            .withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    extendedCaptions[realIndex],
                                    style: captionConfig.textStyle ??
                                        webbTheme.typography.bodyMedium
                                            .copyWith(color: Colors.white),
                                    textAlign: TextAlign.center,
                                    maxLines: isMobile ? 2 : 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (widget.indicatorPosition ==
                  WebbUICarouselIndicatorPosition.bottom)
                Positioned(
                  bottom: (widget.captions != null &&
                          widget.captionConfigs != null
                      ? (widget.captionConfigs![_getRealIndex()].alignment ==
                              Alignment.bottomCenter
                          ? 30.0
                          : 10.0)
                      : 10.0),
                  left: 0.0,
                  right: 0.0,
                  child: _buildIndicators(webbTheme),
                ),
              if (widget.indicatorPosition ==
                  WebbUICarouselIndicatorPosition.top)
                Positioned(
                  top: 10.0,
                  left: 0.0,
                  right: 0.0,
                  child: _buildIndicators(webbTheme),
                ),
              if (widget.showControls)
                Positioned(
                  left: 10.0,
                  child: IconButton(
                    icon: Icon(Icons.chevron_left,
                        color: webbTheme.colorPalette.primary),
                    onPressed: _previousPage,
                  ),
                ),
              if (widget.showControls)
                Positioned(
                  right: 10.0,
                  child: IconButton(
                    icon: Icon(Icons.chevron_right,
                        color: webbTheme.colorPalette.primary),
                    onPressed: _nextPage,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators(BuildContext context) {
    final webbTheme = context;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.items.length, (index) {
        final bool isActive = _getRealIndex() == index;
        return Container(
          width: widget.indicatorStyle == WebbUICarouselIndicatorStyle.dots
              ? 8.0
              : (isActive ? 20.0 : 8.0),
          height: 8.0,
          margin: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(1) / 2),
          decoration: BoxDecoration(
            shape: widget.indicatorStyle == WebbUICarouselIndicatorStyle.dots
                ? BoxShape.circle
                : BoxShape.rectangle,
            borderRadius:
                widget.indicatorStyle == WebbUICarouselIndicatorStyle.bars
                    ? BorderRadius.circular(4)
                    : null,
            color: isActive
                ? webbTheme.colorPalette.primary
                : webbTheme.colorPalette.neutralDark.withOpacity(0.4),
          ),
        );
      }),
    );
  }
}
