import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'file_upload_definitions.dart';

/// Utility methods for file upload functionality
class FileUploadUtils {
  /// Check if platform supports drag and drop
  static bool get supportsDragDrop {
    return kIsWeb ||
        (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  }

  /// Get platform-specific instruction text
  static String getInstructionText({
    required bool isHighlighted,
    required bool supportsDragDrop,
    required String label,
  }) {
    if (supportsDragDrop) {
      return isHighlighted
          ? 'Drop file here'
          : 'Drag & drop or click to upload';
    }
    return label;
  }

  /// Validate file against configuration
  static FileValidationState validateFile(
    PlatformFile file,
    FileValidationConfig config,
  ) {
    // Check file size
    if (config.maxFileSize != null && file.size > config.maxFileSize!) {
      return FileValidationState.invalid;
    }

    // Check file extension
    if (config.allowedExtensions != null &&
        config.allowedExtensions!.isNotEmpty) {
      final extension = _getFileExtension(file.name);
      if (!config.allowedExtensions!.contains(extension)) {
        return FileValidationState.invalid;
      }
    }

    return FileValidationState.valid;
  }

  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes as double) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
}

// Helper for power calculation
double pow(double x, int exponent) {
  double result = 1.0;
  for (int i = 0; i < exponent; i++) {
    result *= x;
  }
  return result;
}

double log(double x) {
  return x <= 0 ? 0 : math.log(x);
}
