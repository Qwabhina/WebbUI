import 'package:file_picker/file_picker.dart';

/// Supported file upload methods
enum FileUploadMethod {
  click, // Traditional file picker
  dragDrop, // Drag and drop functionality
  both, // Both click and drag & drop
}

/// File validation results
enum FileValidationState {
  none,
  valid,
  invalid,
  error,
}

/// Configuration for file validation
class FileValidationConfig {
  final List<String>? allowedExtensions;
  final int? maxFileSize; // in bytes
  final int? maxFiles;

  const FileValidationConfig({
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles = 1,
  });

  bool get allowsMultiple => (maxFiles ?? 1) > 1;

  FileValidationConfig copyWith({
    List<String>? allowedExtensions,
    int? maxFileSize,
    int? maxFiles,
  }) {
    return FileValidationConfig(
      allowedExtensions: allowedExtensions ?? this.allowedExtensions,
      maxFileSize: maxFileSize ?? this.maxFileSize,
      maxFiles: maxFiles ?? this.maxFiles,
    );
  }
}

/// Data model for drag and drop operations
class FileDropData {
  final List<PlatformFile> files;
  final bool isValid;

  const FileDropData({
    required this.files,
    required this.isValid,
  });
}
