import 'package:flutter/material.dart';

/// "The Edition" type scale (Part 6.2). Two faces only: Fraunces for
/// display/headlines, Inter for UI/body. No `fontFamily:` string or
/// `TextStyle(fontSize: …)` literal may appear outside this file.
sealed class AppTextStyles {
  static const String _display = 'Fraunces';
  static const String _ui = 'Inter';

  /// "The Edition" wordmark.
  static const TextStyle masthead = TextStyle(
    fontFamily: _display,
    fontSize: 26,
    height: 30 / 26,
    fontWeight: FontWeight.w700,
  );

  /// Lead story headline, details title.
  static const TextStyle displayL = TextStyle(
    fontFamily: _display,
    fontSize: 34,
    height: 38 / 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// Standard card headline.
  static const TextStyle headlineM = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    height: 27 / 22,
    fontWeight: FontWeight.w600,
  );

  /// Brief card, related story.
  static const TextStyle headlineS = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    height: 23 / 18,
    fontWeight: FontWeight.w600,
  );

  /// Pull quotes.
  static const TextStyle quote = TextStyle(
    fontFamily: _display,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
  );

  /// Article body, summaries.
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
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  /// Buttons, chips.
  static const TextStyle label = TextStyle(
    fontFamily: _ui,
    fontSize: 13,
    height: 16 / 13,
    fontWeight: FontWeight.w500,
  );

  /// The drop cap on the first paragraph of every article body — roughly
  /// three `body` lines tall (Part 6.2). Colour is applied by the caller
  /// (always `red`).
  static const TextStyle dropCap = TextStyle(
    fontFamily: _display,
    fontSize: 68,
    height: 0.85,
    fontWeight: FontWeight.w700,
  );

  /// Timestamps, captions.
  static const TextStyle caption = TextStyle(
    fontFamily: _ui,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
  );

  /// Section tags, dates, "TRENDING". Callers must uppercase the string
  /// themselves — `TextStyle` has no text-transform.
  static const TextStyle overline = TextStyle(
    fontFamily: _ui,
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.4,
  );
}
