import 'package:flutter/material.dart';
import 'stepper_models.dart';

class WebbUIStepperValidation {
  static String? validateStep({
    required WebbUIStep step,
    required BuildContext context,
  }) {
    // First, validate form if present
    if (step.formKey != null && step.formKey!.currentState != null) {
      if (!step.formKey!.currentState!.validate()) {
        return 'Please fix the form errors before continuing';
      }
      step.formKey!.currentState!.save();
      return null;
    }

    // Then, use custom validator if provided
    if (step.validator != null) {
      return step.validator!(context);
    }

    // No validation required
    return null;
  }

  static bool canSkipStep({
    required WebbUIStep step,
    required BuildContext context,
  }) {
    return step.skipCondition?.call(context) ?? false;
  }

  static bool isStepValid(WebbUIStepperState state, int stepIndex) {
    return state.stepErrors[stepIndex] == null;
  }

  static bool isStepAccessible(WebbUIStepperState state, int stepIndex) {
    // A step is accessible if:
    // 1. It's the current step, OR
    // 2. It's a previous step that wasn't skipped, OR
    // 3. It's a completed step
    return stepIndex == state.currentStep ||
        (stepIndex < state.currentStep && !state.stepSkipped[stepIndex]) ||
        state.stepCompleted[stepIndex];
  }
}
