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
}
