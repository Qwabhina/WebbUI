import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIList extends StatelessWidget {
  final List<Widget> items;
  final bool dense;

  const WebbUIList({
    super.key,
    required this.items,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;
    return ListView.builder(
      shrinkWrap: true, // Prevents unbounded height in parent
      physics:
          const NeverScrollableScrollPhysics(), // Delegate scrolling to parent if needed
      itemCount: items.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: webbTheme.spacingGrid.spacing(dense || !isMobile ? 1 : 2),
          ),
          child: items[index],
        );
      },
    );
  }
}
