import 'package:flutter/material.dart';

class AppConstants {
  // App Name
  static const String appName = "Solo Fitness";

  // Theme Colors - Solo Leveling inspired
  static const Color primaryColor = Color(0xFF2E7BFF); // Main blue accent
  static const Color primaryDarkColor = Color(0xFF1565C0); // Darker blue
  static const Color primaryLightColor = Color(0xFF5E9FFF); // Lighter blue
  static const Color accentColor = Color(0xFF6D42FF); // Purple accent

  // Background Colors
  static const Color backgroundDark =
      Color(0xFF121212); // Primary dark background
  static const Color backgroundMedium =
      Color(0xFF1E1E1E); // Secondary dark background
  static const Color backgroundLight =
      Color(0xFF2D2D2D); // Lighter dark background
  static const Color cardBackground = Color(0xFF252525); // Card background

  // Text Colors
  static const Color textPrimary =
      Color(0xFFFFFFFF); // Primary text color (white)
  static const Color textSecondary =
      Color(0xFFB0B0B0); // Secondary text color (gray)
  static const Color textDisabled = Color(0xFF666666); // Disabled text color
  static const Color disabledTextColor =
      Color(0xFF777777); // Disabled element text
  static const Color disabledBorderColor =
      Color(0xFF444444); // Disabled element border

  // Functional Colors
  static const Color errorColor = Color(0xFFFF5252); // Error and failure
  static const Color successColor = Color(0xFF66BB6A); // Success and completion
  static const Color warningColor = Color(0xFFFFD600); // Warning
  static const Color infoColor = primaryColor; // Information

  // Rank Colors
  static const Color rankE = Color(0xFF9E9E9E); // E Rank - Gray
  static const Color rankD = Color(0xFF8BC34A); // D Rank - Green
  static const Color rankC = Color(0xFF29B6F6); // C Rank - Light Blue
  static const Color rankB = Color(0xFF7E57C2); // B Rank - Purple
  static const Color rankA = Color(0xFFFFB300); // A Rank - Gold
  static const Color rankS = Color(0xFFFF3D00); // S Rank - Red/Orange

  // Exercise Category Colors
  static const Color strengthColor = Color(0xFFE53935); // Strength exercises
  static const Color cardioColor = Color(0xFF43A047); // Cardio exercises
  static const Color flexibilityColor =
      Color(0xFF1E88E5); // Flexibility exercises

  // Button Colors
  static const Color buttonGlowColor =
      Color(0x662E7BFF); // Glow effect for buttons

  // Animation Durations
  static const Duration quickAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 350);
  static const Duration slowAnimation = Duration(milliseconds: 500);

  // Text Styles - Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.3,
  );

  // Text Styles - Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: textSecondary,
  );

  // Text Styles - Button Text
  static const TextStyle buttonTextLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonTextMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle buttonTextSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    letterSpacing: 0.2,
  );

  // Level & XP Constants
  static const int baseXpPerExercise = 10;
  static const int baseXpPerQuest = 50;
  static const double difficultyMultiplierE = 1.0;
  static const double difficultyMultiplierD = 1.5;
  static const double difficultyMultiplierC = 2.0;
  static const double difficultyMultiplierB = 2.5;
  static const double difficultyMultiplierA = 3.0;
  static const double difficultyMultiplierS = 4.0;

  // Level thresholds for ranks
  static const int rankEMinLevel = 1; // Starting rank
  static const int rankDMinLevel = 10;
  static const int rankCMinLevel = 20;
  static const int rankBMinLevel = 35;
  static const int rankAMinLevel = 50;
  static const int rankSMinLevel = 70;

  // XP required for each level (formula: level * 50 + 50)
  static int xpRequiredForLevel(int level) {
    return level * 50 + 50;
  }

  // Default user stats
  static const int defaultStrength = 5;
  static const int defaultEndurance = 5;
  static const int defaultFlexibility = 5;

  // Session Constants
  static const int defaultRestPeriod = 60; // Default rest in seconds
  static const int defaultSets = 3;
  static const int defaultReps = 10;

  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // API and Firebase Constants
  static const String userCollection = "users";
  static const String exerciseCollection = "exercises";
  static const String questCollection = "quests";
  static const String progressCollection = "progress";

  // Asset Paths
  static const String logoPath = "assets/images/ui/logo.png";
  static const String backgroundPath = "assets/images/ui/background.png";
  static const String dungeonGatePath = "assets/images/ui/dungeon_gate.png";

  // Rank Badge Paths
  static const String rankEPath = "assets/images/ranks/rank_e.png";
  static const String rankDPath = "assets/images/ranks/rank_d.png";
  static const String rankCPath = "assets/images/ranks/rank_c.png";
  static const String rankBPath = "assets/images/ranks/rank_b.png";
  static const String rankAPath = "assets/images/ranks/rank_a.png";
  static const String rankSPath = "assets/images/ranks/rank_s.png";

  // Animation Paths
  static const String levelUpAnimationPath = "assets/animations/level_up.json";
  static const String dungeonEntryAnimationPath =
      "assets/animations/dungeon_entry.json";
  static const String questCompleteAnimationPath =
      "assets/animations/quest_complete.json";

  // Error Messages
  static const String genericErrorMessage =
      "Something went wrong. Please try again.";
  static const String networkErrorMessage =
      "Network connection error. Please check your internet.";
  static const String authErrorMessage =
      "Authentication failed. Please login again.";
  static const String exerciseDataErrorMessage =
      "Could not load exercise data.";

  // Shared Preferences Keys
  static const String keyUserLoggedIn = "user_logged_in";
  static const String keyUserId = "user_id";
  static const String keyUserName = "user_name";
  static const String keyUserRank = "user_rank";
  static const String keyUserLevel = "user_level";
  static const String keyOnboardingComplete = "onboarding_complete";
  static const String keyDarkModeEnabled = "dark_mode_enabled";
  static const String keySoundEnabled = "sound_enabled";
  static const String keyHapticEnabled = "haptic_enabled";

  // Quest Constants
  static const int maxDailyQuests = 5;
  static const int maxWeeklyQuests = 3;
  static const int questRefreshHour = 0; // Midnight
}
