import 'package:flutter/material.dart';
// import 'package:bitsdojo_window/bitsdojo_window.dart'; // For desktop title bar integration if needed
import 'package:webb_ui/src/foundations/foundations.dart';
import 'package:webb_ui/src/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _widthAnimation = Tween<double>(begin: 250, end: 60).animate(
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
    // final theme = Theme.of(context);
    final webbTheme = context; // BuildContext extension
    final double width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;

    if (isMobile) {
      // For mobile, return as Drawer content
      return Drawer(
        child:
            _buildContent(context, expanded: true), // Always expanded in drawer
      );
    }

    // For desktop/tablet, animated width
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          color: webbTheme.colorPalette.neutralLight, // Background from theme
          child: Column(
            children: [
              if (widget.header != null) widget.header!,
              Expanded(child: _buildContent(context, expanded: !_isCollapsed)),
              if (widget.isCollapsible && !isMobile)
                IconButton(
                  icon: Icon(
                      _isCollapsed ? Icons.chevron_right : Icons.chevron_left),
                  onPressed: _toggleCollapse,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, {required bool expanded}) {
    final webbTheme = context;
    return ListView.builder(
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        final item = widget.items[index];
        final bool selected = item.isSelected;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: item.onTap,
            child: Container(
              height: 48,
              padding: EdgeInsets.symmetric(
                  horizontal: webbTheme.spacingGrid.spacing(2)),
              color: selected
                  ? webbTheme.colorPalette.secondary
                  : Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    item.icon,
                    color: selected
                        ? Colors.white
                        : webbTheme.colorPalette.neutralDark,
                    size: WebbUIIconTheme.getIconSize(context,
                        sizeType: 'medium'),
                  ),
                  if (expanded) ...[
                    SizedBox(width: webbTheme.spacingGrid.spacing(2)),
                    Expanded(
                      child: Text(
                        item.label,
                        style: webbTheme.typography.labelLarge.copyWith(
                          color: selected
                              ? Colors.white
                              : webbTheme.colorPalette.neutralDark,
                        ),
                      ),
                    ),
                  ],
                  if (item.badgeCount != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: webbTheme.colorPalette.error,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.badgeCount.toString(),
                        style: webbTheme.typography.labelMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
