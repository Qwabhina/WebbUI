enum WebbUIValidationState {
  none,
  success,
  error,
  warning,
}

extension WebbUIValidationStateExtension on WebbUIValidationState {
  String get description {
    switch (this) {
      case WebbUIValidationState.none:
        return 'None';
      case WebbUIValidationState.success:
        return 'Success';
      case WebbUIValidationState.error:
        return 'Error';
      case WebbUIValidationState.warning:
        return 'Warning';
    }
  }

  bool get isValid => this == WebbUIValidationState.success;
  bool get hasError => this == WebbUIValidationState.error;
  bool get hasWarning => this == WebbUIValidationState.warning;
  bool get hasFeedback => this != WebbUIValidationState.none;
}
