import 'package:flutter/material.dart';
import 'package:webb_ui/src/foundations/breakpoints.dart';

class WebbUIResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, String deviceType) builder;

  const WebbUIResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final String deviceType = WebbUIBreakpoints.getDeviceType(width);
    return builder(context, deviceType);
  }
}
