import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Solo Leveling-inspired color palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color accentBlue = Color(0xFF64B5F6);
  static const Color glowBlue = Color(0xFF29B6F6);
  static const Color darkBlue = Color(0xFF0D47A1);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF252525);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFB0B0B0);

  // Rank colors
  static const Color rankE = Color(0xFF90A4AE); // Gray
  static const Color rankD = Color(0xFF4CAF50); // Green
  static const Color rankC = Color(0xFF2196F3); // Blue
  static const Color rankB = Color(0xFF9C27B0); // Purple
  static const Color rankA = Color(0xFFFF9800); // Orange
  static const Color rankS = Color(0xFFFF5252); // Red

  // Gradient for special elements
  static const Gradient blueGradient = LinearGradient(
    colors: [primaryBlue, accentBlue, glowBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Theme data
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: backgroundDark,
    primaryColor: primaryBlue,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentBlue,
      background: backgroundDark,
      surface: surfaceDark,
      onPrimary: textPrimary,
      onSecondary: textPrimary,
      onBackground: textPrimary,
      onSurface: textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    cardTheme: CardTheme(
      color: cardDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textSecondary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12,
        color: textSecondary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textPrimary,
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accentBlue,
      ),
    ),
    iconTheme: const IconThemeData(
      color: textPrimary,
      size: 24,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryBlue,
    ),
  );

  static var darkBackgroundSecondary;
}
