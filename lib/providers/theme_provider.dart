import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling/config/constatnts.dart';
import '../config/theme.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode =
      ThemeMode.dark; // Default to dark for Solo Leveling aesthetic
  bool _isDarkMode = true;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;

  // Theme data for dark mode (Solo Leveling)
  ThemeData get darkTheme => AppTheme.darkTheme;

  // Theme data for light mode (fallback, not recommended)
  // ThemeData get lightTheme => AppTheme.lightTheme;

  // Initialize theme from saved preferences
  ThemeProvider() {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? isDarkMode = prefs.getBool(AppConstants.keyDarkModeEnabled);

    // Default to dark mode if no preference is saved
    if (isDarkMode == null || isDarkMode) {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
    }

    notifyListeners();
  }

  // Toggle between dark and light mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
    } else {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
    }

    // Save preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkModeEnabled, _isDarkMode);

    notifyListeners();
  }

  // Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;

    // Save preference
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkModeEnabled, _isDarkMode);

    notifyListeners();
  }

  // Get text color based on current theme
  Color getTextColor() {
    return _isDarkMode ? AppConstants.textPrimary : Colors.black;
  }

  // Get secondary text color based on current theme
  Color getSecondaryTextColor() {
    return _isDarkMode ? AppConstants.textSecondary : Colors.grey[700]!;
  }

  // Get background color based on current theme
  Color getBackgroundColor() {
    return _isDarkMode ? AppConstants.backgroundDark : Colors.white;
  }

  // Get card background color based on current theme
  Color getCardColor() {
    return _isDarkMode ? AppConstants.cardBackground : Colors.grey[100]!;
  }

  // Get primary color (always blue for Solo Leveling theme regardless of mode)
  Color getPrimaryColor() {
    return AppConstants.primaryColor;
  }

  // Get current rank color
  Color getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'E':
        return AppConstants.rankE;
      case 'D':
        return AppConstants.rankD;
      case 'C':
        return AppConstants.rankC;
      case 'B':
        return AppConstants.rankB;
      case 'A':
        return AppConstants.rankA;
      case 'S':
        return AppConstants.rankS;
      default:
        return AppConstants.rankE;
    }
  }

  // Get exercise category color
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'strength':
        return AppConstants.strengthColor;
      case 'cardio':
        return AppConstants.cardioColor;
      case 'flexibility':
        return AppConstants.flexibilityColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  // Get appropriate shadow for current theme
  List<BoxShadow>? getShadow({bool intense = false}) {
    if (!_isDarkMode) {
      // Light mode shadows
      if (intense) {
        return [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ];
      } else {
        return [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ];
      }
    } else {
      // Dark mode shadows (more subtle)
      if (intense) {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ];
      } else {
        return [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ];
      }
    }
  }

  // Get glow effect for buttons and important elements
  BoxDecoration getGlowDecoration({Color? color}) {
    final glowColor = color ?? AppConstants.primaryColor;

    return BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: glowColor.withOpacity(0.5),
          spreadRadius: 1,
          blurRadius: 16,
          offset: const Offset(0, 0),
        ),
      ],
    );
  }

  // Get background decoration based on user rank
  BoxDecoration getRankBackgroundDecoration(String rank) {
    final Color rankColor = getRankColor(rank);

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          _isDarkMode ? AppConstants.backgroundDark : Colors.white,
          _isDarkMode
              ? rankColor.withOpacity(0.15)
              : rankColor.withOpacity(0.05),
        ],
      ),
    );
  }

  // Get button decoration based on theme
  BoxDecoration getPrimaryButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppConstants.primaryLightColor,
          AppConstants.primaryColor,
          AppConstants.primaryDarkColor,
        ],
      ),
      borderRadius: BorderRadius.circular(AppConstants.buttonBorderRadius),
      boxShadow: [
        BoxShadow(
          color: AppConstants.primaryColor.withOpacity(0.4),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
