import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIDragDrop<T> extends StatelessWidget {
  final List<T> items;
  final ValueChanged<List<T>>? onReorder;
  final Widget Function(T item) itemBuilder;

  const WebbUIDragDrop({
    super.key,
    required this.items,
    this.onReorder,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return ReorderableListView.builder(
      shrinkWrap: true, // Bounded height
      physics: const NeverScrollableScrollPhysics(), // Parent scrolls
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        if (onReorder != null) {
          final reorderedItems = List<T>.from(items);
          final item = reorderedItems.removeAt(oldIndex);
          reorderedItems.insert(
              newIndex > oldIndex ? newIndex - 1 : newIndex, item);
          onReorder!(reorderedItems);
        }
      },
      itemBuilder: (context, index) {
        final item = itemBuilder(items[index]);
        return Padding(
          key: ValueKey(items[index]),
          padding: EdgeInsets.symmetric(
              vertical: webbTheme.spacingGrid.spacing(isMobile ? 2 : 1)),
          child: item,
        );
      },
      proxyDecorator: (child, index, animation) => Material(
        elevation: webbTheme.elevation.getShadows(2).first.blurRadius,
        child: child,
      ),
    );
  }
}
