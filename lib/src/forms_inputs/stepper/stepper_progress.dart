import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
    final iconSize = context.iconTheme.mediumSize;

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
                SizedBox(height: context.spacingGrid.spacing(0.5)),
                // Step Title
                _buildStepTitle(step.title, stepConfig, context),
                // Optional Step Description
                if (step.description != null) ...[
                  SizedBox(height: context.spacingGrid.spacing(0.25)),
                  _buildStepDescription(
                      step.description!, stepConfig, context),
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
    
    if (state.stepCompleted[index]) {
      return _StepConfig.completed(context);
    } else if (state.stepErrors[index] != null) {
      return _StepConfig.error(context);
    } else if (index == state.currentStep) {
      return _StepConfig.active(context);
    } else if (state.stepSkipped[index]) {
      return _StepConfig.skipped(context);
    } else {
      return _StepConfig.inactive(context);
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
      String title, _StepConfig config, BuildContext context) {
    return Text(
      title,
      style: context.typography.labelMedium.copyWith(
        color: config.color,
        fontWeight: config.isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepDescription(
      String description, _StepConfig config, BuildContext context) {
    return Text(
      description,
      style: context.typography.labelSmall.copyWith(
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
        // icon: Icons.check_circle,
        icon: FluentIcons.checkmark_20_regular,
        color: context.colorPalette.success,
        isActive: true,
      );

  factory _StepConfig.error(BuildContext context) => _StepConfig(
        // icon: Icons.error,
        icon: FluentIcons.error_circle_20_regular,
        color: context.colorPalette.error,
        isActive: true,
      );

  factory _StepConfig.active(BuildContext context) => _StepConfig(
        // icon: Icons.radio_button_checked,
        icon: FluentIcons.radio_button_20_regular,
        color: context.colorPalette.primary,
        isActive: true,
      );

  factory _StepConfig.skipped(BuildContext context) => _StepConfig(
        // icon: Icons.remove_circle_outline,
        icon: FluentIcons.dismiss_circle_20_regular,
        color: context.interactionStates.disabledColor,
        isActive: false,
      );

  factory _StepConfig.inactive(BuildContext context) => _StepConfig(
        // icon: Icons.radio_button_unchecked,
        icon: FluentIcons.radio_button_20_regular,
        color: context.colorPalette.neutralDark.withOpacity(0.5),
        isActive: false,
      );
}
