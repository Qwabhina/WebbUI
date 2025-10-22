import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Data model for a single item in the side navigation.
class WebbUISideNavItem {
  final IconData icon;
  final String label;
  final String? semanticLabel;
  final int? badgeCount;
  final Widget? activeIcon;

  const WebbUISideNavItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
    this.badgeCount,
    this.activeIcon,
  });
}

/// A responsive and collapsible side navigation bar.
class WebbUISideNav extends StatefulWidget {
  final Widget? header;
  final List<WebbUISideNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final bool isCollapsible;
  final bool initiallyCollapsed;
  final double expandedWidth;
  final double collapsedWidth;

  const WebbUISideNav({
    super.key,
    this.header,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
    this.isCollapsible = true,
    this.initiallyCollapsed = false,
    this.expandedWidth = 250.0,
    this.collapsedWidth = 72.0,
  }) : assert(selectedIndex >= 0 && selectedIndex < items.length);

  @override
  State<WebbUISideNav> createState() => _WebbUISideNavState();
}

class _WebbUISideNavState extends State<WebbUISideNav>
    with SingleTickerProviderStateMixin {
  late bool _isCollapsed;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set initial position
    if (_isCollapsed) {
      _animationController.value = 1.0;
    }

    // Animates between expanded and collapsed widths
    _widthAnimation = Tween<double>(
      begin: widget.expandedWidth,
      end: widget.collapsedWidth,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _handleItemTap(int index) {
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    // Mobile Handling (Drawer)
    if (isMobile) {
      return Drawer(
        child: _buildContent(webbTheme, expanded: true),
      );
    }

    // Desktop/Tablet Handling (Animated Sidebar)
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: webbTheme.colorPalette.surface,
            border: Border(
              right: BorderSide(
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
                width: 1.0,
              ),
            ),
            boxShadow: webbTheme.elevation.getShadows(1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              if (widget.header != null)
                Padding(
                  padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                  child: widget.header!,
                ),
              
              // Navigation Items
              Expanded(
                child: _buildContent(webbTheme, expanded: !_isCollapsed),
              ),

              // Collapse Toggle
              if (widget.isCollapsible) _buildToggleFooter(webbTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToggleFooter(BuildContext webbTheme) {
    return Column(
      children: [
        Divider(
          height: 1,
          color: webbTheme.colorPalette.neutralDark.withOpacity(0.1),
        ),
        Padding(
          padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1)),
          child: IconButton(
            tooltip: _isCollapsed ? 'Expand navigation' : 'Collapse navigation',
            icon: Icon(
              _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: webbTheme.colorPalette.neutralDark,
              size: webbTheme.iconTheme.mediumSize,
            ),
            onPressed: _toggleCollapse,
          ),
        ),
      ],
    );
  }

  /// Builds the main list of navigation items.
  Widget _buildContent(BuildContext webbTheme, {required bool expanded}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _WebbUISideNavItem(
          item: widget.items[index],
          isSelected: index == widget.selectedIndex,
          expanded: expanded,
          onTap: () => _handleItemTap(index),
          webbTheme: webbTheme,
        );
      },
    );
  }
}

/// Private widget to render a single navigation item.
class _WebbUISideNavItem extends StatelessWidget {
  final WebbUISideNavItem item;
  final bool isSelected;
  final bool expanded;
  final VoidCallback onTap;
  final BuildContext webbTheme;

  const _WebbUISideNavItem({
    required this.item,
    required this.isSelected,
    required this.expanded,
    required this.onTap,
    required this.webbTheme,
  });

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        isSelected ? webbTheme.colorPalette.primary : Colors.transparent;

    final Color contentColor = isSelected
        ? webbTheme.colorPalette.onPrimary
        : webbTheme.colorPalette.neutralDark;

    return Semantics(
      button: true,
      selected: isSelected,
      label: item.semanticLabel ?? item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: webbTheme.interactionStates.hoverOverlay,
          splashColor: webbTheme.interactionStates.pressedOverlay,
          child: Container(
            height: webbTheme.accessibility.minTouchTargetSize,
            margin: EdgeInsets.symmetric(
              vertical: webbTheme.spacingGrid.spacing(0.25),
              horizontal: webbTheme.spacingGrid.spacing(1),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: webbTheme.spacingGrid.spacing(1.5),
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(
                webbTheme.spacingGrid.baseSpacing,
              ),
            ),
            child: Row(
              children: [
                // Icon
                _buildIcon(contentColor),
                
                // Label (only when expanded)
                if (expanded) ...[
                  SizedBox(width: webbTheme.spacingGrid.spacing(1.5)),
                  Expanded(
                    child: Text(
                      item.label,
                      style: webbTheme.typography.labelLarge.copyWith(
                        color: contentColor,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                
                // Badge
                if (item.badgeCount != null && item.badgeCount! > 0)
                  _buildBadge(webbTheme, contentColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (isSelected && item.activeIcon != null) {
      return item.activeIcon!;
    }

    return Icon(
      item.icon,
      color: color,
      size: webbTheme.iconTheme.mediumSize,
    );
  }

  Widget _buildBadge(BuildContext webbTheme, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: webbTheme.spacingGrid.spacing(0.75),
        vertical: webbTheme.spacingGrid.spacing(0.25),
      ),
      decoration: BoxDecoration(
        color:
            isSelected ? color.withOpacity(0.2) : webbTheme.colorPalette.error,
        borderRadius:
            BorderRadius.circular(webbTheme.spacingGrid.baseSpacing * 2),
      ),
      constraints: BoxConstraints(
        minWidth: webbTheme.spacingGrid.spacing(2),
      ),
      child: Text(
        item.badgeCount!.toString(),
        style: webbTheme.typography.labelSmall.copyWith(
          color: isSelected ? color : webbTheme.colorPalette.onPrimary,
          fontSize: (webbTheme.typography.labelSmall.fontSize ?? 12) * 0.8,
          height: 1.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
