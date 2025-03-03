import 'package:flutter/foundation.dart';
import '../enums/difficulty_level.dart';
import '../enums/user_rank.dart';

class LevelCalculationService {
  // Constants for XP to level calculations
  static const int _baseXP = 100; // XP needed for level 1
  static const double _growthFactor =
      1.5; // How much XP requirement grows per level

  // Constants for calculating exercise XP - now using the enum's xpMultiplier property
  static const Map<DifficultyLevel, int> _difficultyBaseXP = {
    DifficultyLevel.beginner: 5,
    DifficultyLevel.intermediate: 10,
    DifficultyLevel.advanced: 15,
    DifficultyLevel.expert: 25,
    DifficultyLevel.master: 40,
  };

  // Constants for rank thresholds
  static const Map<UserRank, int> _rankThresholds = {
    UserRank.E: 0,
    UserRank.D: 5,
    UserRank.C: 15,
    UserRank.B: 30,
    UserRank.A: 50,
    UserRank.S: 75,
  };

  /// Calculate the total XP required to reach a specific level
  int calculateXPForLevel(int level) {
    if (level <= 0) return 0;
    if (level == 1) return _baseXP;

    double totalXP = _baseXP as double;
    for (int i = 2; i <= level; i++) {
      totalXP += _baseXP * (1 + (i - 1) * _growthFactor / 10);
    }

    return totalXP.round();
  }

  /// Calculate level based on total XP
  int calculateLevel(int totalXP) {
    if (totalXP < _baseXP) return 0;

    int level = 1;
    double requiredXP = _baseXP as double;
    double accumulatedXP = 0;

    while (accumulatedXP + requiredXP <= totalXP) {
      accumulatedXP += requiredXP;
      level++;
      requiredXP = _baseXP * (1 + (level - 1) * _growthFactor / 10);
    }

    return level;
  }

  /// Calculate XP progress within current level (0.0 to 1.0)
  double calculateLevelProgress(int totalXP, int currentLevel) {
    try {
      final xpForCurrentLevel = calculateXPForLevel(currentLevel);
      final xpForNextLevel = calculateXPForLevel(currentLevel + 1);
      final xpNeededForLevelUp = xpForNextLevel - xpForCurrentLevel;
      final xpInCurrentLevel = totalXP - xpForCurrentLevel;

      return xpInCurrentLevel / xpNeededForLevelUp;
    } catch (e) {
      debugPrint('Error calculating level progress: $e');
      return 0.0;
    }
  }

  /// Calculate user rank based on level
  UserRank calculateRank(int level) {
    if (level >= _rankThresholds[UserRank.S]!) {
      return UserRank.S;
    } else if (level >= _rankThresholds[UserRank.A]!) {
      return UserRank.A;
    } else if (level >= _rankThresholds[UserRank.B]!) {
      return UserRank.B;
    } else if (level >= _rankThresholds[UserRank.C]!) {
      return UserRank.C;
    } else if (level >= _rankThresholds[UserRank.D]!) {
      return UserRank.D;
    } else {
      return UserRank.E;
    }
  }

  /// Calculate XP earned from an exercise based on difficulty, reps and sets
  int calculateExerciseXP(DifficultyLevel difficulty, int reps, int sets) {
    // Get the base XP value for the difficulty level
    final baseXP = _difficultyBaseXP[difficulty] ??
        _difficultyBaseXP[DifficultyLevel.intermediate]!;

    // Use the xpMultiplier from the DifficultyLevelExtension
    final difficultyMultiplier = difficulty.xpMultiplier;

    // Calculate XP with diminishing returns for very high rep/set counts
    final repsFactor = 1 + (0.1 * _calculateWithDiminishingReturns(reps));
    final setsFactor = 1 + (0.2 * _calculateWithDiminishingReturns(sets));

    return (baseXP * repsFactor * setsFactor * difficultyMultiplier).round();
  }

  /// Calculate XP earned from a quest
  int calculateQuestXP(int questDifficulty) {
    // Simple formula: base value + difficulty multiplier
    return 50 + (questDifficulty * 25);
  }

  /// Helper function to calculate with diminishing returns
  double _calculateWithDiminishingReturns(int value) {
    if (value <= 0) return 0;
    if (value <= 10) return value.toDouble();
    if (value <= 20) return 10 + (value - 10) * 0.8;
    if (value <= 30) return 18 + (value - 20) * 0.6;
    if (value <= 50) return 24 + (value - 30) * 0.4;
    return 32 + (value - 50) * 0.2;
  }

  /// Calculate the streak bonus (XP multiplier based on consecutive days)
  double calculateStreakBonus(int consecutiveDays) {
    if (consecutiveDays <= 1) return 1.0;
    if (consecutiveDays <= 3) return 1.1;
    if (consecutiveDays <= 7) return 1.2;
    if (consecutiveDays <= 14) return 1.3;
    if (consecutiveDays <= 30) return 1.4;
    if (consecutiveDays <= 60) return 1.5;
    if (consecutiveDays <= 90) return 1.6;
    return 1.7; // Max bonus for 90+ days
  }

  /// Calculate XP needed for next level
  int calculateXPForNextLevel(int currentLevel) {
    return calculateXPForLevel(currentLevel + 1) -
        calculateXPForLevel(currentLevel);
  }

  /// Calculate XP needed to reach next rank
  int calculateXPForNextRank(int currentLevel, UserRank currentRank) {
    // Find the next rank
    UserRank nextRank;
    switch (currentRank) {
      case UserRank.E:
        nextRank = UserRank.D;
        break;
      case UserRank.D:
        nextRank = UserRank.C;
        break;
      case UserRank.C:
        nextRank = UserRank.B;
        break;
      case UserRank.B:
        nextRank = UserRank.A;
        break;
      case UserRank.A:
        nextRank = UserRank.S;
        break;
      case UserRank.S:
        // Already at max rank
        return 0;
    }

    // Calculate XP needed to reach level required for next rank
    final levelForNextRank = _rankThresholds[nextRank]!;
    if (currentLevel >= levelForNextRank) {
      return 0; // Already at required level
    }

    int xpForCurrentLevel = calculateXPForLevel(currentLevel);
    int xpForTargetLevel = calculateXPForLevel(levelForNextRank);

    return xpForTargetLevel - xpForCurrentLevel;
  }

  /// Calculate estimated days to next level based on average daily XP
  int estimatedDaysToNextLevel(int currentLevel, int averageDailyXP) {
    if (averageDailyXP <= 0) return -1; // Cannot estimate

    final xpNeeded = calculateXPForNextLevel(currentLevel);
    return (xpNeeded / averageDailyXP).ceil();
  }

  /// Get the color for a difficulty level
  String getDifficultyColor(DifficultyLevel difficulty) {
    return difficulty.colorCode;
  }

  /// Get the display name for a difficulty level
  String getDifficultyName(DifficultyLevel difficulty) {
    return difficulty.displayName;
  }
}
