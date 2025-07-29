import 'package:flutter/material.dart';

class AppConstants {
  /// Interval for background sync in minutes
  static const int syncIntervalMinutes = 15;
  static const String appLogo = 'assets/logo/logo.png';
  // DataNest Modern, Solid, Eye-catching Color Palette
  // --- Main Backgrounds ---
  static const Color backgroundColor = Color(0xFFF6F8FC); // Very light blue
  static const Color surfaceColor = Color(0xFFFFFFFF); // White

  // --- Primary Colors ---
  static const Color primaryColor = Color(0xFF3A5AFF); // Vivid Blue
  static const Color primaryDark = Color(0xFF1A237E); // Deep Blue
  static const Color primaryLight = Color(0xFF6C8CFF); // Lighter Blue

  // --- Secondary Colors ---
  static const Color secondaryColor = Color(0xFFFFC542); // Bright Yellow/Gold
  static const Color secondaryDark = Color(0xFFFFA000); // Strong Amber
  static const Color secondaryLight = Color(0xFFFFE082); // Soft Yellow

  // --- Accent Colors ---
  static const Color accentColor = Color(0xFFFF3366); // Eye-catching Pink
  static const Color accentDark = Color(0xFFB8003A); // Deep Pink
  static const Color accentLight = Color(0xFFFF7CA3); // Light Pink

  // --- Neutral Colors ---
  static const Color background = Color(0xFFF6F8FC); // Very light blue
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color card = Color(0xFFF0F4FF); // Card light blue
  static const Color divider = Color(0xFFE0E3E7); // Light divider

  // --- Text Colors ---
  static const Color textPrimary = Color(0xFF232946); // Deep Navy
  static const Color textSecondary = Color(0xFF6B7280); // Muted Gray
  static const Color textTertiary = Color(0xFFBFC6D1); // Pale Gray
  static const Color textInverse = Color(0xFFFFFFFF); // White

  // --- Status Colors ---
  static const Color success = Color(0xFF00C48C); // Green Accent
  static const Color warning = Color(0xFFFFB300); // Amber
  static const Color error = Color(0xFFFF5252); // Red Accent
  static const Color info = Color(0xFF40C4FF); // Light Blue

  // --- Meal Colors (for demo/placeholder, can be used for tags, etc.) ---
  static const Color breakfast = Color(0xFFFFB86B); // Orange
  static const Color lunch = Color(0xFF4ECDC4); // Teal
  static const Color dinner = Color(0xFF3A5AFF); // Blue (matches primary)

  // --- Payment/Status Colors ---
  static const Color paid = Color(0xFF00C48C); // Green
  static const Color unpaid = Color(0xFFFF3366); // Pink/Red
  static const Color overdue = Color(0xFFD7263D); // Strong Red
  static const Color pending = Color(0xFFFFC542); // Yellow/Gold

  static const double borderRadius = 12.0;
  static const double padding = 24.0;
  static const Color inputFillColor =
      Color(0xFFF5F6FA); // Light input background

  // Modern Light Theme (No Shadows, Solid Colors)
  static ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      background: backgroundColor,
      surface: surfaceColor,
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: textPrimary,
      onSurface: textPrimary,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 0, // No shadow
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: secondaryColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    ),
    textTheme: TextTheme(
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyMedium: TextStyle(
        color: textPrimary,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: textSecondary,
        fontSize: 14,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0, // No shadow
    ),
    cardTheme: CardTheme(
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0, // No shadow
    ),
  );

  // Modern Dark Theme (No Shadows, Solid Colors)
  static ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      background: Color(0xFF232946), // Deep Navy
      surface: Color(0xFF2E2E48), // Slightly lighter navy
      error: error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onBackground: Colors.white,
      onSurface: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF232946),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 22,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 1.1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        elevation: 0, // No shadow
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentColor,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2E2E48),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: secondaryColor, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white54),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
      ),
      bodyMedium: TextStyle(
        color: Colors.white,
        fontSize: 16,
      ),
      bodySmall: TextStyle(
        color: Colors.white70,
        fontSize: 14,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0, // No shadow
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF2E2E48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0, // No shadow
    ),
  );
}

class AppSizes {
  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border Radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Icon Sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
}

class AppStrings {
  // App
  static const String appName = 'DataNest';
  static const String appVersion = '1.0.0';
  static const String slogan = 'Structure anything, anywhere!';

  // Authentication
  static const String signIn = 'Sign In';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String signOut = 'Sign Out';
  static const String createAccount = 'Create an account';
  static const String alreadyHaveAccount = 'Already have an account? Sign In';

  // General
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String remove = 'Remove';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String submit = 'Submit';

  // Messages
  static const String successMessage = 'Operation completed successfully';
  static const String errorMessage = 'Something went wrong';
  static const String loadingMessage = 'Loading...';
  static const String noDataMessage = 'No data available';

  // Validation
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordMismatch = 'Passwords do not match';
  static const String weakPassword = 'Password is too weak';
}
