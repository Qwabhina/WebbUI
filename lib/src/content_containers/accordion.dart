import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
  final ValueChanged<bool>? onExpansionChanged;
  final bool disabled;

  const WebbUIAccordion({
    super.key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.disabled = false,
  });

  @override
  State<WebbUIAccordion> createState() => _WebbUIAccordionState();
}

class _WebbUIAccordionState extends State<WebbUIAccordion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heightAnimation;
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
      end: 0.5,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _toggleExpanded() {
    if (widget.disabled) return;
    
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
    
    return Semantics(
      button: true,
      expanded: _isExpanded,
      enabled: !widget.disabled,
      child: WebbUICard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(webbTheme.spacingGrid.baseSpacing),
                  topRight: Radius.circular(webbTheme.spacingGrid.baseSpacing),
                ),
                child: Container(
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
                            color: widget.disabled
                                ? webbTheme.interactionStates.disabledColor
                                : webbTheme.colorPalette.neutralDark,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _rotationAnimation,
                        child: Icon(
                          // Icons.expand_more,
                          FluentIcons.chevron_down_20_filled,
                          color: widget.disabled
                              ? webbTheme.interactionStates.disabledColor
                              : webbTheme.colorPalette.neutralDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            AnimatedBuilder(
              animation: _heightAnimation,
              builder: (context, child) {
                return ClipRect(
                  child: Align(
                    heightFactor: _heightAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  webbTheme.spacingGrid.spacing(2),
                  0,
                  webbTheme.spacingGrid.spacing(2),
                  webbTheme.spacingGrid.spacing(2),
                ),
                child: widget.content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
