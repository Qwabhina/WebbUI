import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// Data model for a single item in the side navigation.
class WebbUISideNavItem {
  final IconData icon;
  final String label;
  final int? badgeCount;
  final VoidCallback onTap;
  final bool isSelected;

  const WebbUISideNavItem({
    required this.icon,
    required this.label,
    this.badgeCount,
    required this.onTap,
    this.isSelected = false,
  });
}

/// A responsive and collapsible side navigation bar.
class WebbUISideNav extends StatefulWidget {
  final Widget? header; // e.g., Logo
  final List<WebbUISideNavItem> items;
  final bool isCollapsible;
  final bool initiallyCollapsed;

  const WebbUISideNav({
    super.key,
    this.header,
    required this.items,
    this.isCollapsible = true,
    this.initiallyCollapsed = false,
  });

  @override
  State<WebbUISideNav> createState() => _WebbUISideNavState();
}

class _WebbUISideNavState extends State<WebbUISideNav>
    with SingleTickerProviderStateMixin {
  late bool _isCollapsed;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  // The expanded width (250px) and collapsed width (64px)
  static const double _expandedWidth = 250.0;
  static const double _collapsedWidth = 64.0;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Set initial position based on initial state
    if (_isCollapsed) {
      _animationController.value = 1.0;
    }

    // Animates between expanded and collapsed widths
    _widthAnimation = Tween<double>(
      begin: _expandedWidth,
      end: _collapsedWidth,
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

  @override
  Widget build(BuildContext context) {
    // We only resolve the theme here to check screen width/responsiveness.
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    // --- Mobile Handling (Drawer) ---
    if (isMobile) {
      // Use a Drawer for mobile responsiveness. Always expanded in drawer context.
      return Drawer(
        child: _buildContent(expanded: true),
      );
    }

    // --- Desktop/Tablet Handling (Animated Sidebar) ---
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        
        return Container(
          width: _widthAnimation.value,
          decoration: BoxDecoration(
            color: context.colorPalette.neutralLight,
            border: Border(
              right: BorderSide(
                color: context.colorPalette.neutralDark.withOpacity(0.1),
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header (Logo/Title)
              if (widget.header != null)
                Padding(
                  padding: EdgeInsets.all(context.spacingGrid.spacing(2)),
                  child: widget.header!,
                ),
              
              // 2. Navigation Items (List)
              Expanded(
                child: _buildContent(expanded: !_isCollapsed),
              ),

              // 3. Collapse Toggle Button
              if (widget.isCollapsible) _buildToggleFooter(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the collapsible footer containing the toggle button.
  Widget _buildToggleFooter() {
    return Column(
      children: [
        const Divider(height: 1, thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacingGrid.spacing(1),
            vertical: context.spacingGrid.spacing(0.5),
          ),
          child: IconButton(
            tooltip: _isCollapsed ? 'Expand' : 'Collapse',
            icon: Icon(
              _isCollapsed ? Icons.chevron_right : Icons.chevron_left,
              color: context.colorPalette.neutralDark,
            ),
            onPressed: _toggleCollapse,
          ),
        ),
      ],
    );
  }

  /// Builds the main list of navigation items.
  Widget _buildContent({required bool expanded}) {
    // The theme can be accessed by the individual list items' build methods
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _WebbUISideNavItem(
          item: widget.items[index],
          expanded: expanded,
        );
      },
    );
  }
}

/// Private widget to render a single navigation item.
class _WebbUISideNavItem extends StatelessWidget {
  const _WebbUISideNavItem({
    required this.item,
    required this.expanded,
  });

  final WebbUISideNavItem item;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final selected = item.isSelected;

    // Determine text and icon color based on selection state
    final color = selected ? Colors.white : context.colorPalette.neutralDark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: item.onTap,
        child: Container(
          height: 48,
          margin: EdgeInsets.symmetric(
            vertical: context.spacingGrid.spacing(0.25),
            horizontal: context.spacingGrid.spacing(1),
          ),
          padding:
              EdgeInsets.symmetric(horizontal: context.spacingGrid.spacing(1)),
          decoration: BoxDecoration(
            color:
                selected ? context.colorPalette.secondary : Colors.transparent,
            borderRadius:
                BorderRadius.circular(context.spacingGrid.baseSpacing),
          ),
          child: Row(
            children: [
              // Icon
              Icon(
                item.icon,
                color: color,
                // Using a standard, explicit size of 20px
                size: 20,
              ),
              
              // Label (Only visible when expanded)
              if (expanded) ...[
                SizedBox(width: context.spacingGrid.spacing(2)),
                Expanded(
                  child: Text(
                    item.label,
                    style: context.typography.labelLarge.copyWith(color: color),
                    overflow: TextOverflow.ellipsis, // Handle long labels
                  ),
                ),
              ],
              
              // Badge (Always visible, but ensures it fits in collapsed mode)
              if (item.badgeCount != null && item.badgeCount! > 0)
                Padding(
                  padding: expanded
                      ? EdgeInsets.zero
                      : EdgeInsets.only(left: context.spacingGrid.spacing(0.5)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.colorPalette.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 20),
                    alignment: Alignment.center,
                    child: Text(
                      item.badgeCount.toString(),
                      style: context.typography.labelMedium
                          .copyWith(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
