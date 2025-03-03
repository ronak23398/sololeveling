class StatsModel {
  final int strength;
  final int endurance;
  final int agility;
  final int flexibility;
  final int experience;
  final int dungeonCleared;
  final int questsCompleted;
  final int exercisesCompleted;

  const StatsModel({
    this.strength = 0,
    this.endurance = 0,
    this.agility = 0,
    this.flexibility = 0,
    this.experience = 0,
    this.dungeonCleared = 0,
    this.questsCompleted = 0,
    this.exercisesCompleted = 0,
  });

  // Get total stats value
  int get totalStatsValue => strength + endurance + agility + flexibility;

  // Get experience needed for next level (sample formula)
  int experienceForLevel(int level) {
    return (level * 100) + ((level - 1) * 50);
  }

  StatsModel copyWith({
    int? strength,
    int? endurance,
    int? agility,
    int? flexibility,
    int? experience,
    int? dungeonCleared,
    int? questsCompleted,
    int? exercisesCompleted,
  }) {
    return StatsModel(
      strength: strength ?? this.strength,
      endurance: endurance ?? this.endurance,
      agility: agility ?? this.agility,
      flexibility: flexibility ?? this.flexibility,
      experience: experience ?? this.experience,
      dungeonCleared: dungeonCleared ?? this.dungeonCleared,
      questsCompleted: questsCompleted ?? this.questsCompleted,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
    );
  }

  // Increase stats based on completed exercise
  StatsModel increaseStats({
    int strengthGain = 0,
    int enduranceGain = 0,
    int agilityGain = 0,
    int flexibilityGain = 0,
    int experienceGain = 0,
  }) {
    return copyWith(
      strength: strength + strengthGain,
      endurance: endurance + enduranceGain,
      agility: agility + agilityGain,
      flexibility: flexibility + flexibilityGain,
      experience: experience + experienceGain,
      exercisesCompleted: exercisesCompleted + 1,
    );
  }

  // Increment dungeon cleared count
  StatsModel incrementDungeonCleared() {
    return copyWith(dungeonCleared: dungeonCleared + 1);
  }

  // Increment quests completed count
  StatsModel incrementQuestsCompleted() {
    return copyWith(questsCompleted: questsCompleted + 1);
  }

  Map<String, dynamic> toJson() {
    return {
      'strength': strength,
      'endurance': endurance,
      'agility': agility,
      'flexibility': flexibility,
      'experience': experience,
      'dungeonCleared': dungeonCleared,
      'questsCompleted': questsCompleted,
      'exercisesCompleted': exercisesCompleted,
    };
  }

  factory StatsModel.fromJson(Map<String, dynamic> json) {
    return StatsModel(
      strength: json['strength'] ?? 0,
      endurance: json['endurance'] ?? 0,
      agility: json['agility'] ?? 0,
      flexibility: json['flexibility'] ?? 0,
      experience: json['experience'] ?? 0,
      dungeonCleared: json['dungeonCleared'] ?? 0,
      questsCompleted: json['questsCompleted'] ?? 0,
      exercisesCompleted: json['exercisesCompleted'] ?? 0,
    );
  }

  // Method to calculate player power level based on stats
  int calculatePowerLevel() {
    return (strength * 1.5).ceil() +
        (endurance * 1.2).ceil() +
        (agility * 1.3).ceil() +
        (flexibility * 1.0).ceil();
  }

  // Generate summary of player's strongest and weakest attributes
  Map<String, String> getSummary() {
    final List<MapEntry<String, int>> statsList = [
      MapEntry('Strength', strength),
      MapEntry('Endurance', endurance),
      MapEntry('Agility', agility),
      MapEntry('Flexibility', flexibility),
    ];

    statsList.sort((a, b) => b.value.compareTo(a.value));

    final String strongest = statsList.first.key;
    final String weakest = statsList.last.key;

    return {
      'strongest': strongest,
      'weakest': weakest,
    };
  }

  // Calculate fitness balance - how evenly distributed the stats are
  double calculateStatBalance() {
    final avg = totalStatsValue / 4;
    final deviation = ((strength - avg).abs() +
            (endurance - avg).abs() +
            (agility - avg).abs() +
            (flexibility - avg).abs()) /
        4;

    // Return a percentage where 100% means perfectly balanced
    return (100 - (deviation / avg * 100)).clamp(0, 100);
  }
}
