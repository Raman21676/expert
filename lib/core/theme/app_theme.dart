import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme Configuration
///
/// Defines light and dark themes for the application
class AppTheme {
  // Brand Colors - Instagram-inspired Gradient Theme
  static const Color primaryColor = Color(0xFFE91E63); // Vibrant Pink
  static const Color primaryDark = Color(0xFF9C27B0); // Deep Purple
  static const Color primaryLight = Color(0xFFF06292); // Light Pink

  static const Color secondaryColor = Color(0xFFFF6F00); // Vibrant Orange
  static const Color accentColor = Color(0xFFFFC107); // Warm Amber

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0)], // Pink to Purple
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6F00), Color(0xFFFFC107)], // Orange to Amber
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient instagramGradient = LinearGradient(
    colors: [
      Color(0xFFFD5949), // Red
      Color(0xFFD6249F), // Pink
      Color(0xFF285AEB), // Blue
    ],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
        surfaceContainerHighest: Color(0xFFF8FAFC),
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1E293B),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF1E293B),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: primaryLight,
        secondary: secondaryColor,
        surface: Color(0xFF1E293B),
        surfaceContainerHighest: Color(0xFF0F172A),
        error: Color(0xFFFCA5A5),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFFF1F5F9),
      ),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF1E293B),
        foregroundColor: Color(0xFFF1F5F9),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryLight, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Build text theme using Google Fonts
  static TextTheme _buildTextTheme(Brightness brightness) {
    final baseTextTheme = GoogleFonts.interTextTheme();
    final color = brightness == Brightness.light
        ? const Color(0xFF1E293B)
        : const Color(0xFFF1F5F9);

    return baseTextTheme.copyWith(
      displayLarge: baseTextTheme.displayLarge?.copyWith(color: color),
      displayMedium: baseTextTheme.displayMedium?.copyWith(color: color),
      displaySmall: baseTextTheme.displaySmall?.copyWith(color: color),
      headlineLarge: baseTextTheme.headlineLarge?.copyWith(color: color),
      headlineMedium: baseTextTheme.headlineMedium?.copyWith(color: color),
      headlineSmall: baseTextTheme.headlineSmall?.copyWith(color: color),
      titleLarge: baseTextTheme.titleLarge?.copyWith(color: color),
      titleMedium: baseTextTheme.titleMedium?.copyWith(color: color),
      titleSmall: baseTextTheme.titleSmall?.copyWith(color: color),
      bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: color),
      bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: color),
      bodySmall: baseTextTheme.bodySmall?.copyWith(color: color),
    );
  }
}
