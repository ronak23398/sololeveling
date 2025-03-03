import 'package:solo_leveling/core/enums/excercise_category.dart';
import '../enums/difficulty_level.dart';

class ExerciseModel {
  final String id;
  final String name;
  final String description;
  final ExerciseCategory category;
  final DifficultyLevel difficulty;
  final int xpReward;
  final Map<String, int> statsGain;
  final List<String> instructions;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  const ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.statsGain,
    required this.instructions,
    this.imageUrl,
    this.metadata,
  });

  ExerciseModel copyWith({
    String? id,
    String? name,
    String? description,
    ExerciseCategory? category,
    DifficultyLevel? difficulty,
    int? xpReward,
    Map<String, int>? statsGain,
    List<String>? instructions,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      statsGain: statsGain ?? this.statsGain,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'xpReward': xpReward,
      'statsGain': statsGain,
      'instructions': instructions,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      category: ExerciseCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => ExerciseCategory.strength,
      ),
      difficulty: DifficultyLevel.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => DifficultyLevel.beginner,
      ),
      xpReward: json['xpReward'] ?? 10,
      statsGain: Map<String, int>.from(json['statsGain'] ?? {}),
      instructions: List<String>.from(json['instructions'] ?? []),
      imageUrl: json['imageUrl'],
      metadata: json['metadata'],
    );
  }
}
