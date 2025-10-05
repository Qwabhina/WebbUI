import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

class WebbUIAccordion extends StatefulWidget {
  final String title;
  final Widget content;

  const WebbUIAccordion({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<WebbUIAccordion> createState() => _WebbUIAccordionState();
}

class _WebbUIAccordionState extends State<WebbUIAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    return WebbUICard(
      child: Column(
        children: [
          ListTile(
            title:
                Text(widget.title, style: webbTheme.typography.headlineMedium),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
              child: widget.content,
            ),
        ],
      ),
    );
  }
}
