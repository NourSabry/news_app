import 'package:flutter/material.dart';

/// Motion tokens (Part 6.13). Never `bounce`/`elastic`.
sealed class AppMotion {
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration transition = Duration(milliseconds: 250);
  static const Duration page = Duration(milliseconds: 400);

  static const Curve curveIn = Curves.easeOutCubic;
  static const Curve curveOut = Curves.easeInCubic;

  /// Respects `MediaQuery.disableAnimations` by collapsing a duration to
  /// zero.
  static Duration scaled(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
