import '../enums/difficulty_level.dart';

class QuestModel {
  final String id;
  final String title;
  final String description;
  final DifficultyLevel difficulty;
  final int xpReward;
  final Map<String, int> statsReward;
  final List<QuestTask> tasks;
  final DateTime expiresAt;
  final bool isCompleted;
  final bool isDaily;

  const QuestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.xpReward,
    required this.statsReward,
    required this.tasks,
    required this.expiresAt,
    this.isCompleted = false,
    this.isDaily = true,
  });

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    DifficultyLevel? difficulty,
    int? xpReward,
    Map<String, int>? statsReward,
    List<QuestTask>? tasks,
    DateTime? expiresAt,
    bool? isCompleted,
    bool? isDaily,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statsReward: statsReward ?? this.statsReward,
      tasks: tasks ?? this.tasks,
      expiresAt: expiresAt ?? this.expiresAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isDaily: isDaily ?? this.isDaily,
    );
  }

  // Calculate quest progress percentage
  double get progressPercentage {
    if (tasks.isEmpty) return 0.0;
    int completed = tasks.where((task) => task.isCompleted).length;
    return completed / tasks.length;
  }

  // Check if all tasks are completed
  bool get allTasksCompleted {
    return tasks.every((task) => task.isCompleted);
  }

  // Check if quest is expired
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'difficulty': difficulty.name,
      'xpReward': xpReward,
      'statsReward': statsReward,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'expiresAt': expiresAt.toIso8601String(),
      'isCompleted': isCompleted,
      'isDaily': isDaily,
    };
  }

  factory QuestModel.fromJson(Map<String, dynamic> json) {
    return QuestModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      xpReward: json['xpReward'] ?? 50,
      statsReward: Map<String, int>.from(json['statsReward'] ?? {}),
      tasks: (json['tasks'] as List?)
              ?.map((task) => QuestTask.fromJson(task))
              .toList() ??
          [],
      expiresAt:
          DateTime.parse(json['expiresAt'] ?? DateTime.now().toIso8601String()),
      isCompleted: json['isCompleted'] ?? false,
      isDaily: json['isDaily'] ?? true,
    );
  }
}

class QuestTask {
  final String id;
  final String description;
  final String? exerciseId;
  final int targetCount;
  final int currentCount;
  final bool isCompleted;

  const QuestTask({
    required this.id,
    required this.description,
    this.exerciseId,
    required this.targetCount,
    this.currentCount = 0,
    this.isCompleted = false,
  });

  QuestTask copyWith({
    String? id,
    String? description,
    String? exerciseId,
    int? targetCount,
    int? currentCount,
    bool? isCompleted,
  }) {
    return QuestTask(
      id: id ?? this.id,
      description: description ?? this.description,
      exerciseId: exerciseId ?? this.exerciseId,
      targetCount: targetCount ?? this.targetCount,
      currentCount: currentCount ?? this.currentCount,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  // Increment task progress
  QuestTask incrementProgress([int amount = 1]) {
    final newCount = currentCount + amount;
    final newIsCompleted = newCount >= targetCount;
    return copyWith(
      currentCount: newCount,
      isCompleted: newIsCompleted,
    );
  }

  // Calculate task progress percentage
  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'exerciseId': exerciseId,
      'targetCount': targetCount,
      'currentCount': currentCount,
      'isCompleted': isCompleted,
    };
  }

  factory QuestTask.fromJson(Map<String, dynamic> json) {
    return QuestTask(
      id: json['id'],
      description: json['description'],
      exerciseId: json['exerciseId'],
      targetCount: json['targetCount'] ?? 1,
      currentCount: json['currentCount'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
