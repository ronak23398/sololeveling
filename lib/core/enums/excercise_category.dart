enum ExerciseCategory {
  strength,
  cardio,
  flexibility,
  balance,
  endurance,
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.flexibility:
        return 'Flexibility';
      case ExerciseCategory.balance:
        return 'Balance';
      case ExerciseCategory.endurance:
        return 'Endurance';
    }
  }

  String get description {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Build muscle and power';
      case ExerciseCategory.cardio:
        return 'Improve heart health and stamina';
      case ExerciseCategory.flexibility:
        return 'Enhance range of motion and prevent injury';
      case ExerciseCategory.balance:
        return 'Improve stability and coordination';
      case ExerciseCategory.endurance:
        return 'Build stamina and resilience';
    }
  }

  String get iconPath {
    switch (this) {
      case ExerciseCategory.strength:
        return 'assets/images/icons/strength.png';
      case ExerciseCategory.cardio:
        return 'assets/images/icons/cardio.png';
      case ExerciseCategory.flexibility:
        return 'assets/images/icons/flexibility.png';
      case ExerciseCategory.balance:
        return 'assets/images/icons/balance.png';
      case ExerciseCategory.endurance:
        return 'assets/images/icons/endurance.png';
    }
  }

  // Primary stat that this category affects
  String get primaryStat {
    switch (this) {
      case ExerciseCategory.strength:
        return 'strength';
      case ExerciseCategory.cardio:
        return 'endurance';
      case ExerciseCategory.flexibility:
        return 'flexibility';
      case ExerciseCategory.balance:
        return 'agility';
      case ExerciseCategory.endurance:
        return 'endurance';
    }
  }
}
