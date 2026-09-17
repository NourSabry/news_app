import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

sealed class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    final paper = isLight ? AppColors.lightPaper : AppColors.darkPaper;
    final paperRaised = isLight ? AppColors.lightPaperRaised : AppColors.darkPaperRaised;
    final ink = isLight ? AppColors.lightInk : AppColors.darkInk;
    final inkMuted = isLight ? AppColors.lightInkMuted : AppColors.darkInkMuted;
    final rule = isLight ? AppColors.lightRule : AppColors.darkRule;
    final red = isLight ? AppColors.lightRed : AppColors.darkRed;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: red,
      onPrimary: AppColors.white,
      secondary: ink,
      onSecondary: paper,
      error: red,
      onError: AppColors.white,
      surface: paper,
      onSurface: ink,
      onSurfaceVariant: inkMuted,
      outline: rule,
      shadow: AppColors.black.withValues(alpha: isLight ? 0.06 : 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: paper,
      dividerColor: rule,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineS.copyWith(color: ink),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardThemeData(
        color: paperRaised,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          side: BorderSide(color: rule, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: paperRaised,
        hintStyle: AppTextStyles.body.copyWith(color: inkMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          borderSide: BorderSide(color: rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          borderSide: BorderSide(color: rule),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusImage),
          borderSide: BorderSide(color: ink, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: AppTextStyles.body.copyWith(color: paper),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusImage)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayL.copyWith(color: ink),
        headlineLarge: AppTextStyles.displayL.copyWith(color: ink),
        headlineMedium: AppTextStyles.headlineM.copyWith(color: ink),
        headlineSmall: AppTextStyles.headlineS.copyWith(color: ink),
        titleLarge: AppTextStyles.headlineS.copyWith(color: ink),
        titleMedium: AppTextStyles.label.copyWith(color: ink),
        bodyLarge: AppTextStyles.body.copyWith(color: ink),
        bodyMedium: AppTextStyles.bodyS.copyWith(color: ink),
        bodySmall: AppTextStyles.caption.copyWith(color: inkMuted),
        labelLarge: AppTextStyles.label.copyWith(color: ink),
        labelMedium: AppTextStyles.caption.copyWith(color: inkMuted),
        labelSmall: AppTextStyles.overline.copyWith(color: inkMuted),
      ),
    );
  }
}
