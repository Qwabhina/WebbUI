import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'stepper_models.dart';

class WebbUIStepperProgress extends StatelessWidget {
  final List<WebbUIStep> steps;
  final WebbUIStepperState state;
  final ValueChanged<int>? onStepTapped;

  const WebbUIStepperProgress({
    super.key,
    required this.steps,
    required this.state,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final webbTheme = context;
    final iconSize = webbTheme.iconTheme.mediumSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isAccessible = _isStepAccessible(index);
        final stepConfig = _getStepConfig(index, context);

        return GestureDetector(
          onTap: isAccessible ? () => onStepTapped?.call(index) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            transform: index == state.currentStep
                ? Matrix4.identity().scaled(1.2, 1.2, 1.0)
                : Matrix4.identity(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step Icon
                _buildStepIcon(stepConfig, step.icon, iconSize),
                SizedBox(height: webbTheme.spacingGrid.spacing(0.5)),
                // Step Title
                _buildStepTitle(step.title, stepConfig, webbTheme),
                // Optional Step Description
                if (step.description != null) ...[
                  SizedBox(height: webbTheme.spacingGrid.spacing(0.25)),
                  _buildStepDescription(
                      step.description!, stepConfig, webbTheme),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  bool _isStepAccessible(int index) {
    return index <= state.currentStep ||
        (index > state.currentStep && state.stepCompleted[index]);
  }

  _StepConfig _getStepConfig(int index, BuildContext context) {
    final webbTheme = context;
    
    if (state.stepCompleted[index]) {
      return _StepConfig.completed(webbTheme);
    } else if (state.stepErrors[index] != null) {
      return _StepConfig.error(webbTheme);
    } else if (index == state.currentStep) {
      return _StepConfig.active(webbTheme);
    } else if (state.stepSkipped[index]) {
      return _StepConfig.skipped(webbTheme);
    } else {
      return _StepConfig.inactive(webbTheme);
    }
  }

  Widget _buildStepIcon(_StepConfig config, IconData? customIcon, double size) {
    return Icon(
      customIcon ?? config.icon,
      color: config.color,
      size: size,
    );
  }

  Widget _buildStepTitle(
      String title, _StepConfig config, BuildContext webbTheme) {
    return Text(
      title,
      style: webbTheme.typography.labelMedium.copyWith(
        color: config.color,
        fontWeight: config.isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepDescription(
      String description, _StepConfig config, BuildContext webbTheme) {
    return Text(
      description,
      style: webbTheme.typography.labelSmall.copyWith(
        color: config.color.withOpacity(0.7),
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _StepConfig {
  final IconData icon;
  final Color color;
  final bool isActive;

  const _StepConfig({
    required this.icon,
    required this.color,
    required this.isActive,
  });

  factory _StepConfig.completed(BuildContext context) => _StepConfig(
        icon: Icons.check_circle,
        color: context.colorPalette.success,
        isActive: true,
      );

  factory _StepConfig.error(BuildContext context) => _StepConfig(
        icon: Icons.error,
        color: context.colorPalette.error,
        isActive: true,
      );

  factory _StepConfig.active(BuildContext context) => _StepConfig(
        icon: Icons.radio_button_checked,
        color: context.colorPalette.primary,
        isActive: true,
      );

  factory _StepConfig.skipped(BuildContext context) => _StepConfig(
        icon: Icons.remove_circle_outline,
        color: context.interactionStates.disabledColor,
        isActive: false,
      );

  factory _StepConfig.inactive(BuildContext context) => _StepConfig(
        icon: Icons.radio_button_unchecked,
        color: context.colorPalette.neutralDark.withOpacity(0.5),
        isActive: false,
      );
}
