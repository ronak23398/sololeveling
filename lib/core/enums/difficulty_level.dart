enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
  master,
}

extension DifficultyLevelExtension on DifficultyLevel {
  String get displayName {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.expert:
        return 'Expert';
      case DifficultyLevel.master:
        return 'Master';
    }
  }

  int get xpMultiplier {
    switch (this) {
      case DifficultyLevel.beginner:
        return 1;
      case DifficultyLevel.intermediate:
        return 2;
      case DifficultyLevel.advanced:
        return 3;
      case DifficultyLevel.expert:
        return 5;
      case DifficultyLevel.master:
        return 8;
    }
  }

  String get colorCode {
    switch (this) {
      case DifficultyLevel.beginner:
        return '#4CAF50'; // Green
      case DifficultyLevel.intermediate:
        return '#2196F3'; // Blue
      case DifficultyLevel.advanced:
        return '#9C27B0'; // Purple
      case DifficultyLevel.expert:
        return '#FF9800'; // Orange
      case DifficultyLevel.master:
        return '#FF5252'; // Red
    }
  }
}
