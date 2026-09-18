import 'package:flutter/material.dart';

/// Type scale. Two faces only: Fraunces for headlines, Inter for UI and
/// body. Sizes and families live here and nowhere else.
sealed class AppTextStyles {
  static const String _display = 'Fraunces';
  static const String _ui = 'Inter';

  /// Screen titles (Home, Explore, Saved, Settings).
  static const TextStyle displayXL = TextStyle(
    fontFamily: _display,
    fontSize: 40,
    height: 44 / 40,
    fontWeight: FontWeight.w600,
    letterSpacing: -1,
  );

  /// Lead story headline, article title.
  static const TextStyle displayL = TextStyle(
    fontFamily: _display,
    fontSize: 30,
    height: 34 / 30,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.6,
  );

  /// Standard card headline.
  static const TextStyle headlineM = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    height: 27 / 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  /// Compact card, related story, tile title.
  static const TextStyle headlineS = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    height: 23 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  /// Pull quotes.
  static const TextStyle quote = TextStyle(
    fontFamily: _display,
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.2,
  );

  /// Article body, standfirst.
  static const TextStyle body = TextStyle(
    fontFamily: _ui,
    fontSize: 16,
    height: 26 / 16,
    fontWeight: FontWeight.w400,
  );

  /// Card summary.
  static const TextStyle bodyS = TextStyle(
    fontFamily: _ui,
    fontSize: 14,
    height: 21 / 14,
    fontWeight: FontWeight.w400,
  );

  /// Buttons, pills, tab labels.
  static const TextStyle label = TextStyle(
    fontFamily: _ui,
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w600,
  );

  /// Drop cap on the first paragraph of an article body.
  static const TextStyle dropCap = TextStyle(
    fontFamily: _display,
    fontSize: 64,
    height: 0.85,
    fontWeight: FontWeight.w600,
  );

  /// Timestamps, bylines, captions.
  static const TextStyle caption = TextStyle(
    fontFamily: _ui,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  /// Section tags, dates, group headers. Callers uppercase the string.
  static const TextStyle overline = TextStyle(
    fontFamily: _ui,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
  );
}
