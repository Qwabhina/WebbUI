import 'package:flutter/material.dart';

enum WebbUIStepperAnimationType { slide, fade, scale, none }

class WebbUIStepperConfig {
  final WebbUIStepperAnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;
  final bool allowStepNavigation;
  final bool showStepErrors;
  final bool autoValidate;

  const WebbUIStepperConfig({
    this.animationType = WebbUIStepperAnimationType.slide,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.allowStepNavigation = true,
    this.showStepErrors = true,
    this.autoValidate = true,
  });

  WebbUIStepperConfig copyWith({
    WebbUIStepperAnimationType? animationType,
    Duration? animationDuration,
    Curve? animationCurve,
    bool? allowStepNavigation,
    bool? showStepErrors,
    bool? autoValidate,
  }) {
    return WebbUIStepperConfig(
      animationType: animationType ?? this.animationType,
      animationDuration: animationDuration ?? this.animationDuration,
      animationCurve: animationCurve ?? this.animationCurve,
      allowStepNavigation: allowStepNavigation ?? this.allowStepNavigation,
      showStepErrors: showStepErrors ?? this.showStepErrors,
      autoValidate: autoValidate ?? this.autoValidate,
    );
  }
}

class WebbUIStep {
  final String title;
  final Widget content;
  final GlobalKey<FormState>? formKey;
  final String? Function(BuildContext)? validator;
  final bool Function(BuildContext)? skipCondition;
  final String? description;
  final IconData? icon;

  const WebbUIStep({
    required this.title,
    required this.content,
    this.formKey,
    this.validator,
    this.skipCondition,
    this.description,
    this.icon,
  });
}

class WebbUIStepperState {
  final int currentStep;
  final List<String?> stepErrors;
  final List<bool> stepCompleted;
  final List<bool> stepSkipped;

  const WebbUIStepperState({
    required this.currentStep,
    required this.stepErrors,
    required this.stepCompleted,
    required this.stepSkipped,
  });

  WebbUIStepperState copyWith({
    int? currentStep,
    List<String?>? stepErrors,
    List<bool>? stepCompleted,
    List<bool>? stepSkipped,
  }) {
    return WebbUIStepperState(
      currentStep: currentStep ?? this.currentStep,
      stepErrors: stepErrors ?? this.stepErrors,
      stepCompleted: stepCompleted ?? this.stepCompleted,
      stepSkipped: stepSkipped ?? this.stepSkipped,
    );
  }
}
