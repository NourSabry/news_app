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

    final background = isLight ? AppColors.lightBackground : AppColors.darkBackground;
    final surface = isLight ? AppColors.lightSurface : AppColors.darkSurface;
    final textPrimary = isLight ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSecondary = isLight ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final accent = isLight ? AppColors.lightAccent : AppColors.darkAccent;
    final divider = isLight ? AppColors.lightDivider : AppColors.darkDivider;
    final navBarBg = isLight ? AppColors.lightNavBarBackground : AppColors.darkNavBarBackground;
    final navBarSelected = isLight ? AppColors.lightNavBarSelected : AppColors.darkNavBarSelected;
    final navBarUnselected = isLight ? AppColors.lightNavBarUnselected : AppColors.darkNavBarUnselected;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: AppColors.white,
      secondary: accent,
      onSecondary: AppColors.white,
      error: AppColors.error,
      onError: AppColors.white,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: divider,
      shadow: AppColors.black.withValues(alpha: isLight ? 0.06 : 0.3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(color: textPrimary),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBarBg,
        selectedItemColor: navBarSelected,
        unselectedItemColor: navBarUnselected,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),
      cardTheme: CardThemeData(
        color: isLight ? AppColors.lightCardBackground : AppColors.darkCardBackground,
        elevation: isLight ? 0.5 : 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: isLight ? BorderSide.none : BorderSide(color: divider, width: 0.5),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? AppColors.lightSearchBar : AppColors.darkSearchBar,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isLight ? AppColors.lightChipBackground : AppColors.darkChipBackground,
        selectedColor: isLight ? AppColors.lightChipSelected : AppColors.darkChipSelected,
        labelStyle: AppTextStyles.labelMedium.copyWith(color: textPrimary),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: isLight ? AppColors.lightChipTextSelected : AppColors.darkChipTextSelected,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? AppColors.lightTextPrimary : AppColors.darkCardBackground,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: isLight ? AppColors.white : AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
        behavior: SnackBarBehavior.floating,
      ),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textPrimary),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: textPrimary),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textPrimary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textPrimary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: textSecondary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: textSecondary),
      ),
    );
  }
}
