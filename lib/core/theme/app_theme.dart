import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/constants.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.light,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.accentColor,
      tertiary: AppConstants.tertiaryColor,
      background: AppConstants.lightScaffoldBg,
      surface: AppConstants.cardColor,
      shadow: AppConstants.shadowColor,
    ),
    scaffoldBackgroundColor: AppConstants.lightScaffoldBg,
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: AppConstants.shadowColor,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppConstants.lightScaffoldBg,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(color: AppConstants.primaryColor),
      titleTextStyle: TextStyle(
        color: AppConstants.textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(2),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppConstants.primaryColor.withOpacity(0.3);
          }
          return AppConstants.primaryColor;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppConstants.cardColor,
      indicatorColor: AppConstants.primaryColor.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppConstants.primaryColor,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: AppConstants.primaryColor, size: 24);
        }
        return IconThemeData(
          color: AppConstants.textColor.withOpacity(0.6),
          size: 24,
        );
      }),
      elevation: 8,
      shadowColor: AppConstants.shadowColor,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppConstants.accentColor,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppConstants.primaryColor,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppConstants.cardColor,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.cardColor,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontSize: 32,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontSize: 28,
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontSize: 24,
        letterSpacing: 0.5,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColor,
        fontSize: 22,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColor,
        fontSize: 20,
        letterSpacing: 0.25,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColor,
        fontSize: 18,
        letterSpacing: 0.25,
      ),
      bodyLarge: TextStyle(
        color: AppConstants.textColor,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: AppConstants.textColor,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: AppConstants.textColor.withOpacity(0.8),
        fontSize: 12,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppConstants.textColor,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.dark,
      primary: AppConstants.primaryColorDark,
      secondary: AppConstants.accentColorDark,
      tertiary: AppConstants.tertiaryColorDark,
      background: AppConstants.darkScaffoldBg,
      surface: AppConstants.cardColorDark,
      shadow: AppConstants.shadowColorDark,
    ),
    scaffoldBackgroundColor: AppConstants.darkScaffoldBg,
    cardTheme: CardTheme(
      elevation: 4,
      shadowColor: AppConstants.shadowColorDark,
      color: AppConstants.cardColorDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppConstants.darkScaffoldBg,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: AppConstants.primaryColorDark),
      titleTextStyle: TextStyle(
        color: AppConstants.textColorDark,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        elevation: MaterialStateProperty.all(2),
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled)) {
            return AppConstants.primaryColorDark.withOpacity(0.3);
          }
          return AppConstants.primaryColorDark;
        }),
        foregroundColor: MaterialStateProperty.all(Colors.white),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        side: MaterialStateProperty.all(
          BorderSide(color: AppConstants.primaryColorDark, width: 2),
        ),
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.baseRadius),
          ),
        ),
        animationDuration: AppConstants.standardAnimation,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppConstants.cardColorDark,
      indicatorColor: AppConstants.primaryColorDark.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppConstants.primaryColorDark,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: AppConstants.primaryColorDark, size: 24);
        }
        return IconThemeData(
          color: AppConstants.textColorDark.withOpacity(0.6),
          size: 24,
        );
      }),
      elevation: 8,
      shadowColor: AppConstants.shadowColorDark,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppConstants.accentColorDark,
      foregroundColor: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppConstants.primaryColorDark,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppConstants.cardColorDark,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppConstants.cardColorDark,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.baseRadius),
        borderSide: BorderSide(color: AppConstants.primaryColorDark, width: 2),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColorDark,
        fontSize: 32,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColorDark,
        fontSize: 28,
        letterSpacing: 0.5,
      ),
      displaySmall: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColorDark,
        fontSize: 24,
        letterSpacing: 0.5,
      ),
      headlineLarge: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppConstants.textColorDark,
        fontSize: 22,
        letterSpacing: 0.5,
      ),
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColorDark,
        fontSize: 20,
        letterSpacing: 0.25,
      ),
      headlineSmall: TextStyle(
        fontWeight: FontWeight.w600,
        color: AppConstants.textColorDark,
        fontSize: 18,
        letterSpacing: 0.25,
      ),
      bodyLarge: TextStyle(
        color: AppConstants.textColorDark,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        color: AppConstants.textColorDark,
        fontSize: 14,
        letterSpacing: 0.25,
      ),
      bodySmall: TextStyle(
        color: AppConstants.textColorDark.withOpacity(0.8),
        fontSize: 12,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        fontWeight: FontWeight.w500,
        color: AppConstants.textColorDark,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    ),
  );

  static ThemeData getTheme(bool isDarkMode) {
    return isDarkMode ? darkTheme : lightTheme;
  }
}
