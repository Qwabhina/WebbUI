// Additional file: sidenav_scaffold.dart
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'sidenav.dart';

class WebbUISideNavScaffold extends StatelessWidget {
  final Widget? sideNavHeader;
  final List<WebbUISideNavItem> sideNavItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final Widget body;
  final Widget? appBarTitle;
  final List<Widget>? appBarActions;
  final bool automaticallyImplyLeading;

  const WebbUISideNavScaffold({
    super.key,
    this.sideNavHeader,
    required this.sideNavItems,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.body,
    this.appBarTitle,
    this.appBarActions,
    this.automaticallyImplyLeading = true,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: appBarTitle,
          actions: appBarActions,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: webbTheme.colorPalette.surface,
          foregroundColor: webbTheme.colorPalette.neutralDark,
        ),
        drawer: WebbUISideNav(
          header: sideNavHeader,
          items: sideNavItems,
          selectedIndex: selectedIndex,
          onItemSelected: onItemSelected,
          isCollapsible: false,
        ),
        body: body,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          WebbUISideNav(
            header: sideNavHeader,
            items: sideNavItems,
            selectedIndex: selectedIndex,
            onItemSelected: onItemSelected,
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
