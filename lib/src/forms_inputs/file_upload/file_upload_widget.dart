import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'file_upload_definitions.dart';
import 'file_upload_utils.dart';
import 'file_upload_dropzone.dart';
import 'file_upload_picker.dart';

class WebbUIFileUpload extends StatefulWidget {
  final ValueChanged<List<PlatformFile>>? onFilesSelected;
  final ValueChanged<String>? onError;
  final String? label;
  final String? hintText;
  final FileUploadMethod method;
  final FileValidationConfig validationConfig;
  final bool showFileSize;
  final bool disabled;

  const WebbUIFileUpload({
    super.key,
    this.onFilesSelected,
    this.onError,
    this.label = 'Upload File',
    this.hintText,
    this.method = FileUploadMethod.both,
    this.validationConfig = const FileValidationConfig(),
    this.showFileSize = true,
    this.disabled = false,
  });

  @override
  State<WebbUIFileUpload> createState() => _WebbUIFileUploadState();
}

class _WebbUIFileUploadState extends State<WebbUIFileUpload> {
  bool _isLoading = false;
  bool _isHighlighted = false;
  final List<PlatformFile> _selectedFiles = [];

  bool get _supportsDragDrop {
    return FileUploadUtils.supportsDragDrop &&
        widget.method != FileUploadMethod.click;
  }

  bool get _supportsClick {
    return widget.method != FileUploadMethod.dragDrop;
  }

  Future<void> _pickFile() async {
    if (_isLoading || widget.disabled || !_supportsClick) return;

    setState(() => _isLoading = true);

    final selectedFiles = <PlatformFile>[];

    await FileUploadPicker.pickFiles(
      validationConfig: widget.validationConfig,
      onFileSelected: (file) => selectedFiles.add(file),
      onError: (error) => _handleError(error),
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (selectedFiles.isNotEmpty) {
          _addFiles(selectedFiles);
        }
      });
    }
  }

  void _handleFilesDropped(List<PlatformFile> files) {
    if (widget.disabled) return;
    _addFiles(files);
  }

  void _addFiles(List<PlatformFile> files) {
    if (!mounted) return;

    setState(() {
      if (widget.validationConfig.allowsMultiple) {
        _selectedFiles.addAll(files);
      } else {
        _selectedFiles.clear();
        _selectedFiles.add(files.first);
      }
    });

    widget.onFilesSelected?.call(List.from(_selectedFiles));
  }

  void _removeFile(int index) {
    if (!mounted) return;

    setState(() {
      _selectedFiles.removeAt(index);
      widget.onFilesSelected?.call(List.from(_selectedFiles));
    });
  }

  void _clearAllFiles() {
    if (!mounted) return;

    setState(() {
      _selectedFiles.clear();
      widget.onFilesSelected?.call([]);
    });
  }

  void _handleError(String message) {
    if (!mounted) return;
    
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
    
    widget.onError?.call(message);
  }

  String _getHintText() {
    if (widget.hintText != null) return widget.hintText!;

    final parts = <String>[];
    if (widget.validationConfig.allowedExtensions != null) {
      parts.add(widget.validationConfig.allowedExtensions!.join(', '));
    }
    if (widget.validationConfig.maxFileSize != null) {
      parts.add(
          'max ${FileUploadUtils.formatFileSize(widget.validationConfig.maxFileSize!)}');
    }
    
    return parts.isEmpty ? 'Select file to upload' : parts.join(' • ');
  }

  Widget _buildUploadArea(BuildContext webbTheme) {
    final instructionText = FileUploadUtils.getInstructionText(
      isHighlighted: _isHighlighted,
      supportsDragDrop: _supportsDragDrop,
      label: widget.label!,
    );

    final content = Column(
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
            _isHighlighted ? Icons.file_upload : Icons.cloud_upload_outlined,
            size: webbTheme.iconTheme.largeSize,
            color: widget.disabled
                ? webbTheme.interactionStates.disabledColor
                : webbTheme.colorPalette.primary,
          ),
        SizedBox(height: webbTheme.spacingGrid.spacing(1)),
        Text(
          instructionText,
          style: webbTheme.typography.bodyMedium.copyWith(
            color: widget.disabled
                ? webbTheme.interactionStates.disabledColor
                : webbTheme.colorPalette.neutralDark,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
        if (_getHintText().isNotEmpty) ...[
          SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
          Text(
            _getHintText(),
            style: webbTheme.typography.labelSmall.copyWith(
              color: webbTheme.colorPalette.neutralDark.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (_supportsDragDrop) {
      return FileUploadDropzone(
        onFilesDropped: _handleFilesDropped,
        onError: _handleError,
        validationConfig: widget.validationConfig,
        isHighlighted: _isHighlighted,
        onDragEnter: () => setState(() => _isHighlighted = true),
        onDragLeave: () => setState(() => _isHighlighted = false),
        child: Container(
          height: 140,
          padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
          child: content,
        ),
      );
    } else {
      return GestureDetector(
        onTap: _pickFile,
        child: Container(
          height: 140,
          padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(2)),
          decoration: BoxDecoration(
            color: widget.disabled
                ? webbTheme.interactionStates.disabledColor.withOpacity(0.1)
                : webbTheme.colorPalette.surface,
            border: Border.all(
              color: webbTheme.colorPalette.neutralDark.withOpacity(0.3),
              width: 2,
            ),
            borderRadius:
                BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
          ),
          child: content,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        if (widget.label != null)
          Padding(
            padding: EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.label!,
                  style: webbTheme.typography.labelMedium.copyWith(
                    color: widget.disabled
                        ? webbTheme.interactionStates.disabledColor
                        : webbTheme.colorPalette.neutralDark,
                  ),
                ),
                if (_selectedFiles.isNotEmpty &&
                    widget.validationConfig.allowsMultiple)
                  TextButton(
                    onPressed: _clearAllFiles,
                    child: Text(
                      'Clear all',
                      style: webbTheme.typography.labelSmall.copyWith(
                        color: webbTheme.colorPalette.error,
                      ),
                    ),
                  ),
              ],
            ),
          ),

        // Upload Area (with drag and drop support)
        _buildUploadArea(webbTheme),

        // Selected Files List
        if (_selectedFiles.isNotEmpty) ...[
          SizedBox(height: webbTheme.spacingGrid.spacing(1)),
          ..._selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFileItem(file, index, webbTheme);
          }),
        ],
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file, int index, BuildContext webbTheme) {
    return Container(
      margin: EdgeInsets.only(bottom: webbTheme.spacingGrid.spacing(0.5)),
      padding: EdgeInsets.all(webbTheme.spacingGrid.spacing(1.5)),
      decoration: BoxDecoration(
        color: webbTheme.colorPalette.neutralLight,
        borderRadius: BorderRadius.circular(webbTheme.spacingGrid.baseSpacing),
      ),
      child: Row(
        children: [
          Icon(
            FileUploadUtils.getFileIcon(file.name),
            size: webbTheme.iconTheme.mediumSize,
            color: webbTheme.colorPalette.primary,
          ),
          SizedBox(width: webbTheme.spacingGrid.spacing(1)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: webbTheme.typography.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.showFileSize)
                  Text(
                    FileUploadUtils.formatFileSize(file.size),
                    style: webbTheme.typography.labelSmall.copyWith(
                      color:
                          webbTheme.colorPalette.neutralDark.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: webbTheme.iconTheme.smallSize,
              color: webbTheme.colorPalette.error,
            ),
            onPressed: () => _removeFile(index),
          ),
        ],
      ),
    );
  }
}
