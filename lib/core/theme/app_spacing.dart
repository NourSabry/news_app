import 'package:flutter/material.dart';

sealed class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal screen gutter.
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: gutter,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(md);
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Thumbnails, small tiles, buttons.
  static const double radiusSm = 12;

  /// Inputs, sheets, banners, standard images.
  static const double radiusMd = 16;

  /// Lead imagery, hero, onboarding tiles.
  static const double radiusLg = 20;

  /// Bottom sheets.
  static const double radiusXl = 28;

  static const double radiusPill = 999;
  static const double radiusFull = radiusPill;

  /// Height of the floating navigation dock, without safe-area inset.
  static const double dockHeight = 64;

  /// Vertical room lists leave so their last item clears the floating dock.
  static const double dockClearance = dockHeight + xxl + lg;
}
