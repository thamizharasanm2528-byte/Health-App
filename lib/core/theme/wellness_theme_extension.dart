import 'package:flutter/material.dart';

class WellnessThemeExtension extends ThemeExtension<WellnessThemeExtension> {
  final Color waterColor;
  final Color stepsColor;
  final Color bmiColor;
  final Color sleepColor;
  final Color foodColor;
  final Color healthColor;
  final double cardRadius;
  final List<BoxShadow> softShadows;

  const WellnessThemeExtension({
    required this.waterColor,
    required this.stepsColor,
    required this.bmiColor,
    required this.sleepColor,
    required this.foodColor,
    required this.healthColor,
    required this.cardRadius,
    required this.softShadows,
  });

  @override
  WellnessThemeExtension copyWith({
    Color? waterColor,
    Color? stepsColor,
    Color? bmiColor,
    Color? sleepColor,
    Color? foodColor,
    Color? healthColor,
    double? cardRadius,
    List<BoxShadow>? softShadows,
  }) {
    return WellnessThemeExtension(
      waterColor: waterColor ?? this.waterColor,
      stepsColor: stepsColor ?? this.stepsColor,
      bmiColor: bmiColor ?? this.bmiColor,
      sleepColor: sleepColor ?? this.sleepColor,
      foodColor: foodColor ?? this.foodColor,
      healthColor: healthColor ?? this.healthColor,
      cardRadius: cardRadius ?? this.cardRadius,
      softShadows: softShadows ?? this.softShadows,
    );
  }

  @override
  WellnessThemeExtension lerp(ThemeExtension<WellnessThemeExtension>? other, double t) {
    if (other is! WellnessThemeExtension) return this;
    return WellnessThemeExtension(
      waterColor: Color.lerp(waterColor, other.waterColor, t)!,
      stepsColor: Color.lerp(stepsColor, other.stepsColor, t)!,
      bmiColor: Color.lerp(bmiColor, other.bmiColor, t)!,
      sleepColor: Color.lerp(sleepColor, other.sleepColor, t)!,
      foodColor: Color.lerp(foodColor, other.foodColor, t)!,
      healthColor: Color.lerp(healthColor, other.healthColor, t)!,
      cardRadius: lerpDouble(cardRadius, other.cardRadius, t),
      softShadows: other.softShadows, // Simply replace or default to other
    );
  }

  static double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
