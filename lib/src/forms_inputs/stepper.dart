import 'package:flutter/material.dart';
import 'package:webb_ui/webb_ui.dart';

enum AnimationType { slide, fade, scale, none }

class WebbUIStepper extends StatefulWidget {
  final List<Widget> steps;
  final List<String> stepTitles;
  final List<String? Function(BuildContext)?>
      validators; // Custom validators per step
  final List<GlobalKey<FormState>?> formKeys; // Optional form keys per step
  final List<bool Function(BuildContext)?>
      skipConditions; // Optional skip conditions per step
  final int initialStep;
  final ValueChanged<int>? onStepChanged;
  final VoidCallback? onComplete;
  final AnimationType animationType;
  final Duration animationDuration;
  final Curve animationCurve;

  WebbUIStepper({
    super.key,
    required this.steps,
    required this.stepTitles,
    this.validators = const [],
    this.formKeys = const [],
    this.skipConditions = const [],
    this.initialStep = 0,
    this.onStepChanged,
    this.onComplete,
    this.animationType = AnimationType.slide,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
  })  : assert(steps.length == stepTitles.length,
            'Steps and titles must match in length'),
        assert(validators.isEmpty || validators.length == steps.length,
            'Validators must match steps in length'),
        assert(formKeys.isEmpty || formKeys.length == steps.length,
            'Form keys must match steps in length'),
        assert(skipConditions.isEmpty || skipConditions.length == steps.length,
            'Skip conditions must match steps in length');

  @override
  State<WebbUIStepper> createState() => _WebbUIStepperState();
}

class _WebbUIStepperState extends State<WebbUIStepper>
    with SingleTickerProviderStateMixin {
  late int _currentStep;
  late List<String?> _stepErrors;
  late List<bool> _stepCompleted;
  late List<bool> _stepSkipped;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    _stepErrors = List<String?>.filled(widget.steps.length, null);
    _stepCompleted = List<bool>.filled(widget.steps.length, false);
    _stepSkipped = List<bool>.filled(widget.steps.length, false);
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String? _validateStep(int step) {
    final formKey = widget.formKeys[step];
    final customValidator = widget.validators[step];

    if (formKey != null && formKey.currentState != null) {
      // Validate form if present
      if (!formKey.currentState!.validate()) {
        return 'Form contains errors';
      }
      formKey.currentState!.save(); // Optionally save form data
      return null;
    } else if (customValidator != null) {
      // Fall back to custom validator
      return customValidator(context);
    }
    return null; // No validation, assume valid
  }

  bool _isStepValid(int step) {
    return _stepErrors[step] == null;
  }

  bool _canSkipStep(int step) {
    // Check if the skipConditions list is provided and the condition for the step is not null
    return step < widget.skipConditions.length &&
            widget.skipConditions[step] != null
        ? widget.skipConditions[step]!(context)
        : false;
  }

  void _nextStep() {
    final error = _validateStep(_currentStep);
    setState(() {
      _stepErrors[_currentStep] = error;
      if (error == null) {
        _stepCompleted[_currentStep] = true;
      }
    });

    if (error == null || _canSkipStep(_currentStep)) {
      if (_currentStep < widget.steps.length - 1) {
        if (_canSkipStep(_currentStep)) {
          // Skip to next non-skippable step or end
          int nextStep = _currentStep + 1;
          while (nextStep < widget.steps.length - 1 && _canSkipStep(nextStep)) {
            _stepSkipped[nextStep] = true;
            nextStep++;
          }
          _stepSkipped[_currentStep] = true;
          _currentStep = nextStep;
        } else {
          _currentStep++;
        }
        _animationController.forward(from: 0.0); // Trigger animation
        widget.onStepChanged?.call(_currentStep);
      } else {
        widget.onComplete?.call();
      }
      setState(() {}); // Ensure UI updates
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      _animationController.forward(from: 0.0); // Trigger animation
      widget.onStepChanged?.call(_currentStep);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    // Get the dynamically scaled icon theme
    final scaledIconTheme = webbTheme.iconTheme;
    // Use the scaled medium size for step icons
    final double iconSize = scaledIconTheme.mediumSize;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress indicator with animated status
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.steps.length, (index) {
            IconData icon;
            Color color;
            if (_stepCompleted[index]) {
              icon = Icons.check_circle;
              color = webbTheme.colorPalette.success;
            } else if (_stepErrors[index] != null) {
              icon = Icons.error;
              color = webbTheme.colorPalette.error;
            } else if (index == _currentStep) {
              icon = Icons.radio_button_checked;
              color = webbTheme.colorPalette.primary;
            } else if (_stepSkipped[index]) {
              icon = Icons.remove_circle_outline;
              color = webbTheme.colorPalette.neutralDark.withOpacity(0.6);
            } else {
              icon = Icons.radio_button_unchecked;
              color = webbTheme.colorPalette.neutralDark.withOpacity(0.4);
            }

            return GestureDetector(
              onTap: () {
                // Allow navigating to previous steps only if they weren't skipped
                if (index < _currentStep && !_stepSkipped[index]) {
                  _currentStep = index;
                  _animationController.forward(from: 0.0); // Trigger animation
                  widget.onStepChanged?.call(_currentStep);
                  setState(() {});
                }
              },
              child: AnimatedContainer(
                duration: widget.animationDuration,
                curve: widget.animationCurve,
                transform: index == _currentStep
                    ? Matrix4.identity().scaled(1.2, 1.2, 1.0)
                    : Matrix4.identity(),
                child: Column(
                  children: [
                    // --- FIX APPLIED HERE: Use scaled icon size ---
                    Icon(icon, color: color, size: iconSize),
                    // --- END FIX ---
                    Text(widget.stepTitles[index],
                        style: webbTheme.typography.labelMedium),
                  ],
                ),
              ),
            );
          }),
        ),
        SizedBox(height: webbTheme.spacingGrid.spacing(2)),
        // Step content with animation
        AnimatedSwitcher(
          duration: widget.animationDuration,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final inAnimation = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
                parent: animation, curve: widget.animationCurve));
            final outAnimation = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-1.0, 0.0),
            ).animate(CurvedAnimation(
                parent: animation, curve: widget.animationCurve));

            switch (widget.animationType) {
              case AnimationType.slide:
                // Use is going forward/backward to determine slide direction more accurately
                // For simplicity here, sticking to the original logic
                return SlideTransition(
                  position: animation.value <= 0.5 ? outAnimation : inAnimation,
                  child: child,
                );
              case AnimationType.fade:
                return FadeTransition(opacity: animation, child: child);
              case AnimationType.scale:
                return ScaleTransition(scale: animation, child: child);
              case AnimationType.none:
                return child;
            }
          },
          switchInCurve: widget.animationCurve,
          switchOutCurve: widget.animationCurve,
          child: Semantics(
            key: ValueKey<int>(_currentStep),
            label:
                'Step ${_currentStep + 1}: ${widget.stepTitles[_currentStep]} ${!_isStepValid(_currentStep) ? 'with errors' : _canSkipStep(_currentStep) ? 'skippable' : ''}',
            child: widget.steps[_currentStep],
          ),
        ),
        if (_stepErrors[_currentStep] != null)
          Padding(
            padding: EdgeInsets.only(top: webbTheme.spacingGrid.spacing(1)),
            child: Text(
              _stepErrors[_currentStep]!,
              style: webbTheme.typography.labelMedium
                  .copyWith(color: webbTheme.colorPalette.error),
            ),
          ),
        SizedBox(height: webbTheme.spacingGrid.spacing(2)),
        // Navigation buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0)
              WebbUIButton(
                label: 'Previous',
                onPressed: _previousStep,
                variant: WebbUIButtonVariant.secondary,
              ),
            WebbUIButton(
              label:
                  _currentStep < widget.steps.length - 1 ? 'Next' : 'Complete',
              onPressed: _nextStep,
              disabled: _stepErrors[_currentStep] != null &&
                  !_canSkipStep(_currentStep),
            ),
          ],
        ),
      ],
    );
  }
}
