import 'package:flutter/material.dart';

class WebbUIBottomNavItem {
  final IconData icon;
  final String label;
  final String? semanticLabel;
  final Widget? activeIcon;

  const WebbUIBottomNavItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
    this.activeIcon,
  });
}
