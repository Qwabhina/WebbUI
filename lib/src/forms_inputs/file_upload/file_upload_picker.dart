import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'file_upload_definitions.dart';
import 'file_upload_utils.dart';

/// Handles traditional file picker functionality
class FileUploadPicker {
  static Future<void> pickFiles({
    required FileValidationConfig validationConfig,
    required ValueChanged<PlatformFile> onFileSelected,
    required ValueChanged<String> onError,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: validationConfig.allowedExtensions,
        allowMultiple: validationConfig.allowsMultiple,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          final validationState =
              FileUploadUtils.validateFile(file, validationConfig);

          if (validationState == FileValidationState.valid) {
            onFileSelected(file);
          } else {
            onError('File "${file.name}" does not meet requirements');
          }
        }
      }
    } catch (e) {
      onError('Failed to pick files: ${e.toString()}');
    }
  }
}
