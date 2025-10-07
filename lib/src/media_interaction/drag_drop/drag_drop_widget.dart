import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';

/// A theme-aware, reorderable list component for drag-and-drop functionality.
class WebbUIDragDrop<T> extends StatelessWidget {
  /// The list of items to display and reorder.
  final List<T> items;

  /// Callback triggered when the list is reordered by the user.
  final ValueChanged<List<T>>? onReorder;

  /// A builder function to create the widget for each item in the list.
  final Widget Function(T item) itemBuilder;

  /// If true, displays a dedicated drag handle icon for reordering.
  /// This is recommended if items have their own interactive elements.
  final bool showDragHandle;

  /// A widget to display when the `items` list is empty.
  final Widget? emptyPlaceholder;

  const WebbUIDragDrop({
    super.key,
    required this.items,
    this.onReorder,
    required this.itemBuilder,
    this.showDragHandle = true,
    this.emptyPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // final bool isMobile = MediaQuery.of(context).size.width < 600;

    // Display the placeholder if the list is empty.
    if (items.isEmpty) {
      return emptyPlaceholder ?? const SizedBox.shrink();
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles:
          !showDragHandle, // Disable default handles if we're showing our own.
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(), // Assumes parent is scrollable.
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        if (onReorder != null) {
          final reorderedItems = List<T>.from(items);
          final T item = reorderedItems.removeAt(oldIndex);
          // Adjust index for items moving down the list.
          reorderedItems.insert(
              newIndex > oldIndex ? newIndex - 1 : newIndex, item);
          onReorder!(reorderedItems);
        }
      },
      itemBuilder: (context, index) {
        final item = items[index];
        final child = itemBuilder(item);

        // Each item must have a unique key.
        return Container(
          key: ValueKey(item),
          margin: EdgeInsets.symmetric(
            vertical: webbTheme.spacingGrid.spacing(1),
          ),
          decoration: BoxDecoration(
            color: webbTheme.colorPalette.neutralLight,
            borderRadius:
                BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            border: Border.all(
                color: webbTheme.colorPalette.neutralDark.withOpacity(0.1)),
          ),
          child: showDragHandle
              ? Row(
                  children: [
                    Expanded(child: child),
                    ReorderableDragStartListener(
                      index: index,
                      child: Semantics(
                        label: 'Reorder',
                        child: Container(
                          padding:
                              EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
                          child: Icon(
                            Icons.drag_handle,
                            color: webbTheme.colorPalette.neutralDark
                                .withOpacity(0.5),
                            size: webbTheme.iconTheme.mediumSize,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : child,
        );
      },
      // Enhances the visual feedback for the item being dragged.
      proxyDecorator: (widget, index, animation) {
        return Material(
          type: MaterialType.transparency,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              final double scale = 1.0 + (animation.value * 0.05);
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    color: webbTheme.interactionStates.pressedOverlay
                        .withOpacity(0.1),
                    boxShadow: webbTheme.elevation.getShadows(2),
                    borderRadius: BorderRadius.circular(
                        webbTheme.spacingGrid.baseSpacing),
                  ),
                  child: widget,
                ),
              );
            },
            child: widget,
          ),
        );
      },
    );
  }
}
