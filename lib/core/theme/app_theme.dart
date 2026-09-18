import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

sealed class AppTheme {
  static ThemeData get light => _buildTheme(AppPalette.light);
  static ThemeData get dark => _buildTheme(AppPalette.dark);

  static ThemeData _buildTheme(AppPalette p) {
    // Every role is mapped to a token so stock widgets we still rely on
    // (Switch, dialogs, date picker) never fall back to Material defaults.
    final colorScheme = ColorScheme(
      brightness: p.brightness,
      primary: p.ink,
      onPrimary: p.background,
      primaryContainer: p.surface,
      onPrimaryContainer: p.ink,
      secondary: p.accent,
      onSecondary: AppColors.white,
      secondaryContainer: p.accentSoft,
      onSecondaryContainer: p.ink,
      tertiary: p.accent,
      onTertiary: AppColors.white,
      error: p.accent,
      onError: AppColors.white,
      errorContainer: p.accentSoft,
      onErrorContainer: p.ink,
      surface: p.background,
      onSurface: p.ink,
      surfaceDim: p.surface,
      surfaceBright: p.background,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surfaceHigh,
      surfaceContainerHighest: p.surfaceHigh,
      onSurfaceVariant: p.inkMuted,
      outline: p.outline,
      outlineVariant: p.outline,
      shadow: AppColors.black.withValues(alpha: p.isLight ? 0.08 : 0.4),
      scrim: AppColors.black.withValues(alpha: 0.5),
      inverseSurface: p.ink,
      onInverseSurface: p.background,
      inversePrimary: p.background,
      surfaceTint: Colors.transparent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      extensions: [p],
      scaffoldBackgroundColor: p.background,
      dividerColor: Colors.transparent,
      splashFactory: InkSparkle.splashFactory,
      splashColor: p.ink.withValues(alpha: 0.06),
      highlightColor: p.ink.withValues(alpha: 0.04),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineS.copyWith(color: p.ink),
        systemOverlayStyle: p.isLight
            ? SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: Colors.transparent,
              )
            : SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
              ),
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        showDragHandle: false,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: AppTextStyles.body.copyWith(color: p.inkFaint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: p.ink, width: 1.5),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: AppTextStyles.bodyS.copyWith(color: p.background),
        actionTextColor: p.isLight
            ? AppColors.darkAccent
            : AppColors.lightAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.background : p.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? p.ink : p.surfaceHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXL.copyWith(color: p.ink),
        headlineLarge: AppTextStyles.displayL.copyWith(color: p.ink),
        headlineMedium: AppTextStyles.headlineM.copyWith(color: p.ink),
        headlineSmall: AppTextStyles.headlineS.copyWith(color: p.ink),
        titleLarge: AppTextStyles.headlineS.copyWith(color: p.ink),
        titleMedium: AppTextStyles.label.copyWith(color: p.ink),
        bodyLarge: AppTextStyles.body.copyWith(color: p.ink),
        bodyMedium: AppTextStyles.bodyS.copyWith(color: p.ink),
        bodySmall: AppTextStyles.caption.copyWith(color: p.inkMuted),
        labelLarge: AppTextStyles.label.copyWith(color: p.ink),
        labelMedium: AppTextStyles.caption.copyWith(color: p.inkMuted),
        labelSmall: AppTextStyles.overline.copyWith(color: p.inkMuted),
      ),
    );
  }
}
