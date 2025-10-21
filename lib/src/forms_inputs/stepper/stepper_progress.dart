import 'package:flutter/material.dart';
import 'package:webb_ui/src/theme.dart';
import 'stepper_models.dart';

class WebbUIStepperProgress extends StatelessWidget {
  final List<WebbUIStep> steps;
  final WebbUIStepperState state;
  final ValueChanged<int>? onStepTapped;
  final BuildContext webbTheme;

  const WebbUIStepperProgress({
    super.key,
    required this.steps,
    required this.state,
    required this.webbTheme,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = webbTheme.iconTheme.mediumSize;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isAccessible = _isStepAccessible(index);
        final stepConfig = _getStepConfig(index);

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
                _buildStepTitle(step.title, stepConfig),
                // Optional Step Description
                if (step.description != null) ...[
                  SizedBox(height: webbTheme.spacingGrid.spacing(0.25)),
                  _buildStepDescription(step.description!, stepConfig),
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

  _StepConfig _getStepConfig(int index) {
    if (state.stepCompleted[index]) {
      return _StepConfig.completed();
    } else if (state.stepErrors[index] != null) {
      return _StepConfig.error();
    } else if (index == state.currentStep) {
      return _StepConfig.active();
    } else if (state.stepSkipped[index]) {
      return _StepConfig.skipped();
    } else {
      return _StepConfig.inactive();
    }
  }

  Widget _buildStepIcon(_StepConfig config, IconData? customIcon, double size) {
    return Icon(
      customIcon ?? config.icon,
      color: config.color,
      size: size,
    );
  }

  Widget _buildStepTitle(String title, _StepConfig config) {
    return Text(
      title,
      style: webbTheme.typography.labelMedium.copyWith(
        color: config.color,
        fontWeight: config.isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepDescription(String description, _StepConfig config) {
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

  factory _StepConfig.completed() => const _StepConfig(
        icon: Icons.check_circle,
        color: Colors.green,
        isActive: true,
      );

  factory _StepConfig.error() => const _StepConfig(
        icon: Icons.error,
        color: Colors.red,
        isActive: true,
      );

  factory _StepConfig.active() => const _StepConfig(
        icon: Icons.radio_button_checked,
        color: Colors.blue,
        isActive: true,
      );

  factory _StepConfig.skipped() => const _StepConfig(
        icon: Icons.remove_circle_outline,
        color: Colors.grey,
        isActive: false,
      );

  factory _StepConfig.inactive() => const _StepConfig(
        icon: Icons.radio_button_unchecked,
        color: Colors.grey,
        isActive: false,
      );
}
