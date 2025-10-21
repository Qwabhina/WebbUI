import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webb_ui/src/theme.dart';
import 'file_upload_definitions.dart';
import 'file_upload_utils.dart';

/// Native Flutter drag and drop implementation
class FileUploadDropzone extends StatefulWidget {
  final ValueChanged<List<PlatformFile>> onFilesDropped;
  final ValueChanged<String> onError;
  final FileValidationConfig validationConfig;
  final Widget child;
  final bool isHighlighted;
  final VoidCallback? onDragEnter;
  final VoidCallback? onDragLeave;

  const FileUploadDropzone({
    super.key,
    required this.onFilesDropped,
    required this.onError,
    required this.validationConfig,
    required this.child,
    required this.isHighlighted,
    this.onDragEnter,
    this.onDragLeave,
  });

  @override
  State<FileUploadDropzone> createState() => _FileUploadDropzoneState();
}

class _FileUploadDropzoneState extends State<FileUploadDropzone> {
  bool _isDragging = false;

  Future<void> _handleDroppedFiles(List<PlatformFile> files) async {
    if (files.isEmpty) return;

    final validation =
        FileUploadUtils.validateFiles(files, widget.validationConfig);

    if (validation.files.isNotEmpty) {
      widget.onFilesDropped(validation.files);
    }

    if (!validation.isValid) {
      widget.onError('Some files did not meet requirements');
    }
  }

  Future<void> _handleFilePicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.validationConfig.allowedExtensions,
        allowMultiple: widget.validationConfig.allowsMultiple,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        await _handleDroppedFiles(result.files);
      }
    } catch (e) {
      widget.onError('Failed to pick files: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return DragTarget<PlatformFile>(
      onWillAcceptWithDetails: (data) {
        setState(() {
          _isDragging = true;
        });
        widget.onDragEnter?.call();
        return true;
      },
      onAcceptWithDetails: (file) {
        _handleDroppedFiles([file.data]);
        setState(() {
          _isDragging = false;
        });
        widget.onDragLeave?.call();
      },
      onLeave: (data) {
        setState(() {
          _isDragging = false;
        });
        widget.onDragLeave?.call();
      },
      builder: (context, candidateData, rejectedData) {
        final bool isActive = _isDragging || widget.isHighlighted;
        
        return GestureDetector(
          onTap: _handleFilePicker,
          child: Container(
            decoration: BoxDecoration(
              color: isActive
                  ? webbTheme.colorPalette.primary.withOpacity(0.1)
                  : webbTheme.colorPalette.surface,
              border: Border.all(
                color: isActive
                    ? webbTheme.colorPalette.primary
                    : webbTheme.colorPalette.neutralDark.withOpacity(0.3),
                width: isActive ? 3 : 2,
              ),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            ),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.02 : 1.0,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
