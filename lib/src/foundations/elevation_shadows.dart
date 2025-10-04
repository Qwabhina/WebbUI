import 'package:flutter/material.dart';

/// Defines elevation and shadows for WebbUI.
class WebbUIElevation extends ThemeExtension<WebbUIElevation> {
  final List<BoxShadow> level0;
  final List<BoxShadow> level1;
  final List<BoxShadow> level2;
  final List<BoxShadow> level3;

  const WebbUIElevation({
    required this.level0,
    required this.level1,
    required this.level2,
    required this.level3,
  });

  /// Default shadow levels.
  static const WebbUIElevation defaultElevation = WebbUIElevation(
    level0: [], // No shadow
    level1: [
      BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))
    ],
    level2: [
      BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
    ],
    level3: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
    ],
  );

  /// Get shadows for a level.
  List<BoxShadow> getShadows(int level) {
    switch (level) {
      case 1:
        return level1;
      case 2:
        return level2;
      case 3:
        return level3;
      default:
        return level0;
    }
  }

  @override
  WebbUIElevation copyWith({
    List<BoxShadow>? level0,
    List<BoxShadow>? level1,
    List<BoxShadow>? level2,
    List<BoxShadow>? level3,
  }) {
    return WebbUIElevation(
      level0: level0 ?? this.level0,
      level1: level1 ?? this.level1,
      level2: level2 ?? this.level2,
      level3: level3 ?? this.level3,
    );
  }

  @override
  WebbUIElevation lerp(ThemeExtension<WebbUIElevation>? other, double t) {
    if (other is! WebbUIElevation) {
      return this;
    }
    return WebbUIElevation(
      level0: _lerpShadows(level0, other.level0, t),
      level1: _lerpShadows(level1, other.level1, t),
      level2: _lerpShadows(level2, other.level2, t),
      level3: _lerpShadows(level3, other.level3, t),
    );
  }

  static List<BoxShadow> _lerpShadows(
      List<BoxShadow> a, List<BoxShadow> b, double t) {
    if (a.length != b.length) return a;
    return List.generate(a.length, (i) => BoxShadow.lerp(a[i], b[i], t)!);
  }
}
