import 'package:flutter/material.dart';

/// Colour tokens. Every colour a widget uses resolves through one of these,
/// either statically or via [AppPalette] on the current theme.
sealed class AppColors {
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF3F3F5);
  static const Color lightSurfaceHigh = Color(0xFFE8E8EC);
  static const Color lightInk = Color(0xFF0F0F12);
  static const Color lightInkMuted = Color(0xFF5B5C66);
  static const Color lightInkFaint = Color(0xFF8E8F99);
  static const Color lightOutline = Color(0xFFDDDDE2);
  static const Color lightAccent = Color(0xFFCF3520);
  static const Color lightAccentSoft = Color(0xFFFBE9E5);
  static const Color lightSuccess = Color(0xFF1F7A4D);
  static const Color lightWarning = Color(0xFF8A5A0B);

  static const Color darkBackground = Color(0xFF0B0B0D);
  static const Color darkSurface = Color(0xFF17171B);
  static const Color darkSurfaceHigh = Color(0xFF232329);
  static const Color darkInk = Color(0xFFF5F5F7);
  static const Color darkInkMuted = Color(0xFFA5A6B0);
  static const Color darkInkFaint = Color(0xFF6E6F79);
  static const Color darkOutline = Color(0xFF2C2C33);
  static const Color darkAccent = Color(0xFFFF6B52);
  static const Color darkAccentSoft = Color(0xFF3A1C16);
  static const Color darkSuccess = Color(0xFF5CC489);
  static const Color darkWarning = Color(0xFFE2B04A);

  // Section tints — topic tags, browse tiles, onboarding selection.
  static const Color lightTintTechnology = Color(0xFF2F5FD0);
  static const Color lightTintBusiness = Color(0xFF9A6A00);
  static const Color lightTintSports = Color(0xFF1F7A4D);
  static const Color lightTintScience = Color(0xFF6A4BD8);
  static const Color lightTintHealth = Color(0xFFC0392B);
  static const Color lightTintCulture = Color(0xFF9B3B8B);

  static const Color darkTintTechnology = Color(0xFF7FA3FF);
  static const Color darkTintBusiness = Color(0xFFE3B95B);
  static const Color darkTintSports = Color(0xFF5CC489);
  static const Color darkTintScience = Color(0xFFB39CFF);
  static const Color darkTintHealth = Color(0xFFFF7F72);
  static const Color darkTintCulture = Color(0xFFDD8AD0);

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

  /// Section tint for a topic name, falling back to muted ink for topics
  /// outside the six core sections.
  static Color sectionTint(String topicName, Brightness brightness) {
    final tints = brightness == Brightness.light ? _lightTints : _darkTints;
    return tints[topicName] ??
        (brightness == Brightness.light ? lightInkMuted : darkInkMuted);
  }
}

/// The resolved palette for the current brightness, exposed as a theme
/// extension so widgets read `context.palette.ink` instead of branching on
/// brightness themselves.
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color surfaceHigh;
  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color outline;
  final Color accent;
  final Color accentSoft;
  final Color success;
  final Color warning;
  final Brightness brightness;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.outline,
    required this.accent,
    required this.accentSoft,
    required this.success,
    required this.warning,
    required this.brightness,
  });

  static const light = AppPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceHigh: AppColors.lightSurfaceHigh,
    ink: AppColors.lightInk,
    inkMuted: AppColors.lightInkMuted,
    inkFaint: AppColors.lightInkFaint,
    outline: AppColors.lightOutline,
    accent: AppColors.lightAccent,
    accentSoft: AppColors.lightAccentSoft,
    success: AppColors.lightSuccess,
    warning: AppColors.lightWarning,
    brightness: Brightness.light,
  );

  static const dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceHigh: AppColors.darkSurfaceHigh,
    ink: AppColors.darkInk,
    inkMuted: AppColors.darkInkMuted,
    inkFaint: AppColors.darkInkFaint,
    outline: AppColors.darkOutline,
    accent: AppColors.darkAccent,
    accentSoft: AppColors.darkAccentSoft,
    success: AppColors.darkSuccess,
    warning: AppColors.darkWarning,
    brightness: Brightness.dark,
  );

  bool get isLight => brightness == Brightness.light;

  /// Text/icon colour that reads on top of a photo scrim.
  Color get onImage => AppColors.white;

  Color sectionTint(String topicName) =>
      AppColors.sectionTint(topicName, brightness);

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      brightness: t < 0.5 ? brightness : other.brightness,
    );
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      (Theme.of(this).brightness == Brightness.light
          ? AppPalette.light
          : AppPalette.dark);
}
