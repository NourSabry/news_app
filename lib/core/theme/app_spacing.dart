import 'package:flutter/material.dart';

sealed class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal gutter (Part 6.3).
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: gutter);
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(horizontal: md, vertical: sm);

  /// Corner radius on images and tiles (Part 6.3). No 12–16 px "card" radii.
  static const double radiusImage = 4;

  /// Corner radius on the few pills (new-stories, pending sync).
  static const double radiusPill = 999;

  static const double radiusSm = radiusImage;
  static const double radiusMd = radiusImage;
  static const double radiusLg = radiusImage;
  static const double radiusXl = radiusImage;
  static const double radiusFull = radiusPill;
}
