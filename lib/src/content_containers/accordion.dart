import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'package:webb_ui/src/content_containers/card.dart';

/// A theme-compliant, expandable container component for hiding/showing content.
/// An accordion can contain multiple sections, each with a header that can be
/// clicked to expand or collapse the section.
class WebbUIAccordion extends StatefulWidget {
  final String title;
  final Widget content;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged; // Add callback

  const WebbUIAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
  });

  @override
  State<WebbUIAccordion> createState() => _WebbUIAccordionState();
}

class _WebbUIAccordionState extends State<WebbUIAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.5, // 180 degrees for expand_more -> expand_less
    ).animate(_controller);

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    
    return WebbUICard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Enhanced header with better interaction states
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(webbTheme.spacingGrid.baseSpacing),
                topRight: Radius.circular(webbTheme.spacingGrid.baseSpacing),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: webbTheme.spacingGrid.spacing(2),
                  vertical: webbTheme.spacingGrid.spacing(1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: webbTheme.typography.headlineMedium.copyWith(
                          color: webbTheme.colorPalette.neutralDark,
                        ),
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.expand_more, // Always start with expand_more
                        color: webbTheme.colorPalette.neutralDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: EdgeInsets.fromLTRB(
                      webbTheme.spacingGrid.spacing(2),
                      0,
                      webbTheme.spacingGrid.spacing(2),
                      webbTheme.spacingGrid.spacing(2),
                    ),
                    child: widget.content,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
