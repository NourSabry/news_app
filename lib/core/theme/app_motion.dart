import 'package:flutter/material.dart';

/// Motion tokens. Calm and physical — nothing bounces.
sealed class AppMotion {
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 260);
  static const Duration page = Duration(milliseconds: 420);

  static const Curve curveIn = Curves.easeOutCubic;
  static const Curve curveOut = Curves.easeInCubic;
  static const Curve curveSettle = Curves.easeOutQuart;

  /// Collapses a duration to zero when the platform asks for reduced motion.
  static Duration scaled(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
