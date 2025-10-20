import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'file_upload_definitions.dart';
import 'file_upload_utils.dart';
import 'file_upload_dropzone.dart';
import 'file_upload_picker.dart';

class WebbUIFileUpload extends StatefulWidget {
  final ValueChanged<PlatformFile>? onFileSelected;
  final ValueChanged<String>? onError;
  final String? label;
  final FileUploadMethod method;
  final FileValidationConfig validationConfig;

  const WebbUIFileUpload({
    super.key,
    this.onFileSelected,
    this.onError,
    this.label = 'Upload File',
    this.method = FileUploadMethod.both,
    this.validationConfig = const FileValidationConfig(),
  });

  @override
  State<WebbUIFileUpload> createState() => _WebbUIFileUploadState();
}

class _WebbUIFileUploadState extends State<WebbUIFileUpload> {
  bool _isHighlighted = false;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    await FileUploadPicker.pickFiles(
      validationConfig: widget.validationConfig,
      onFileSelected: (file) {
        widget.onFileSelected?.call(file);
      },
      onError: (error) {
        if (mounted) {
          _showError(context, error);
        }
      },
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
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

  bool get _supportsDragDrop {
    return FileUploadUtils.supportsDragDrop &&
        widget.method != FileUploadMethod.click;
  }

  bool get _supportsClick {
    return widget.method != FileUploadMethod.dragDrop;
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    final instructionText = FileUploadUtils.getInstructionText(
      isHighlighted: _isHighlighted,
      supportsDragDrop: _supportsDragDrop,
      label: widget.label!,
    );

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
          onTap: _supportsClick ? _pickFile : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: _isHighlighted
                  ? webbTheme.colorPalette.primary.withOpacity(0.1)
                  : webbTheme.colorPalette.surface,
              border: Border.all(
                color: _isHighlighted
                    ? webbTheme.colorPalette.primary
                    : webbTheme.colorPalette.neutralDark.withOpacity(0.3),
                width: 2,
              ),
              borderRadius:
                  BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
            ),
            child: Stack(
              children: [
                // Drag and drop zone for supported platforms
                if (_supportsDragDrop)
                  FileUploadDropzone(
                    onFileSelected: widget.onFileSelected,
                    onDragEnter: () => setState(() => _isHighlighted = true),
                    onDragLeave: () => setState(() => _isHighlighted = false),
                    validationConfig: widget.validationConfig,
                  ),

                // Visual content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: webbTheme.iconTheme.mediumSize,
                          height: webbTheme.iconTheme.mediumSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: webbTheme.colorPalette.primary,
                          ),
                        )
                      else
                        Icon(
                          _isHighlighted
                              ? Icons.file_upload
                              : Icons.cloud_upload_outlined,
                          size: webbTheme.iconTheme.largeSize,
                          color: webbTheme.colorPalette.primary,
                        ),
                      SizedBox(height: webbTheme.spacingGrid.spacing(1)),
                      Text(
                        instructionText,
                        style: webbTheme.typography.bodyMedium.copyWith(
                          color: webbTheme.colorPalette.neutralDark,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
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
