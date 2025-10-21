import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'stepper_models.dart';
import 'stepper_progress.dart';
import 'stepper_navigation.dart';
import 'stepper_animations.dart';
import 'stepper_validation.dart';

class WebbUIStepperWizard extends StatefulWidget {
  final List<WebbUIStep> steps;
  final int initialStep;
  final ValueChanged<int>? onStepChanged;
  final VoidCallback? onComplete;
  final WebbUIStepperConfig config;

  const WebbUIStepperWizard({
    super.key,
    required this.steps,
    this.initialStep = 0,
    this.onStepChanged,
    this.onComplete,
    this.config = const WebbUIStepperConfig(),
  }) : assert(initialStep >= 0 && initialStep < steps.length,
            'Initial step must be within bounds');

  @override
  State<WebbUIStepperWizard> createState() => _WebbUIStepperWizardState();
}

class _WebbUIStepperWizardState extends State<WebbUIStepperWizard>
    with SingleTickerProviderStateMixin {
  late WebbUIStepperState _state;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.animationDuration,
    );
    _animationController.forward();
  }

  void _initializeState() {
    _state = WebbUIStepperState(
      currentStep: widget.initialStep,
      stepErrors: List<String?>.filled(widget.steps.length, null),
      stepCompleted: List<bool>.filled(widget.steps.length, false),
      stepSkipped: List<bool>.filled(widget.steps.length, false),
    );
  }

  @override
  void didUpdateWidget(WebbUIStepperWizard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialStep != widget.initialStep) {
      _updateCurrentStep(widget.initialStep);
    }
  }

  void _updateCurrentStep(int newStep) {
    setState(() {
      _state = _state.copyWith(currentStep: newStep);
    });
    _animationController.forward(from: 0.0);
    widget.onStepChanged?.call(newStep);
  }

  void _validateCurrentStep() {
    if (!widget.config.autoValidate) return;

    final error = WebbUIStepperValidation.validateStep(
      step: widget.steps[_state.currentStep],
      context: context,
    );

    setState(() {
      _state = _state.copyWith(
        stepErrors: List.from(_state.stepErrors)..[_state.currentStep] = error,
      );
    });
  }

  void _handleNext() {
    _validateCurrentStep();

    final currentStep = widget.steps[_state.currentStep];
    final canSkip = WebbUIStepperValidation.canSkipStep(
      step: currentStep,
      context: context,
    );
    final isValid =
        WebbUIStepperValidation.isStepValid(_state, _state.currentStep);

    if (isValid || canSkip) {
      // Mark current step as completed if valid
      if (isValid) {
        setState(() {
          _state = _state.copyWith(
            stepCompleted: List.from(_state.stepCompleted)
              ..[_state.currentStep] = true,
          );
        });
      }

      // Handle step skipping
      if (canSkip) {
        _handleStepSkipping();
      } else if (_state.currentStep < widget.steps.length - 1) {
        _updateCurrentStep(_state.currentStep + 1);
      } else {
        widget.onComplete?.call();
      }
    }
  }

  void _handleStepSkipping() {
    int nextStep = _state.currentStep + 1;

    // Skip consecutive skippable steps
    while (nextStep < widget.steps.length - 1) {
      final canSkipNext = WebbUIStepperValidation.canSkipStep(
        step: widget.steps[nextStep],
        context: context,
      );
      if (!canSkipNext) break;

      setState(() {
        _state = _state.copyWith(
          stepSkipped: List.from(_state.stepSkipped)..[nextStep] = true,
        );
      });
      nextStep++;
    }

    if (nextStep < widget.steps.length) {
      _updateCurrentStep(nextStep);
    } else {
      widget.onComplete?.call();
    }
  }

  void _handlePrevious() {
    if (_state.currentStep > 0) {
      _updateCurrentStep(_state.currentStep - 1);
    }
  }

  void _handleStepTapped(int stepIndex) {
    if (WebbUIStepperValidation.isStepAccessible(_state, stepIndex)) {
      _updateCurrentStep(stepIndex);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final currentStep = widget.steps[_state.currentStep];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress Indicator
WebbUIStepperProgress(
          steps: widget.steps,
          state: _state,
          onStepTapped:
              widget.config.allowStepNavigation ? _handleStepTapped : null,
        ),

        SizedBox(height: webbTheme.spacingGrid.spacing(2)),

        // Step Content with Animation
        AnimatedSwitcher(
          duration: widget.config.animationDuration,
          switchInCurve: widget.config.animationCurve,
          switchOutCurve: widget.config.animationCurve,
          transitionBuilder: (child, animation) {
            return WebbUIStepperAnimations.buildAnimation(
              child: child,
              animation: animation,
              animationType: widget.config.animationType,
              curve: widget.config.animationCurve,
            );
          },
          child: KeyedSubtree(
            key: ValueKey(_state.currentStep),
            child: Semantics(
              label: 'Step ${_state.currentStep + 1}: ${currentStep.title}',
              child: currentStep.content,
            ),
          ),
        ),

        // Error Display
        if (widget.config.showStepErrors &&
            _state.stepErrors[_state.currentStep] != null)
          Padding(
            padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(1)),
            child: Text(
              _state.stepErrors[_state.currentStep]!,
              style: webbTheme.typography.labelMedium.copyWith(
                color: webbTheme.colorPalette.error,
              ),
            ),
          ),

        SizedBox(height: webbTheme.spacingGrid.spacing(2)),

        // Navigation Buttons
        WebbUIStepperNavigation(
          steps: widget.steps,
          state: _state,
          onNext: _handleNext,
          onPrevious: _handlePrevious,
          onComplete: widget.onComplete,
        ),
      ],
    );
  }
}
