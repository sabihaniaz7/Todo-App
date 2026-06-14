import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase/theme/app_colors.dart';
import 'package:flutter_firebase/theme/app_sizes.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: isDark ? AppColors.darkBackground : Colors.white,
      primaryContainer: isDark
          ? AppColors.primarySurfaceDark
          : AppColors.primarySurface,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      secondaryContainer: isDark ? AppColors.darkCard : AppColors.lightCard,
      onSecondaryContainer: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      surface: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onSurface: isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary,
      surfaceContainerHighest: isDark
          ? AppColors.darkCard
          : AppColors.lightCard,
      error: AppColors.danger,
      onError: Colors.white,
      outline: isDark ? AppColors.darkBorder : AppColors.lightBorder,
    );
    // Build base typography setup to map font asset globally across standard text strings
    final typography = Typography.material2021(
      platform: TargetPlatform.android,
    );
    final baseTextTheme =
        (brightness == Brightness.light ? typography.black : typography.white)
            .apply(fontFamily: 'Nunito');
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      textTheme: baseTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors
              .transparent, // Ensures seamless notification bar backgrounds
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          fontSize: AppSizes.fontXxl,
          fontWeight: FontWeight.w800,
          fontFamily: 'Nunito',
        ),
        iconTheme: IconThemeData(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        thickness: 1,
        space: 0,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkCard : AppColors.lightBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
          fontSize: AppSizes.fontMd,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.md,
        ),
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.xs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            // Contrast Check: Keep thumb bright white when sliding over pastel lavender track
            return isDark ? AppColors.darkSurface : Colors.white;
          }
          return isDark ? AppColors.darkTextSecondary : Colors.grey[400];
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return isDark ? AppColors.darkCard : Colors.grey[200];
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        ),
        titleTextStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextPrimary
              : AppColors.lightTextPrimary,
          fontSize: AppSizes.fontXl,
          fontWeight: FontWeight.w700,
          fontFamily: 'Nunito',
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        backgroundColor: isDark
            ? AppColors.darkCard
            : AppColors.lightTextPrimary,
      ),
    );
  }
}
