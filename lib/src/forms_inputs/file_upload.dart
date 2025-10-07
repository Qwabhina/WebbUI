import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:webb_ui/src/theme.dart';

class WebbUIFileUpload extends StatefulWidget {
  final ValueChanged<PlatformFile>? onFileSelected;
  final String? label;

  const WebbUIFileUpload({
    super.key,
    this.onFileSelected,
    this.label = 'Upload File',
  });

  @override
  State<WebbUIFileUpload> createState() => _WebbUIFileUploadState();
}

class _WebbUIFileUploadState extends State<WebbUIFileUpload> {
  late DropzoneViewController? _controller;
  bool _isHighlighted = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null &&
        result.files.isNotEmpty &&
        widget.onFileSelected != null) {
      widget.onFileSelected!(result.files.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final bool isDesktop = Platform.isWindows ||
        Platform.isMacOS ||
        Platform.isLinux; // Approximate

    return GestureDetector(
      onTap: _pickFile,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: _isHighlighted
              ? webbTheme.interactionStates.hoverOverlay
              : webbTheme.colorPalette.neutralLight,
          border: Border.all(color: webbTheme.colorPalette.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            if (isDesktop)
              DropzoneView(
                operation: DragOperation.copy,
                cursor: CursorType.grab,
                onCreated: (ctrl) => _controller = ctrl,
                onHover: () => setState(() => _isHighlighted = true),
                onLeave: () => setState(() => _isHighlighted = false),
                onDropFile: (ev) async {
                  final bytes = await _controller?.getFileData(ev);
                  final name = await _controller?.getFilename(ev);
                  if (bytes != null &&
                      name != null &&
                      widget.onFileSelected != null) {
                    widget.onFileSelected!(PlatformFile(
                        name: name, size: bytes.length, bytes: bytes));
                  }
                  setState(() => _isHighlighted = false);
                },
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload,
                      size: 40, color: webbTheme.colorPalette.primary),
                  Text(
                    widget.label!,
                    style: webbTheme.typography.bodyMedium
                        .copyWith(color: webbTheme.colorPalette.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
