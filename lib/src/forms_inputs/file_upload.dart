import 'dart:io' show Platform; // Used for non-web desktop platform detection
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // CRITICAL: Used for web detection
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:webb_ui/src/theme.dart';

/// A theme-aware component for uploading files, supporting click-to-upload
/// on all platforms and drag-and-drop on Web and Desktop.
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
  // DropzoneViewController is only needed for Web and Desktop targets.
  DropzoneViewController? _controller;
  bool _isHighlighted = false;

  /// Handles the action of opening the native file picker dialogue.
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
    
    // Determine if we are on a platform that supports drag-and-drop (Web or Desktop).
    // The conditional check is safe because `Platform` is conditionally available,
    // but `kIsWeb` is always safe to check.
    final bool enableDropzone =
        kIsWeb || (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

    // Default instructional text
    final String instructionText = enableDropzone
        ? (_isHighlighted ? 'Drop file here' : 'Drag & drop or Click to upload')
        : widget.label!; // Fallback for mobile/non-dropzone targets

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
            child: Text(
              widget.label!,
              style: webbTheme.typography.labelMedium,
            ),
          ),
        GestureDetector(
          // Allow tapping the whole container to open the file picker
          onTap: _pickFile,
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              // Use primary color for highlighting state
              color: _isHighlighted
                  ? webbTheme.colorPalette.primary.withOpacity(0.1)
                  : webbTheme.colorPalette.neutralLight.withOpacity(0.9),
              border: Border.all(
                color: _isHighlighted
                    ? webbTheme.colorPalette
                        .primary // Solid primary border when highlighted
                    : webbTheme.colorPalette.neutralDark
                        .withOpacity(0.3), // Faded border otherwise
                width: 2,
              ),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            ),
            child: Stack(
              children: [
                // DropzoneView for drag-and-drop on relevant platforms
                if (enableDropzone)
                  DropzoneView(
                    operation: DragOperation.copy,
                    cursor: CursorType.grab,
                    onCreated: (ctrl) => _controller = ctrl,
                    onHover: () => setState(() => _isHighlighted = true),
                    onLeave: () => setState(() => _isHighlighted = false),
                    onDropFile: (ev) async {
                      // IMPORTANT: Check mounted state before context/state updates
                      if (!mounted) return;
                      
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
                // Visual content (always visible)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon changes when highlighted
                      Icon(
                        _isHighlighted
                            ? Icons.file_upload
                            : Icons.cloud_upload_outlined,
                        size: webbTheme.iconTheme.largeSize,
                        color: webbTheme.colorPalette.primary,
                      ),
                      SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
                      Text(
                        instructionText,
                        style: webbTheme.typography.bodyMedium.copyWith(
                          color: webbTheme.colorPalette.neutralDark,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
