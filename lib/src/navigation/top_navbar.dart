import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUITopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? badge;
  final bool showWindowControls;

  const WebbUITopNavBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.badge,
    this.showWindowControls = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return WindowTitleBarBox(
      child: Container(
        height: preferredSize.height,
        color: webbTheme.colorPalette.primary, // Themed background
        child: Row(
          children: [
            if (leading != null) leading!,
            Expanded(
              child: MoveWindow(
                child: Center(
                  child: Text(
                    title,
                    style: webbTheme.typography.headlineMedium
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ),
            if (badge != null) badge!,
            if (actions != null) ...actions!,
            if (showWindowControls && isDesktop)
              Row(
                children: [
                  MinimizeWindowButton(),
                  MaximizeWindowButton(),
                  CloseWindowButton(),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
