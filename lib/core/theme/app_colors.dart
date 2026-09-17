import 'package:flutter/material.dart';

/// "The Edition" colour tokens (Part 6.1). No `Color(0x…)` literal may
/// appear anywhere else in the app — every colour used by a widget must
/// resolve through one of these tokens.
sealed class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color lightPaper = Color(0xFFF7F3EA);
  static const Color lightPaperRaised = Color(0xFFFFFDF8);
  static const Color lightInk = Color(0xFF141311);
  static const Color lightInkMuted = Color(0xFF5C5852);
  static const Color lightInkFaint = Color(0xFF9C968C);
  static const Color lightRule = Color(0xFFD9D3C6);
  static const Color lightRuleStrong = Color(0xFF141311);
  static const Color lightRed = Color(0xFFC8321E);
  static const Color lightRedSoft = Color(0xFFF6E4E0);
  static const Color lightSuccess = Color(0xFF2F6B4F);
  static const Color lightWarning = Color(0xFF9A6B12);

  static const Color darkPaper = Color(0xFF121110);
  static const Color darkPaperRaised = Color(0xFF1A1917);
  static const Color darkInk = Color(0xFFEFE9DC);
  static const Color darkInkMuted = Color(0xFFA39D93);
  static const Color darkInkFaint = Color(0xFF6B665E);
  static const Color darkRule = Color(0xFF2A2825);
  static const Color darkRuleStrong = Color(0xFFEFE9DC);
  static const Color darkRed = Color(0xFFE5533E);
  static const Color darkRedSoft = Color(0xFF3A1F1B);
  static const Color darkSuccess = Color(0xFF6FB58F);
  static const Color darkWarning = Color(0xFFD9A441);

  // Section tints — used for topic tag text/rule only, never large fills
  // except onboarding tiles (Part 6.1).
  static const Color lightTintTechnology = Color(0xFF345E8C);
  static const Color lightTintBusiness = Color(0xFF8A6A1E);
  static const Color lightTintSports = Color(0xFF2F6B4F);
  static const Color lightTintScience = Color(0xFF5A4C8C);
  static const Color lightTintHealth = Color(0xFFB04E3C);
  static const Color lightTintCulture = Color(0xFF7A3E6B);

  static const Color darkTintTechnology = Color(0xFF7FA9D6);
  static const Color darkTintBusiness = Color(0xFFD2B15C);
  static const Color darkTintSports = Color(0xFF6FB58F);
  static const Color darkTintScience = Color(0xFFA497D6);
  static const Color darkTintHealth = Color(0xFFE0876F);
  static const Color darkTintCulture = Color(0xFFC58AB6);

  static const Map<String, Color> _lightTints = {
    'Technology': lightTintTechnology,
    'Business': lightTintBusiness,
    'Sports': lightTintSports,
    'Science': lightTintScience,
    'Health': lightTintHealth,
    'Culture': lightTintCulture,
  };

  static const Map<String, Color> _darkTints = {
    'Technology': darkTintTechnology,
    'Business': darkTintBusiness,
    'Sports': darkTintSports,
    'Science': darkTintScience,
    'Health': darkTintHealth,
    'Culture': darkTintCulture,
  };

  /// Section tint for a topic name, falling back to [inkMuted] for topics
  /// not in the six core sections.
  static Color sectionTint(String topicName, Brightness brightness) {
    final tints = brightness == Brightness.light ? _lightTints : _darkTints;
    return tints[topicName] ?? (brightness == Brightness.light ? lightInkMuted : darkInkMuted);
  }

  // Legacy aliases kept until the remaining screens are restyled
  // (onboarding, saved list, shimmer, topic picker, offline banner,
  // engagement row). Kept only so those files keep resolving colours
  // through `AppColors` instead of a literal until they are rewritten.
  static const Color warning = lightWarning;
  static const Color success = lightSuccess;
  static const Color error = lightRed;
  static const Color liked = lightRed;
  static const Color lightAccent = lightRed;
  static const Color darkAccent = darkRed;
  static const Color lightBackground = lightPaper;
  static const Color darkBackground = darkPaper;
  static const Color lightCardBackground = lightPaperRaised;
  static const Color darkCardBackground = darkPaperRaised;
  static const Color lightShimmerBase = lightRule;
  static const Color darkShimmerBase = darkRule;
  static const Color lightShimmerHighlight = lightPaperRaised;
  static const Color darkShimmerHighlight = darkPaperRaised;
}
