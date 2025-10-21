import 'package:flutter/material.dart';
import 'package:webb_ui/src/buttons_controls/buttons_controls.dart';
import 'stepper_models.dart';
import 'stepper_validation.dart';

class WebbUIStepperNavigation extends StatelessWidget {
  final List<WebbUIStep> steps;
  final WebbUIStepperState state;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback? onComplete;

  const WebbUIStepperNavigation({
    super.key,
    required this.steps,
    required this.state,
    required this.onNext,
    required this.onPrevious,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isFirstStep = state.currentStep == 0;
    final isLastStep = state.currentStep == steps.length - 1;
    final currentStep = steps[state.currentStep];

    final canProceed =
        WebbUIStepperValidation.isStepValid(state, state.currentStep) ||
            WebbUIStepperValidation.canSkipStep(
                step: currentStep, context: context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Previous Button
        if (!isFirstStep)
          WebbUIButton(
            label: 'Previous',
            onPressed: onPrevious,
            variant: WebbUIButtonVariant.secondary,
            icon: Icons.arrow_back,
          )
        else
          const SizedBox(), // Spacer to maintain layout

        // Next/Complete Button
        WebbUIButton(
          label: isLastStep ? 'Complete' : 'Next',
          onPressed: canProceed ? onNext : null,
          variant: isLastStep
              ? WebbUIButtonVariant.primary
              : WebbUIButtonVariant.secondary,
          icon: isLastStep ? Icons.check : Icons.arrow_forward,
        ),
      ],
    );
  }
}
