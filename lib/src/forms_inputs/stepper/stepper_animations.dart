import 'package:flutter/material.dart';
import 'stepper_models.dart';

class WebbUIStepperAnimations {
  static Widget buildAnimation({
    required Widget child,
    required Animation<double> animation,
    required WebbUIStepperAnimationType animationType,
    required Curve curve,
    bool isForward = true,
  }) {
    switch (animationType) {
      case WebbUIStepperAnimationType.slide:
        return _buildSlideAnimation(child, animation, curve, isForward);
      case WebbUIStepperAnimationType.fade:
        return _buildFadeAnimation(child, animation, curve);
      case WebbUIStepperAnimationType.scale:
        return _buildScaleAnimation(child, animation, curve);
      case WebbUIStepperAnimationType.none:
        return child;
    }
  }

  static Widget _buildSlideAnimation(
    Widget child,
    Animation<double> animation,
    Curve curve,
    bool isForward,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: Offset(isForward ? 1.0 : -1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  static Widget _buildFadeAnimation(
    Widget child,
    Animation<double> animation,
    Curve curve,
  ) {
    final fadeAnimation = CurvedAnimation(parent: animation, curve: curve);
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  static Widget _buildScaleAnimation(
    Widget child,
    Animation<double> animation,
    Curve curve,
  ) {
    final scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }
}
