import 'dart:io';
import 'dart:math' as math;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'file_upload_definitions.dart';

class FileUploadUtils {
  /// Check if platform supports drag and drop
  static bool get supportsDragDrop {
    return kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  /// Get platform-specific instruction text
  static String getInstructionText({
    required bool isHighlighted,
    required bool supportsDragDrop,
    required String label,
  }) {
    if (supportsDragDrop) {
      return isHighlighted
          ? 'Drop files here'
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

  /// Validate multiple files
  static FileDropData validateFiles(
    List<PlatformFile> files,
    FileValidationConfig config,
  ) {
    final validFiles = <PlatformFile>[];
    bool allValid = true;

    for (final file in files) {
      final validationState = validateFile(file, config);
      if (validationState == FileValidationState.valid) {
        validFiles.add(file);
      } else {
        allValid = false;
      }
    }

    // Check file count
    if (config.maxFiles != null && validFiles.length > config.maxFiles!) {
      return const FileDropData(files: [], isValid: false);
    }

    return FileDropData(files: validFiles, isValid: allValid);
  }

  static String _getFileExtension(String filename) {
    final parts = filename.split('.');
    return parts.length > 1 ? '.${parts.last.toLowerCase()}' : '';
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (math.log(bytes) / math.log(1024)).floor();

    if (i >= suffixes.length) {
      return '${(bytes / math.pow(1024, suffixes.length - 1)).toStringAsFixed(1)} ${suffixes.last}';
    }
    
    return '${(bytes / math.pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Get file icon based on extension
  static IconData getFileIcon(String filename) {
    final extension = _getFileExtension(filename).toLowerCase();

    if (['.pdf'].contains(extension)) return Icons.picture_as_pdf;
    if (['.doc', '.docx'].contains(extension)) return Icons.description;
    if (['.xls', '.xlsx'].contains(extension)) return Icons.table_chart;
    if (['.jpg', '.jpeg', '.png', '.gif', '.bmp'].contains(extension)) {
      return Icons.image;
    }
    if (['.mp4', '.avi', '.mov', '.wmv'].contains(extension)) {
      return Icons.video_file;
    }
    if (['.mp3', '.wav', '.aac'].contains(extension)) return Icons.audio_file;
    if (['.zip', '.rar', '.7z'].contains(extension)) return Icons.archive;

    return Icons.insert_drive_file;
  }
}
