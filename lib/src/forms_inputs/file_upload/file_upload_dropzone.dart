import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webb_ui/src/theme.dart';
import 'file_upload_definitions.dart';
import 'file_upload_utils.dart';

/// Handles drag and drop functionality for supported platforms
class FileUploadDropzone extends StatefulWidget {
  final ValueChanged<PlatformFile>? onFileSelected;
  final VoidCallback? onDragEnter;
  final VoidCallback? onDragLeave;
  final FileValidationConfig validationConfig;

  const FileUploadDropzone({
    super.key,
    this.onFileSelected,
    this.onDragEnter,
    this.onDragLeave,
    this.validationConfig = const FileValidationConfig(),
  });

  @override
  State<FileUploadDropzone> createState() => _FileUploadDropzoneState();
}

class _FileUploadDropzoneState extends State<FileUploadDropzone> {
  DropzoneViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return DropzoneView(
      operation: DragOperation.copy,
      cursor: CursorType.grab,
      onCreated: (ctrl) => _controller = ctrl,
      onHover: () => widget.onDragEnter?.call(),
      onLeave: () => widget.onDragLeave?.call(),
      onDropFile: (ev) async {
        if (!mounted) return;

        try {
          final mime = await _controller?.getFileMIME(ev);
          final name = await _controller?.getFilename(ev);
          final size = await _controller?.getFileSize(ev);
          final bytes = await _controller?.getFileData(ev);

          if (name != null && bytes != null && widget.onFileSelected != null) {
            final file = PlatformFile(
              name: name,
              size: size ?? bytes.length,
              bytes: bytes,
            );

            // Validate file
            final validationState =
                FileUploadUtils.validateFile(file, widget.validationConfig);

            if (validationState == FileValidationState.valid) {
              widget.onFileSelected!(file);
            } else {
              _showValidationError(context);
            }
          }
        } catch (e) {
          _showError(context, 'Failed to process dropped file');
        }

        widget.onDragLeave?.call();
      },
    );
  }

  void _showValidationError(BuildContext context) {
    final webbTheme = context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'File does not meet requirements',
          style: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.onSurface,
          ),
        ),
        backgroundColor: webbTheme.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    final webbTheme = context;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: webbTheme.typography.bodyMedium.copyWith(
            color: webbTheme.colorPalette.onSurface,
          ),
        ),
        backgroundColor: webbTheme.colorPalette.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
